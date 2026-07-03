-- macros/generate_schema_name.sql
-- Sobrescreve o comportamento padrão do dbt para nomear schemas
-- Garante que os schemas fiquem como: staging, mart (sem prefixo)

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}