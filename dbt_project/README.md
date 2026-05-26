# akshat_dbt_project — dbt + MetricFlow on Databricks

A complete dbt project with MetricFlow semantic layer for Databricks.

---

## Project Structure

```
akshat_dbt_project/
├── models/
│   ├── staging/               ← Raw data cleaning (views)
│   │   ├── stg_customers.sql
│   │   ├── stg_orders.sql
│   │   └── schema.yml         ← Sources + staging model docs & tests
│   ├── marts/                 ← Business-ready tables (materialized as tables)
│   │   ├── dim_customers.sql
│   │   ├── fct_orders.sql
│   │   ├── gold_sales_summary.sql
│   │   └── schema.yml
│   ├── semantic_models/       ← MetricFlow semantic model definitions
│   │   ├── sem_orders.yml
│   │   └── sem_customers.yml
│   └── metrics/               ← MetricFlow metric definitions
│       ├── metrics.yml
│       └── saved_queries.yml
├── seeds/                     ← Sample CSV data for local testing
│   ├── customers.csv
│   ├── orders.csv
│   └── schema.yml
├── tests/                     ← Custom SQL tests
├── macros/                    ← Custom dbt macros
├── analyses/                  ← Ad-hoc SQL analyses
├── dbt_project.yml            ← Main project config
├── profiles.yml               ← Databricks connection config
└── packages.yml               ← dbt package dependencies
```

---

## Step 1: Install Dependencies

```bash
pip install dbt-databricks dbt-metricflow
```

Verify:
```bash
dbt --version
mf --version
```

---

## Step 2: Configure Your Databricks Connection

Edit `profiles.yml` OR set environment variables:

```bash
export DATABRICKS_HOST="adb-XXXXXXXXXXXX.XX.azuredatabricks.net"
export DATABRICKS_HTTP_PATH="/sql/1.0/warehouses/XXXXXXXXXXXXXXXXX"
export DATABRICKS_TOKEN="dapiXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

Test connection:
```bash
dbt debug
```

---

## Step 3: Update Source References

In `models/staging/schema.yml`, update the source to match YOUR Databricks tables:

```yaml
sources:
  - name: raw
    database: hive_metastore   # ← your catalog name
    schema: default            # ← your schema where raw tables live
    tables:
      - name: customers        # ← must match your actual table name
      - name: orders           # ← must match your actual table name
```

**If your raw tables have different column names**, update the staging SQL files (`stg_customers.sql`, `stg_orders.sql`) to match your actual column names.

---

## Step 4: Run the Project (with your real Databricks data)

```bash
# Install dbt packages
dbt deps

# Run all models
dbt run

# Run tests
dbt test

# Validate MetricFlow config (IMPORTANT - run this to check for errors)
mf validate-configs

# Generate docs
dbt docs generate
dbt docs serve
```

---

## Step 5: Test with Seed Data (without Databricks)

If you want to test locally WITHOUT connecting to Databricks, use the seed data:

1. First, in `models/staging/stg_customers.sql` and `stg_orders.sql`, change the source reference to use seeds:

```sql
-- Change this:
select * from {{ source('raw', 'customers') }}

-- To this (for seed testing):
select * from {{ ref('customers') }}
```

2. Then run:
```bash
dbt seed          # loads CSV data into your warehouse
dbt run           # runs all models on top of seed data
dbt test          # runs all tests
mf validate-configs  # validates MetricFlow
```

---

## Step 6: Query Your Metrics with MetricFlow

```bash
# List all available metrics
mf list metrics

# List all dimensions
mf list dimensions --metrics total_revenue

# Query metrics
mf query --metrics total_revenue --group-by metric_time
mf query --metrics total_revenue --group-by metric_time__month
mf query --metrics total_revenue,total_orders --group-by orders__customer_segment
mf query --metrics average_order_value --group-by orders__country
mf query --metrics return_rate --group-by metric_time__month
mf query --metrics total_revenue --start-time 2024-01-01 --end-time 2024-12-31

# Validate everything
mf validate-configs
```

---

## Available Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `total_revenue` | simple | Sum of gross revenue |
| `total_net_revenue` | simple | Sum of net revenue after discounts |
| `total_orders` | simple | Count of all orders |
| `total_customers` | simple | Count of all customers |
| `total_new_customers` | simple | Customers acquired in last 365 days |
| `total_quantity_sold` | simple | Total units sold |
| `total_discounts` | simple | Sum of all discounts |
| `completed_orders` | simple | Count of completed orders |
| `returned_orders` | simple | Count of returned orders |
| `distinct_customers_ordering` | simple | Unique customers with orders |
| `average_order_value` | ratio | Revenue / Orders |
| `return_rate` | ratio | Returned / Total orders |
| `completion_rate` | ratio | Completed / Total orders |
| `revenue_per_customer` | ratio | Revenue / Distinct customers |
| `discount_rate` | ratio | Discounts / Revenue |
| `gross_profit` | derived | Revenue - Discounts |
| `orders_per_customer` | derived | Orders / Customers |

---

## Common Errors & Fixes

### Error: `No semantic model found`
→ Make sure you ran `dbt run` first before `mf validate-configs`

### Error: `agg_time_dimension not found`
→ Every measure must reference a time dimension that exists in the same semantic model

### Error: `entity not found for join`
→ Both semantic models must have a shared entity name (e.g., both have `customer` entity)

### Error: `source not found`
→ Update `models/staging/schema.yml` with your correct database/schema/table names

### Error: `column not found`
→ Update the staging SQL files to match your actual column names in Databricks

---

## Data Flow

```
Databricks Raw Tables
        │
        ▼
   stg_customers.sql  ←──  source('raw', 'customers')
   stg_orders.sql     ←──  source('raw', 'orders')
        │
        ▼
   dim_customers.sql  ←──  ref('stg_customers')
   fct_orders.sql     ←──  ref('stg_orders') + ref('stg_customers')
        │
        ▼
   gold_sales_summary.sql  ←──  ref('fct_orders') + ref('dim_customers')
        │
        ▼
   MetricFlow Semantic Models (sem_orders.yml, sem_customers.yml)
        │
        ▼
   Metrics (metrics.yml)
        │
        ▼
   mf query / BI Tools / Databricks Genie
```
