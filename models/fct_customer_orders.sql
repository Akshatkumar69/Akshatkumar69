SELECT
    c.CUSTOMER_ID,
    c.CUSTOMER_NAME,
    o.ORDER_ID,
    o.AMOUNT
FROM {{ ref('stg_customers') }} c
JOIN ORDERS o
    ON c.CUSTOMER_ID = o.CUSTOMER_ID