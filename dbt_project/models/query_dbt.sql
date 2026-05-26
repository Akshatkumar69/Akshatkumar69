SELECT `customer_name`,
    COUNT(*) AS `count`
FROM `default`.`customers` AS `default__customers`
GROUP BY 1
