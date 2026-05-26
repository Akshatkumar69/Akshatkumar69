-- macros/generate_schema_name.sql
-- Overrides dbt's default schema naming to work cleanly with Databricks
-- Without this, dbt appends the target schema to your custom schema name

{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}

    {%- else -%}
        {# In production: use just the custom schema name (no prefix) #}
        {# In dev: prefix with your username to avoid conflicts #}
        {%- if target.name == 'prod' -%}
            {{ custom_schema_name | trim }}
        {%- else -%}
            {{ default_schema }}_{{ custom_schema_name | trim }}
        {%- endif -%}

    {%- endif -%}
{%- endmacro %}
