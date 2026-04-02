/*
  Override the full fabric table materialization to fix error 15335 on
  repeated dbt runs in Fabric SQL DW.

  Root cause: adapter.drop_relation() does not reliably drop backup/temp
  tables in Fabric before the rename. When a prior run left stale
  __dbt_backup or __dbt_temp objects, the subsequent RENAME fails with:
    "The new name '<table>' is already in use ... (15335)"

  Fix: Add explicit DROP TABLE IF EXISTS / DROP VIEW IF EXISTS SQL
  statements (executed via statement blocks) before every rename, so we
  never depend on adapter.drop_relation() for cleanup.
*/
{% materialization table, adapter='fabric' %}

  {%- set target_relation = this.incorporate(type='table') %}
  {%- set existing_relation = adapter.get_relation(
        database=this.database, schema=this.schema, identifier=this.identifier) -%}

  {% if existing_relation is not none and not existing_relation.is_table %}
    {{ log("Dropping relation " ~ existing_relation ~ " because it is of type " ~ existing_relation.type) }}
    {{ adapter.drop_relation(existing_relation) }}
  {% endif %}

  {% set grant_config = config.get('grants') %}

  -- Build temp relation names
  {% set temp_relation      = make_temp_relation(target_relation, '__dbt_temp') %}
  {% set backup_relation    = make_backup_relation(target_relation, 'table') %}
  {% set tmp_vw_relation    = temp_relation.incorporate(
        path={"identifier": temp_relation.identifier ~ '__dbt_tmp_vw'}, type='view') %}

  -- Explicitly drop any stale temp/backup/view objects BEFORE doing work
  {% call statement('drop_stale_temp_vw') %}
    DROP VIEW IF EXISTS {{ tmp_vw_relation }};
  {% endcall %}

  {% call statement('drop_stale_temp') %}
    DROP TABLE IF EXISTS {{ temp_relation }};
  {% endcall %}

  {% call statement('drop_stale_backup') %}
    DROP TABLE IF EXISTS {{ backup_relation }};
  {% endcall %}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- Build the model into the temp relation
  {% call statement('main') -%}
    {{ create_table_as(False, temp_relation, sql) }}
  {% endcall %}

  {% if existing_relation is not none and existing_relation.is_table %}

    -- Drop backup (ensure clean slate before rename)
    {% call statement('drop_backup_before_rename') %}
      DROP TABLE IF EXISTS {{ backup_relation }};
    {% endcall %}

    -- Rename existing → backup
    {{ adapter.rename_relation(existing_relation, backup_relation) }}

    -- Fabric rename may be async — explicitly drop the target if it still exists
    {% call statement('drop_target_if_lingering') %}
      DROP TABLE IF EXISTS {{ target_relation }};
    {% endcall %}

    -- Rename temp → final
    {{ adapter.rename_relation(temp_relation, target_relation) }}

    -- Drop backup
    {% call statement('drop_backup_after_rename') %}
      DROP TABLE IF EXISTS {{ backup_relation }};
    {% endcall %}

  {%- else %}

    -- First-time build (or existing was a view, already dropped above):
    -- Drop target just in case, then rename temp → final
    {% call statement('drop_target_first_time') %}
      DROP TABLE IF EXISTS {{ target_relation }};
    {% endcall %}

    {{ adapter.rename_relation(temp_relation, target_relation) }}

  {% endif %}

  -- Drop temp view used by CETAS
  {% call statement('drop_tmp_vw_final') %}
    DROP VIEW IF EXISTS {{ tmp_vw_relation }};
  {% endcall %}

  {{ run_hooks(post_hooks, inside_transaction=True) }}
  {% do apply_grants(target_relation, grant_config, should_revoke=should_revoke) %}
  {% do persist_docs(target_relation, model) %}
  {{ adapter.commit() }}

  {{ build_model_constraints(target_relation) }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}
  {{ return({'relations': [target_relation]}) }}

{% endmaterialization %}


/*
  Override fabric__create_view_as to use CREATE OR ALTER VIEW instead of
  CREATE VIEW. The built-in adapter issues CREATE VIEW which fails on
  subsequent dbt runs with error 42S01 ("already an object named X").

  IMPORTANT: The CREATE VIEW statement must be the ONLY statement in a
  T-SQL batch. The fabric adapter wraps it in EXEC('...') for this reason
  — we must preserve that pattern and only change "create view" → "create
  or alter view" inside the EXEC string.
*/

{% macro fabric__create_view_as(relation, sql) -%}
    {%- set temp_view_sql = sql.replace("'", "''") -%}
    {{ get_use_database_sql(relation.database) }}
    {% set contract_config = config.get('contract') %}
    {% if contract_config.enforced %}
        {{ get_assert_columns_equivalent(sql) }}
    {%- endif %}

    EXEC('create or alter view {{ relation.include(database=False) }} as {{ temp_view_sql }};');

{% endmacro %}


/*
  Override fabric__create_schema to use target.database instead of relation.database.

  The built-in fabric__create_schema in dbt-fabric 1.9.9 has a hardcoded
  USE [{{ relation.database }}] that renders as USE [None] when
  generate_database_name returns None (our 2-part name strategy for Fabric DW).

  This override replaces it with USE [{{ target.database }}] so the correct
  database is always selected, even when relation.database is None.
*/

{% macro fabric__create_schema(relation) -%}
  {% call statement('create_schema') -%}
    USE [{{ target.database }}];
    IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{{ relation.schema }}')
    BEGIN
    EXEC('CREATE SCHEMA [{{ relation.schema }}]')
    END
  {% endcall %}
{% endmacro %}
