SELECT
    product_id,
    COUNT(*) AS current_records

FROM {{ ref('products_snapshot') }}

WHERE dbt_valid_to IS NULL

GROUP BY product_id

HAVING COUNT(*) > 1