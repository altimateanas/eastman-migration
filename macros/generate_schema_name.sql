/*
  Custom schema name generation macro.
  When a custom schema is specified in the model config, use ONLY that schema name
  (not prepended with the target schema). This is critical for the migration where
  we need models to land in exact schema names like 'bronze', 'silver', 'transformed'.
*/

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
