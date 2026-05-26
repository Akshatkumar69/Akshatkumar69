# akshat_dbt_project — dbt + MetricFlow on Databricks

## Your Real Table Schema

| Table | Columns |
|-------|---------|
| `workspace.default.customers` | `customer_id (int)`, `customer_name (string)`, `city (string)`, `signup_date (date)` |
| `workspace.default.orders` | `order_id (int)`, `customer_id (int)`, `order_date (date)`, `amount (double)`, `status (string)` |

---

## Run Commands (in exact order)

```bash
# 1. Install packages
dbt deps

# 2. Test connection
dbt debug

# 3. Build all models
dbt run

# 4. Run all tests
dbt test

# 5. Validate MetricFlow (THE most important step)
mf validate-configs

# 6. List available metrics
mf list metrics

# 7. Query metrics
mf query --metrics total_revenue --group-by metric_time
mf query --metrics total_revenue --group-by metric_time__month
mf query --metrics total_orders --group-by orders__order_status
mf query --metrics total_revenue --group-by orders__city
mf query --metrics average_order_value --group-by metric_time__month
mf query --metrics return_rate --group-by metric_time__month
mf query --metrics total_revenue --start-time 2024-01-01 --end-time 2024-12-31
```

---

## Available Metrics

| Metric Name | Type | Description |
|-------------|------|-------------|
| `total_revenue` | simple | Sum of order amounts |
| `total_orders` | simple | Count of all orders |
| `total_customers` | simple | Count of all customers |
| `total_new_customers` | simple | Customers signed up in last 365 days |
| `completed_orders` | simple | Orders with status = completed |
| `returned_orders` | simple | Orders with status = returned |
| `distinct_customers_with_orders` | simple | Unique customers who ordered |
| `average_order_value` | ratio | Revenue / Orders |
| `return_rate` | ratio | Returned / Total orders |
| `completion_rate` | ratio | Completed / Total orders |
| `revenue_per_customer` | ratio | Revenue / Distinct customers |
| `orders_per_customer` | derived | Total Orders / Total Customers |

---

## Data Flow

```
workspace.default.customers   workspace.default.orders
         │                              │
         ▼                              ▼
  stg_customers.sql              stg_orders.sql
  (view)                         (view)
         │                              │
         └──────────────┬───────────────┘
                        ▼
               fct_orders.sql (table)      dim_customers.sql (table)
                        │                          │
                        └──────────┬───────────────┘
                                   ▼
                        gold_sales_summary.sql (table)
                                   │
                        ┌──────────┴───────────────┐
                        ▼                          ▼
               sem_orders.yml            sem_customers.yml
                        │                          │
                        └──────────┬───────────────┘
                                   ▼
                             metrics.yml
                                   │
                                   ▼
                        mf query / BI Tools
```

---

## Common Errors

| Error | Fix |
|-------|-----|
| `source not found` | Check `database: workspace` and `schema: default` in staging/schema.yml |
| `column not found` | Your table columns changed — re-run DESCRIBE TABLE and update staging SQLs |
| `agg_time_dimension not found` | Every measure must reference `ordered_at` (orders) or `signup_date` (customers) |
| `entity not found for join` | Both semantic models must have a `customer` entity — already done ✅ |
| `No semantic model found` | Run `dbt run` FIRST, then `mf validate-configs` |
