SELECT *
FROM orders ;

#How many orders were placed, and how are they distributed across order statuses?
SELECT order_status ,
COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY  total_orders DESC ;

#How long does it take to deliver an order to the customer?
SELECT
    order_id,
    DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    ) AS delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

#What is the average delivery time?

SELECT
    AVG(
        DATEDIFF(
            order_delivered_customer_date,
            order_purchase_timestamp
        )
    ) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;
                             
#How often are orders delivered late compared to the estimated delivery date?

SELECT order_id , order_status ,
CASE 
WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
ELSE 'On time'

END


FROM orders
WHERE order_delivered_customer_date IS NOT NULL

;   


#What percentage of orders were delivered late?
 
SELECT
    COUNT(*) AS total_delivered_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS late_orders,

    SUM(
        CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(*) AS late_percentage,

    SUM(
        CASE
            WHEN order_delivered_customer_date <= order_estimated_delivery_date
            THEN 1
            ELSE 0
        END
    ) * 100.0 / COUNT(*) AS on_time_percentage

FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

#When an order is late, how many days late is it on average?
SELECT order_status, COUNT(*) AS all_orders ,

SUM( CASE
WHEN order_delivered_customer_date < order_estimated_delivery_date THEN 1
ELSE 0
END ) AS order_not_late ,

SUM( CASE
WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
ELSE 0
END ) AS order_is_late  ,
 AVG( CASE
	WHEN order_delivered_customer_date > order_estimated_delivery_date 
      THEN  DATEDIFF(
            order_delivered_customer_date,
            order_estimated_delivery_date
        ) END
    )  AS avg_late_days
FROM orders 
WHERE order_delivered_customer_date IS NOT NULL  
GROUP BY order_status ;
 
 #How long does it take to hand an approved order to the carrier?
 SELECT
    AVG(
        DATEDIFF(
            order_delivered_carrier_date,
            order_approved_at
        )
    ) AS avg_approved_to_carrier_days
FROM orders
WHERE order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL; 
  
  
#Breaking down the delivery journey into stages
#Stage 1
#Purchase → Approval
 WITH delivery_stages AS (
 SELECT
 order_status ,
DATEDIFF(
order_approved_at , order_purchase_timestamp ) purchase_to_approval_days ,

 
 
#Stage 2
#Approval → Carrier

 DATEDIFF(
 order_delivered_carrier_date, order_approved_at) AS approval_to_carrier_days ,
 #Stage 3
#Carrier → Customer
 DATEDIFF(order_delivered_customer_date, order_delivered_carrier_date) AS carrier_to_customer_days ,
 #Stage 4
#Purchase → Customer 
DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS purchase_to_customer_days 

FROM orders 
WHERE order_delivered_customer_date IS NOT NULL

)
SELECT
    AVG(purchase_to_approval_days) AS avg_purchase_to_approval,
    AVG(approval_to_carrier_days) AS avg_approval_to_carrier,
    AVG(carrier_to_customer_days) AS avg_carrier_to_customer,
    AVG(purchase_to_customer_days) AS avg_purchase_to_customer
FROM delivery_stages
GROUP BY order_status ;

#Who are the most frequent customers based on number of orders?
SELECT
    customer_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;

#How many customers placed more than one order?
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 1
) AS customer_orders;
