WITH current_products AS (

    SELECT *

    FROM {{ ref('products_snapshot') }}

    WHERE dbt_valid_to IS NULL

)

SELECT

    dbt_scd_id AS product_sk,

    product_id,

    product_name,

    category,

    price,

    supplier,

    product_status,

    dbt_valid_from AS effective_date,

    CURRENT_TIMESTAMP - dbt_valid_from
        AS time_since_last_change

FROM current_products