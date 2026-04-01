/*
  Override the default source() macro for Microsoft Fabric Data Warehouse.
  
  Fabric DW does not support 3-part table references inside EXEC() strings.
  This macro wraps the built-in source() to strip the database component,
  producing 2-part names ([schema].[table]).
*/

{% macro source(source_name, table_name) -%}
    {%- set rel = builtins.source(source_name, table_name) -%}
    {{ return(rel.include(database=false)) }}
{%- endmacro %}
