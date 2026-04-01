/*
  Override the Fabric adapter's get_use_database_sql to always use target.database.
  
  Since generate_database_name returns None (to produce 2-part table names),
  relation.database will be None. This override ensures the USE [database] 
  statement always uses the configured target database from profiles.yml.
*/

{%- macro get_use_database_sql(database) -%}
  USE [{{ target.database }}];
{%- endmacro -%}
