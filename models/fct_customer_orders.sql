WITH customers_cte AS (

    SELECT
        CUSTOMER_ID,
        CUSTOMER_NAME
    FROM {{ ref('customers') }}
)
SELECT
    CUSTOMER_ID,
    CUSTOMER_NAME,
    LENGTH(CUSTOMER_NAME) AS NAME_LENGTH
FROM customers_cte