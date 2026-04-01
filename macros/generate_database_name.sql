/*
  Custom database name generation macro for Microsoft Fabric Data Warehouse.
  
  Fabric DW does not support 3-part table references ([database].[schema].[table])
  inside EXEC() strings. Returning None removes the database component from all
  rendered relation names, producing 2-part names ([schema].[table]).
  
  The USE [database] statement is handled separately via get_use_database_sql override.
*/

{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {% do return(none) %}
{%- endmacro %}
