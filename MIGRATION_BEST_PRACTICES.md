# MS SQL Server to Microsoft Fabric Migration Best Practices with dbt

## Table of Contents

- [Overview](#overview)
- [1. Project Setup & Structure](#1-project-setup--structure)
  - [1.1 dbt Project Structure](#11-dbt-project-structure)
  - [1.2 dbt_project.yml Configuration](#12-dbt_projectyml-configuration)
- [2. Model Development](#2-model-development)
  - [2.1 Modularity and Readability](#21-modularity-and-readability)
  - [2.2 Referencing Other Models](#22-referencing-other-models)
  - [2.3 Idempotency](#23-idempotency)
  - [2.4 Python Models (dbt Core 1.3+)](#24-python-models-dbt-core-13)
- [3. Sources & Staging](#3-sources--staging)
  - [3.1 Defining Sources](#31-defining-sources)
  - [3.2 Staging Models](#32-staging-models)
- [4. Intermediate & Marts Models](#4-intermediate--marts-models)
  - [4.1 Intermediate Models](#41-intermediate-models)
  - [4.2 Marts Models](#42-marts-models)
- [5. Materializations](#5-materializations)
- [6. Testing](#6-testing)
  - [6.1 Generic Tests (Schema Tests)](#61-generic-tests-schema-tests)
  - [6.2 Singular Tests (Custom Data Tests)](#62-singular-tests-custom-data-tests)
- [7. Documentation](#7-documentation)
  - [7.1 Model and Column Descriptions](#71-model-and-column-descriptions)
- [Migration Strategy](#migration-strategy)
- [Medallion Architecture](#medallion-architecture)
- [Naming Conventions](#naming-conventions)
- [Model Design Best Practices](#model-design-best-practices)
- [Performance Optimization](#performance-optimization)
- [Migration Checklist](#migration-checklist)
- [Additional Resources](#additional-resources)

---

## Overview

This guide outlines best practices for migrating from MS SQL Server to Microsoft Fabric using dbt (data build tool) while implementing the Medallion Architecture pattern.

### Key Benefits of dbt for Fabric Migration

- Version-controlled data transformations
- Built-in testing and documentation
- Modular, reusable SQL logic
- Dependency management
- Easy rollback and deployment

---

## 1. Project Setup & Structure

### 1.1 dbt Project Structure

#### Recommended Folder Structure

```
eastman/
├── dbt_project.yml
├── packages.yml
├── README.md
├── MIGRATION_BEST_PRACTICES.md
├── analyses/
│   └── migration_validation.sql
├── macros/
│   ├── generate_schema_name.sql
│   ├── audit_columns.sql
│   └── data_quality_checks.sql
├── models/
│   ├── bronze/
│   │   ├── _bronze__sources.yml
│   │   ├── raw_customers.sql
│   │   ├── raw_orders.sql
│   │   └── raw_products.sql
│   ├── silver/
│   │   ├── _silver__models.yml
│   │   ├── stg_customers.sql
│   │   ├── stg_orders.sql
│   │   └── stg_products.sql
│   └── gold/
│       ├── _gold__models.yml
│       ├── dimensions/
│       │   ├── dim_customer.sql
│       │   ├── dim_product.sql
│       │   └── dim_date.sql
│       ├── facts/
│       │   ├── fact_sales.sql
│       │   └── fact_inventory.sql
│       └── marts/
│           └── mart_customer_360.sql
├── seeds/
│   ├── raw_categories.csv
│   ├── raw_customers.csv
│   └── raw_products.csv
├── snapshots/
│   ├── customer_snapshot.sql
│   └── product_snapshot.sql
├── tests/
│   ├── data_quality/
│   │   ├── test_customer_email_format.sql
│   │   └── test_sales_amount_positive.sql
│   └── migration_validation/
│       └── test_row_count_match.sql
└── target/
```

### 1.2 `dbt_project.yml` Configuration

- **Centralized Configuration:** Define project-level configurations, model paths, materializations, and variables here.
- **Profiles:** Keep `profiles.yml` (which contains connection credentials) out of version control (add to `.gitignore`). Use environment variables or secrets management for production credentials.
- **Model Configurations:** Configure models in `dbt_project.yml` or within model files using `{{ config(...) }}`. Prefer `dbt_project.yml` for directory-level configurations and `config()` blocks for model-specific overrides.

---

## 2. Model Development

### 2.1 Modularity and Readability

- **One Model, One Logical Unit:** Each model should represent a single, well-defined transformation or entity.
- **CTEs for Logic:** Use Common Table Expressions (CTEs) extensively to break down complex transformations into logical, readable steps.
  - Name CTEs clearly (e.g., `source_data`, `cleaned_data`, `joined_with_customers`).
- **SQL Style Guide:** Adopt a consistent SQL style guide (e.g., formatting, capitalization, commenting) across the team. Tools like SQLFluff can help enforce this.
- _Avoid "SELECT \*":_ Explicitly select columns. This improves clarity, prevents errors when source schemas change, and can optimize performance.
  - Use `dbt_utils.star()` macro if you need to select all columns from a source while excluding/renaming some.

### 2.2 Referencing Other Models

- **`ref()` function:** Always use the `{{ ref('model_name') }}` function to refer to other dbt models. This builds the dependency graph (DAG) and ensures correct build order.
- **`source()` function:** Use `{{ source('source_name', 'table_name') }}` to refer to raw source tables defined in your `schema.yml` files.

### 2.3 Idempotency

- Ensure your models are idempotent. Running `dbt run` multiple times should yield the same state in the data warehouse, assuming no changes to input data or model logic. This is especially important for incremental models.

### 2.4 Python Models (dbt Core 1.3+)

- Use Python models for transformations that are difficult or inefficient to express in SQL (e.g., complex statistical analysis, machine learning feature engineering).
- Keep Python models focused and ensure they integrate well with your SQL-based DAG.
- Materialize Python model outputs as tables or incremental tables.

---

## 3. Sources & Staging

### 3.1 Defining Sources

- Define all raw data inputs as sources in `.yml` files (typically `models/staging/<source_system>/_sources.yml` or a dedicated `models/_sources.yml`).
- This allows dbt to understand dependencies on raw data and enables features like `dbt source freshness`.

### 3.2 Staging Models

- **Purpose:** Create one staging model for each source table.
  - Staging models should perform minimal transformations: renaming columns (to a consistent style), casting data types, basic cleaning (e.g., trimming whitespace).
  - **No Joins:** Avoid joins in staging models. Joins should happen in downstream intermediate or mart models.
- **Naming:** `stg_<source_name>__<table_name>` (e.g., `stg_jaffle_shop__customers`).
- **Lightweight Transformations:**
  - Column renaming: `customer_id AS customer_id` (even if same, for clarity) or `cst_id AS customer_id`.
  - Type casting: `CAST(order_date AS DATE) AS order_date`.
  - Basic calculations if they are universally applicable and derived directly from the source (e.g., `amount / 100 AS amount_dollars` if source stores cents).
- **Idempotency:** Staging models are typically materialized as views by default, which are inherently idempotent.

---

## 4. Intermediate & Marts Models

### 4.1 Intermediate Models

- **Purpose:** Bridge the gap between staging models and mart models. Used for complex joins, aggregations, or transformations that are reused in multiple mart models.
- **Location:** `models/intermediate/`.
- **Naming:** `int_<description>.sql` (e.g., `int_orders_with_payments.sql`).
- Materialize as tables if they are complex to compute and used by many downstream models, or as ephemeral/views if simpler.

### 4.2 Marts Models

- **Purpose:** Provide clean, transformed data ready for analytics, BI tools, or operational use cases.
  - Often conform to dimensional modeling principles (fact and dimension tables) or represent specific business entities/processes.
- **Location:** `models/marts/` (can be further subdivided by business domain, e.g., `marts/finance/`, `marts/marketing/`).
- **Naming:**
  - Dimension tables: `dim_<entity>.sql` (e.g., `dim_customers.sql`).
  - Fact tables: `fct_<process_or_event>.sql` (e.g., `fct_orders.sql`).
- **Business Logic:** Mart models encapsulate core business logic and definitions.
- **Performance:** Optimize for query performance by BI tools (e.g., denormalization where appropriate, correct materializations).

---

## 5. Materializations

Choose the appropriate materialization for each model based on its characteristics and usage:

- **`view` (default):**
  - **Pros:** No data stored, always reflects current underlying data. Good for staging models and simple transformations.
  - **Cons:** Recomputed every time it's queried. Can be slow if the underlying logic is complex or queries large datasets.

- **`table`:**
  - **Pros:** Faster query performance for downstream models/BI tools as data is physically stored.
  - **Cons:** Uses storage. Data is only as fresh as the last `dbt run`. Rebuilt fully on each run.
  - **Use Case:** Mart models, complex intermediate models, models referenced by many downstream consumers.

- **`incremental`:**
  - **Pros:** Only processes new or changed data, significantly faster and more resource-efficient for large datasets.
  - **Cons:** More complex to configure correctly (requires `unique_key`, `is_incremental()` logic). Can lead to stale data if not managed properly.
  - **Use Case:** Large fact tables, event logs, any model where full rebuilds are too expensive.

- **`ephemeral`:**
  - **Pros:** Not materialized in the warehouse at all; interpolated as a CTE or subquery in downstream models. Reduces warehouse clutter.
  - **Cons:** Can make debugging harder. Not queryable directly.
  - **Use Case:** Very simple helper models, one-off transformations used in only one downstream model.

---

## 6. Testing

dbt provides a robust framework for testing your data.

### 6.1 Generic Tests (Schema Tests)

- Built-in tests provided by dbt (and packages like `dbt_utils`).
- Apply to specific columns in your models.
- Defined in `.yml` files alongside model and column definitions.
- Examples:

```yaml
models:
  - name: dim_customers
    columns:
      - name: customer_id
        tests:
          - unique
          - not_null
      - name: status
        tests:
          - accepted_values:
              values: ["active", "inactive"]
  - name: fct_orders
    columns:
      - name: customer_id
        tests:
          - relationships:
              to: ref('dim_customers')
              field: customer_id
```

- `unique`: Ensures all values in a column are unique.
- `not_null`: Ensures no null values in a column.
- `accepted_values`: Ensures column values are within a specified list.
- `relationships`: Ensures referential integrity between two models (foreign key check).

### 6.2 Singular Tests (Custom Data Tests)

- SQL queries that select "failing" rows. If the query returns any rows, the test fails.
- Stored in the `tests/` directory.
- Name files descriptively (e.g., `tests/assert_order_total_is_positive.sql`).

---

## 7. Documentation

dbt makes data documentation a first-class citizen.

### 7.1 Model and Column Descriptions

- Add descriptions for all models and columns in your `.yml` files.

```yaml
models:
  - name: dim_customers
    description: "Dimension table for customer attributes. One row per customer."
    columns:
      - name: customer_id
        description: "Unique identifier for a customer."
      - name: first_name
        description: "Customer's first name."
```

---

## Migration Strategy

### 1. Assessment Phase

- **Inventory existing objects**: Catalog all tables, views, stored procedures, functions, and jobs
- **Identify dependencies**: Map data lineage and transformation dependencies
- **Classify data sensitivity**: Determine security and compliance requirements
- **Performance baseline**: Document current performance metrics

### 2. Planning Phase

- **Choose migration approach**:
  - Lift-and-shift (initial load via seeds/external tables)
  - Incremental migration (phased approach)
  - Hybrid (temporary coexistence)
- **Define success criteria**: Set performance, data quality, and business KPIs
- **Create rollback plan**: Ensure safe migration with fallback options

### 3. Execution Phase

- **Bronze layer**: Load raw data using dbt seeds or external tables
- **Silver layer**: Transform and cleanse data using dbt models
- **Gold layer**: Create business-ready aggregates and marts

---

## Medallion Architecture

The Medallion Architecture (Bronze, Silver, Gold) is a data design pattern for organizing data in a lakehouse.

### Bronze Layer (Raw/Landing)

**Purpose**: Store raw, unprocessed data exactly as received from source systems

**Characteristics**:

- Minimal to no transformations
- Preserves historical data in original format
- Append-only or full snapshots
- Include metadata columns (load timestamp, source system)

**Implementation**:

```sql
-- Example: Bronze model
-- models/bronze/raw_customers.sql
{{ config(
    materialized='incremental',
    unique_key='customer_id',
    schema='bronze',
    tags=['bronze', 'source_mssql']
) }}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _loaded_at,
    'mssql_server' AS _source_system
FROM {{ source('mssql', 'customers') }}
```

**Folder structure**:

```
models/
└── bronze/
    ├── _bronze__sources.yml
    ├── raw_customers.sql
    ├── raw_orders.sql
    └── raw_products.sql
```

### Silver Layer (Cleansed/Conformed)

**Purpose**: Cleaned, validated, and conformed data ready for analytics

**Characteristics**:

- Data quality rules applied
- Standardized formats and naming
- Deduplication and type casting
- Business logic applied
- SCD (Slowly Changing Dimensions) implementation

**Implementation**:

```sql
-- Example: Silver model
-- models/silver/stg_customers.sql
{{ config(
    materialized='incremental',
    unique_key='customer_key',
    schema='silver',
    tags=['silver', 'staging']
) }}

WITH source AS (
    SELECT * FROM {{ ref('raw_customers') }}
    {% if is_incremental() %}
    WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} AS customer_key,
        UPPER(TRIM(customer_id)) AS customer_id,
        TRIM(first_name) AS first_name,
        TRIM(last_name) AS last_name,
        LOWER(TRIM(email)) AS email,
        CASE
            WHEN phone_number ~ '^[0-9]{10}$' THEN phone_number
            ELSE NULL
        END AS phone_number,
        created_date,
        modified_date,
        _loaded_at,
        _source_system,
        {{ dbt_utils.generate_surrogate_key(['customer_id', '_loaded_at']) }} AS row_hash
    FROM source
    WHERE customer_id IS NOT NULL
)

SELECT * FROM cleaned
```

**Folder structure**:

```
models/
└── silver/
    ├── _silver__models.yml
    ├── stg_customers.sql
    ├── stg_orders.sql
    ├── stg_products.sql
    └── README.md
```

### Gold Layer (Business/Presentation)

**Purpose**: Business-ready, aggregated data optimized for consumption

**Characteristics**:

- Denormalized for query performance
- Business metrics and KPIs
- Dimensional models (facts and dimensions)
- Aggregated/summarized data
- Optimized for reporting and BI tools

**Implementation**:

```sql
-- Example: Gold dimension model
-- models/gold/dim_customer.sql
{{ config(
    materialized='table',
    schema='gold',
    tags=['gold', 'dimension']
) }}

SELECT
    customer_key,
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    first_name,
    last_name,
    email,
    phone_number,
    created_date,
    DATEDIFF(day, created_date, CURRENT_DATE()) AS customer_tenure_days,
    CASE
        WHEN DATEDIFF(day, created_date, CURRENT_DATE()) <= 30 THEN 'New'
        WHEN DATEDIFF(day, created_date, CURRENT_DATE()) <= 365 THEN 'Active'
        ELSE 'Loyal'
    END AS customer_segment,
    modified_date,
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at
FROM {{ ref('stg_customers') }}
```

```sql
-- Example: Gold fact model
-- models/gold/fact_sales.sql
{{ config(
    materialized='incremental',
    unique_key='sales_key',
    schema='gold',
    tags=['gold', 'fact']
) }}

SELECT
    {{ dbt_utils.generate_surrogate_key(['o.order_id', 'oi.order_item_id']) }} AS sales_key,
    o.order_key,
    c.customer_key,
    p.product_key,
    d.date_key,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total,
    o.tax_amount,
    o.shipping_amount,
    CURRENT_TIMESTAMP() AS dw_created_at
FROM {{ ref('stg_orders') }} o
INNER JOIN {{ ref('stg_order_items') }} oi ON o.order_id = oi.order_id
INNER JOIN {{ ref('dim_customer') }} c ON o.customer_id = c.customer_id
INNER JOIN {{ ref('dim_product') }} p ON oi.product_id = p.product_id
INNER JOIN {{ ref('dim_date') }} d ON CAST(o.order_date AS DATE) = d.date_value
{% if is_incremental() %}
WHERE o._loaded_at > (SELECT MAX(dw_created_at) FROM {{ this }})
{% endif %}
```

**Folder structure**:

```
models/
└── gold/
    ├── _gold__models.yml
    ├── dimensions/
    │   ├── dim_customer.sql
    │   ├── dim_product.sql
    │   ├── dim_date.sql
    │   └── dim_store.sql
    ├── facts/
    │   ├── fact_sales.sql
    │   └── fact_inventory.sql
    └── marts/
        ├── mart_customer_360.sql
        └── mart_sales_summary.sql
```

---

## Naming Conventions

### Model Names

#### Bronze Layer

- **Prefix**: `raw_`
- **Pattern**: `raw_<source_table_name>`
- **Examples**:
  - `raw_customers.sql`
  - `raw_orders.sql`
  - `raw_order_items.sql`

#### Silver Layer

- **Prefix**: `stg_` (staging)
- **Pattern**: `stg_<entity_name>`
- **Examples**:
  - `stg_customers.sql`
  - `stg_orders.sql`
  - `stg_order_items.sql`

#### Gold Layer - Dimensions

- **Prefix**: `dim_`
- **Pattern**: `dim_<dimension_name>`
- **Examples**:
  - `dim_customer.sql`
  - `dim_product.sql`
  - `dim_date.sql`
  - `dim_store.sql`

#### Gold Layer - Facts

- **Prefix**: `fct_` or `fact_`
- **Pattern**: `fct_<business_process>` or `fact_<business_process>`
- **Examples**:
  - `fct_sales.sql` or `fact_sales.sql`
  - `fct_inventory.sql` or `fact_inventory.sql`

#### Gold Layer - Marts

- **Prefix**: `mart_`
- **Pattern**: `mart_<business_area>`
- **Examples**:
  - `mart_customer_360.sql`
  - `mart_sales_summary.sql`
  - `mart_product_performance.sql`

### Column Names

- Use **snake_case** for all column names
- Be descriptive but concise
- Add suffixes for clarity:
  - `_id`: Natural keys from source systems
  - `_key`: Surrogate keys (hashed or generated)
  - `_date`: Date columns
  - `_timestamp` or `_at`: Timestamp columns
  - `_amount`: Monetary values
  - `_flag` or `_is`: Boolean indicators
  - `_count`: Count metrics

**Examples**:

```sql
customer_id          -- Natural key
customer_key         -- Surrogate key
order_date           -- Date column
created_at           -- Timestamp column
total_amount         -- Monetary value
is_active            -- Boolean flag
order_count          -- Count metric
```

### Schema Names

- **Bronze**: `bronze` or `raw`
- **Silver**: `silver` or `staging`
- **Gold**: `gold`, `analytics`, or `mart`

### Tags

Use tags to categorize models:

```yaml
tags:
  - bronze / silver / gold
  - source_mssql / source_api
  - daily / hourly / weekly
  - pii / sensitive
  - dimension / fact / mart
```

---

## Model Design Best Practices

### 1. Incremental Models

Use incremental models for large datasets to improve performance:

```sql
{{ config(
    materialized='incremental',
    unique_key='order_key',
    incremental_strategy='merge',
    on_schema_change='fail'
) }}

SELECT * FROM source_data
{% if is_incremental() %}
WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```

### 2. Use CTEs (Common Table Expressions)

Structure models with clear, readable CTEs:

```sql
WITH source AS (
    SELECT * FROM {{ ref('raw_orders') }}
),

filtered AS (
    SELECT * FROM source
    WHERE order_status != 'CANCELLED'
),

enhanced AS (
    SELECT
        *,
        CASE WHEN total_amount > 1000 THEN 'High Value' ELSE 'Standard' END AS order_category
    FROM filtered
)

SELECT * FROM enhanced
```

### 3. Surrogate Keys

Generate consistent surrogate keys using `dbt_utils`:

```sql
{{ dbt_utils.generate_surrogate_key(['customer_id', 'order_id']) }} AS order_key
```

### 4. Audit Columns

Add standard audit columns to all models:

```sql
-- Create macro: macros/audit_columns.sql
{% macro audit_columns() %}
    CURRENT_TIMESTAMP() AS dw_created_at,
    CURRENT_TIMESTAMP() AS dw_updated_at,
    'dbt' AS dw_created_by
{% endmacro %}

-- Use in models:
SELECT
    *,
    {{ audit_columns() }}
FROM source
```

### 5. Slowly Changing Dimensions (SCD)

Implement SCD Type 2 using snapshots:

```sql
-- snapshots/customer_snapshot.sql
{% snapshot customer_snapshot %}

{{
    config(
        target_schema='silver',
        unique_key='customer_id',
        strategy='timestamp',
        updated_at='modified_date'
    )
}}

SELECT * FROM {{ ref('stg_customers') }}

{% endsnapshot %}
```

### 6. Data Quality at Each Layer

- **Bronze**: Minimal validation, preserve source data integrity
- **Silver**: Apply data quality rules, handle nulls, standardize formats
- **Gold**: Business rule validation, referential integrity

### 7. Materialization Strategy

Choose appropriate materialization based on use case:

| Layer             | Materialization     | Reason                                        |
| ----------------- | ------------------- | --------------------------------------------- |
| Bronze            | Incremental or View | Preserve raw data, optimize for storage       |
| Silver            | Incremental         | Balance performance and freshness             |
| Gold - Dimensions | Table               | Small, frequently accessed, relatively static |
| Gold - Facts      | Incremental         | Large, append-only or merge                   |
| Gold - Marts      | Table or View       | Depends on complexity and size                |

---

## Testing Strategy

### Schema Tests

Define tests in YAML files:

```yaml
# models/silver/_silver__models.yml
version: 2

models:
  - name: stg_customers
    description: Cleansed and standardized customer data
    columns:
      - name: customer_key
        description: Surrogate key for customer
        tests:
          - unique
          - not_null

      - name: email
        description: Customer email address
        tests:
          - not_null
          - unique

      - name: customer_id
        description: Natural key from source system
        tests:
          - not_null
          - relationships:
              to: ref('raw_customers')
              field: customer_id
```

### Custom Data Quality Tests

Create custom tests for business rules:

```sql
-- tests/data_quality/test_sales_amount_positive.sql
SELECT
    order_id,
    total_amount
FROM {{ ref('fact_sales') }}
WHERE total_amount < 0
```

### Migration Validation Tests

Validate data migration accuracy:

```sql
-- tests/migration_validation/test_row_count_match.sql
WITH source_count AS (
    SELECT COUNT(*) AS cnt FROM {{ source('mssql', 'customers') }}
),
target_count AS (
    SELECT COUNT(*) AS cnt FROM {{ ref('raw_customers') }}
)
SELECT *
FROM source_count
WHERE source_count.cnt != (SELECT cnt FROM target_count)
```

### Test Categories

- **Integrity tests**: unique, not_null, relationships
- **Accuracy tests**: Custom SQL to validate business logic
- **Completeness tests**: Row count validation, null checks
- **Consistency tests**: Cross-table validation

---

## Documentation

### Model Documentation

Document all models in YAML:

```yaml
version: 2

models:
  - name: dim_customer
    description: |
      Customer dimension containing current and historical customer information.
      This is a Type 2 SCD tracking changes over time.
    columns:
      - name: customer_key
        description: Surrogate key (auto-generated hash)
      - name: customer_id
        description: Natural key from source system
      - name: full_name
        description: Concatenated first and last name
```

### Generate Documentation Site

```bash
dbt docs generate
dbt docs serve
```

### Inline Documentation

Add descriptions in models:

```sql
-- models/gold/dim_customer.sql
/*
  Dimension: Customer
  Purpose: Master customer dimension with SCD Type 2 tracking
  Grain: One row per customer per version
  Source: silver.stg_customers
*/

SELECT ...
```

---

## Performance Optimization

### 1. Partitioning

Leverage Fabric's partitioning capabilities:

```sql
{{ config(
    materialized='incremental',
    partition_by={
        "field": "order_date",
        "data_type": "date"
    }
) }}
```

### 2. Clustering

Use appropriate clustering for query performance:

```sql
{{ config(
    materialized='table',
    cluster_by=['customer_id', 'order_date']
) }}
```

### 3. Incremental Strategies

Choose the right incremental strategy:

- **append**: For immutable event data
- **merge**: For updates and inserts (use unique_key)
- **delete+insert**: For complete partition refreshes

### 4. Model Dependencies

Minimize model dependencies to reduce compilation time:

- Avoid circular dependencies
- Use sources instead of repeated refs
- Create intermediate models for complex logic

### 5. Query Optimization

- Use WHERE clauses early in CTEs
- Avoid SELECT \*; specify needed columns
- Use appropriate JOIN types
- Leverage indexes on source tables

### 6. Resource Management

Configure model-specific resources:

```yaml
# dbt_project.yml
models:
  eastman:
    gold:
      +materialized: table
      +threads: 4
    silver:
      +materialized: incremental
      +threads: 8
    bronze:
      +materialized: view
```

---

## Migration Checklist

### Pre-Migration

- [ ] Complete source system inventory
- [ ] Document business rules and transformations
- [ ] Set up Fabric workspace and data warehouse
- [ ] Install and configure dbt
- [ ] Define naming conventions and standards
- [ ] Create project structure

### Migration

- [ ] Create bronze models (raw data ingestion)
- [ ] Create silver models (cleansing and standardization)
- [ ] Create gold models (dimensions and facts)
- [ ] Implement data quality tests
- [ ] Add documentation
- [ ] Validate against source system

### Post-Migration

- [ ] Performance testing and optimization
- [ ] User acceptance testing
- [ ] Create migration runbooks
- [ ] Train users on new system
- [ ] Monitor and optimize
- [ ] Decommission old system (when appropriate)

---

## Additional Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Microsoft Fabric Documentation](https://learn.microsoft.com/en-us/fabric/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture)

---

**Document Version**: 1.1
**Last Updated**: 2026-04-01
**Maintained By**: Data Engineering Team
