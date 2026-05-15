WITH source_products AS (

    SELECT *
    FROM {{ ref('products') }}

),

cleaned_products AS (

    SELECT

        CAST(product_id AS INTEGER) AS product_id,

        TRIM(name) AS product_name,

        TRIM(category) AS category,

        CAST(price AS DOUBLE) AS price,

        TRIM(supplier) AS supplier,

        LOWER(TRIM(status)) AS product_status,

        CURRENT_TIMESTAMP AS updated_at,

        {{ dbt_utils.generate_surrogate_key([
            'name',
            'category',
            'price',
            'supplier',
            'status'
        ]) }} AS record_hash

    FROM source_products

)

SELECT *
FROM cleaned_products