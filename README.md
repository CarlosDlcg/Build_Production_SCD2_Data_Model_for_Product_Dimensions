# Production SCD2 Product Dimension Model with dbt

![dbt](https://img.shields.io/badge/dbt-Analytics%20Engineering-orange)
![DuckDB](https://img.shields.io/badge/DuckDB-Data%20Warehouse-yellow)
![SQL](https://img.shields.io/badge/SQL-Data%20Modeling-blue)
![SCD2](https://img.shields.io/badge/SCD2-Historical%20Tracking-green)

A production-oriented Slowly Changing Dimension Type 2 (SCD2) implementation built with dbt and DuckDB for historical product tracking in an ecommerce analytics environment.

This project demonstrates modern Analytics Engineering and Data Engineering concepts including:

- SCD Type 2 historical modeling
- dbt snapshots
- dimensional data modeling
- temporal analytics
- data quality validation
- staging and marts architecture
- surrogate key generation
- production-style warehouse design

---

# Business Problem

In modern ecommerce systems, product information changes constantly:

- prices change,
- suppliers change,
- categories are reorganized,
- products become inactive or discontinued.

Analytics teams need historical visibility into these changes to answer questions such as:

- How do price changes impact sales?
- Which supplier relationships perform best over time?
- How do category reorganizations affect customer behavior?
- What was the exact state of a product at a given point in time?

This project implements a production-style SCD2 architecture using dbt snapshots to preserve complete product history while maintaining analyst-friendly access to current dimensional data.

---

# Architecture Overview

```text
Raw Product Data (CSV Seed)
            ↓
Staging Layer (stg_products)
            ↓
dbt Snapshot (SCD2 History Tracking)
            ↓
Current Product Dimension
(dim_products_current)
            ↓
Analytics / BI
```

---

# Key Engineering Concepts Demonstrated

| Concept | Description |
|---|---|
| SCD Type 2 | Historical version tracking |
| dbt Snapshots | Automated temporal versioning |
| Dimensional Modeling | Analytics-ready warehouse design |
| Surrogate Keys | Stable warehouse identifiers |
| Staging Layer | Cleaned and standardized source data |
| Data Quality Testing | Production reliability validation |
| Temporal Analytics | Querying historical product states |
| Modern Data Stack | dbt + DuckDB workflow |

---

# Project Structure

```text
Build_Production_SCD2_Data_Model_for_Production_Dimensions/
│
├── README.md
├── requirements.txt
├── .gitignore
│
├── ecommerce_scd2/
│   │
│   ├── models/
│   │   ├── staging/
│   │   │   └── stg_products.sql
│   │   │
│   │   ├── marts/
│   │   │   └── dim_products_current.sql
│   │   │
│   │   └── schema.yml
│   │
│   ├── snapshots/
│   │   └── products_snapshot.sql
│   │
│   ├── seeds/
│   │   └── products.csv
│   │
│   ├── tests/
│   │   └── assert_single_current_record.sql
│   │
│   ├── dbt_project.yml
│   └── dev.duckdb
│
└── venv/
```

---

# SCD2 Workflow

The project follows a layered warehouse modeling architecture commonly used in modern analytics engineering environments.

---

## 1. Seed Layer

Raw product data is loaded from CSV:

```csv
product_id,name,category,price,supplier,status
1,Laptop,Electronics,1000,TechCorp,active
2,Mouse,Accessories,25,PeriTech,active
3,Keyboard,Accessories,75,PeriTech,active
```

---

## 2. Staging Layer

`stg_products.sql` standardizes and prepares product data for historical tracking.

Responsibilities:
- data cleaning,
- type standardization,
- formatting normalization,
- surrogate hash generation.

Example:

```sql
{{ dbt_utils.generate_surrogate_key([
    'name',
    'category',
    'price',
    'supplier',
    'status'
]) }}
```

The hash enables efficient change detection for SCD2 processing.

---

## 3. Snapshot Layer (SCD2)

`products_snapshot.sql` implements Slowly Changing Dimension Type 2 logic.

```sql
{% snapshot products_snapshot %}

{{
    config(
        target_schema='main',
        unique_key='product_id',
        strategy='check',
        check_cols=[
            'product_name',
            'category',
            'price',
            'supplier',
            'product_status'
        ]
    )
}}

SELECT *
FROM {{ ref('stg_products') }}

{% endsnapshot %}
```

The snapshot automatically:
- detects changes,
- closes previous versions,
- creates new historical records,
- manages temporal validity periods.

---

# Example SCD2 Behavior

## Initial Product State

| product_id | product_name | price |
|---|---|---|
| 1 | Laptop | 1000 |

---

## After Price Update

| product_id | product_name | price |
|---|---|---|
| 1 | Laptop | 1200 |

---

## Historical Result

| product_id | product_name | price | dbt_valid_from | dbt_valid_to |
|---|---|---|---|---|
| 1 | Laptop | 1000 | earlier timestamp | update timestamp |
| 1 | Laptop | 1200 | update timestamp | NULL |

`dbt_valid_to IS NULL` represents the current active version.

---

# Current Product Dimension

`dim_products_current.sql` exposes analyst-friendly access to current product information only.

Typical filtering logic:

```sql
WHERE dbt_valid_to IS NULL
```

This pattern is commonly used in enterprise dimensional warehouses for joining dimensions to fact tables.

---

# Data Quality Testing

The project includes production-style dbt tests validating:

- surrogate key uniqueness,
- business key completeness,
- accepted status values,
- current-record consistency,
- temporal validity,
- logical pricing constraints.

Example custom SCD2 validation:

```sql
SELECT
    product_id,
    COUNT(*) AS current_records

FROM {{ ref('products_snapshot') }}

WHERE dbt_valid_to IS NULL

GROUP BY product_id

HAVING COUNT(*) > 1
```

This ensures every product has exactly one active current version.

---

# Technologies Used

| Technology | Purpose |
|---|---|
| dbt | Transformations and snapshots |
| DuckDB | Local analytical warehouse |
| SQL | Modeling and transformations |
| dbt-utils | Surrogate key generation |
| DBeaver | Warehouse querying and inspection |

---

# How to Run the Project

## 1. Clone the Repository

```bash
git clone https://github.com/CarlosDlcg/Build_Production_SCD2_Data_Model_for_Product_Dimensions.git
cd Build_Production_SCD2_Data_Model_for_Production_Dimensions
```

---

## 2. Create Virtual Environment (Optional)

```bash
python -m venv venv
```

Activate environment:

### Windows

```bash
venv\Scripts\activate
```

### Linux / macOS

```bash
source venv/bin/activate
```

---

## 3. Install Dependencies

```bash
pip install -r requirements.txt
```

---

## 4. Configure dbt Profile

Create:

```text
~/.dbt/profiles.yml
```

Example configuration:

```yaml
ecommerce_scd2:
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb
      threads: 1

  target: dev
```

---

## 5. Navigate to dbt Project

```bash
cd ecommerce_scd2
```

---

## 6. Install dbt Packages

```bash
dbt deps
```

---

## 7. Load Seed Data

```bash
dbt seed
```

---

## 8. Run Models

```bash
dbt run
```

---

## 9. Execute SCD2 Snapshots

```bash
dbt snapshot
```

---

## 10. Run Data Quality Tests

```bash
dbt test
```

---

# Verifying Historical Tracking

## Step 1 — Modify Product Data

Update a value inside:

```text
seeds/products.csv
```

Example:

```csv
1,Laptop,Electronics,1200,TechCorp,active
```

---

## Step 2 — Reload Seed Data

```bash
dbt seed --full-refresh
```

---

## Step 3 — Re-run Snapshots

```bash
dbt snapshot
```

---

## Step 4 — Query Historical Records

```sql
SELECT
    product_id,
    product_name,
    price,
    dbt_valid_from,
    dbt_valid_to
FROM main.products_snapshot
ORDER BY product_id, dbt_valid_from;
```

---

# Example Queries

## Current Product Records

```sql
SELECT *
FROM main.products_snapshot
WHERE dbt_valid_to IS NULL;
```

---

## Historical Product Versions

```sql
SELECT *
FROM main.products_snapshot
WHERE product_id = 1
ORDER BY dbt_valid_from;
```

---

# Engineering Principles Applied

This project follows modern Analytics Engineering and warehouse modeling best practices:

- layered modeling architecture,
- separation of concerns,
- immutable historical tracking,
- reproducible transformations,
- production-oriented testing,
- scalable warehouse design,
- temporal data modeling,
- analyst-friendly marts.

---

# Learning Outcomes

This project reinforced understanding of:

- Slowly Changing Dimensions (SCD2)
- dbt snapshots
- dimensional warehouse modeling
- temporal analytics
- surrogate keys
- modern Analytics Engineering workflows
- warehouse testing strategies
- historical data management

---

# Future Improvements

Potential future enhancements include:

- cloud warehouse integration
- orchestration with Airflow
- CI/CD pipelines
- incremental processing
- automated freshness monitoring
- fact table integration
- semantic layer modeling
- dashboard integration

---

# Author

Carlos De los Cobos

Computer Engineering Student focused on:
- Data Engineering
- Analytics Engineering
- Data Warehousing
- Distributed Systems
- Scalable Data Architectures