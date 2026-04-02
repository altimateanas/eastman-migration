/*
  Override the Fabric adapter's get_use_database_sql to always use target.database.
  
  Since generate_database_name returns None (to produce 2-part table names),
  relation.database will be None. This override ensures the USE [database] 
  statement always uses the configured target database from profiles.yml,
  regardless of what value (including None) is passed in.
  
  dbt dispatches as: adapter.dispatch('get_use_database_sql', 'dbt')
  Resolution order: dbt__get_use_database_sql → fabric__get_use_database_sql → default__get_use_database_sql
  We override all variants to be safe.
*/

{%- macro get_use_database_sql(database) -%}
  USE [{{ target.database }}];
{%- endmacro -%}

{%- macro dbt__get_use_database_sql(database) -%}
  USE [{{ target.database }}];
{%- endmacro -%}

{%- macro fabric__get_use_database_sql(database) -%}
  USE [{{ target.database }}];
{%- endmacro -%}

{%- macro default__get_use_database_sql(database) -%}
  USE [{{ target.database }}];
{%- endmacro -%}
