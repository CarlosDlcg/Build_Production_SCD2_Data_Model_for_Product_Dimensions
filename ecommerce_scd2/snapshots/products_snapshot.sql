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