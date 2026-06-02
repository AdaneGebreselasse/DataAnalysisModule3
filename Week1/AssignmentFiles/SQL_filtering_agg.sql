-- ==================================
-- FILTERS & AGGREGATION
-- ==================================

USE coffeeshop_db;


-- Q1) Compute total items per order.
--     Return (order_id, total_items) from order_items.
Select order_id, sum(quantity) total_items
From order_items
group by order_id;
-- Q2) Compute total items per order for PAID orders only.
--     Return (order_id, total_items). Hint: order_id IN (SELECT ... FROM orders WHERE status='paid').
Select order_id, sum(quantity) total_items
From order_items
Where order_id in (SELECT order_id
	FROM coffeeshop_db.orders
	where status = 'paid')
group by order_id;

# OR 
 
SELECT o.order_id,sum(i.quantity) as total_items
FROM coffeeshop_db.orders o 
Join order_items i 
on o.order_id = i.order_id
where o.status = 'paid'
group by o.order_id ;

-- Q3) How many orders were placed per day (all statuses)?
--     Return (order_date, orders_count) from orders.
Select DATE(order_datetime) order_date, Count(*) as orders_count
From orders
group by DATE(order_datetime);
-- Q4) What is the average number of items per PAID order?
--     Use a subquery or CTE over order_items filtered by order_id IN (...).

with cte_Avg_qnty as (
SELECT order_id,round(avg(quantity)) as avg_qnty
 FROM coffeeshop_db.order_items
 group by order_id)
 
 Select o.order_id,avg_qnty ,o.status
 from orders o 
 join cte_Avg_qnty c 
 on o.order_id = c.order_id
 where o.status = 'paid';
 
-- Q5) Which products (by product_id) have sold the most units overall across all stores?
--     Return (product_id, total_units) total_units, sorted desc.
SELECT product_id,sum(quantity) as total_units
FROM order_items
group by product_id
Order by total_units desc;
-- Q6) Among PAID orders only, which product_ids have the most units sold?
--     Return (product_id, total_units_paid), sorted desc.
--     Hint: order_id IN (SELECT order_id FROM orders WHERE status='paid').
SELECT product_id,sum(quantity) as total_units
FROM order_items
where order_id IN (SELECT order_id FROM orders WHERE status='paid')
group by product_id
Order by total_units desc;
-- Q7) For each store, how many UNIQUE customers have placed a PAID order?
--     Return (store_id, unique_customers) using only the orders table.

SELECT distinct store_id, customer_id 
FROM coffeeshop_db.orders 
where status = 'paid'; 

-- Q8) Which day of week has the highest number of PAID orders?
--     Return (day_name, orders_count). Hint: DAYNAME(order_datetime). Return ties if any.
select DAYNAME(order_datetime) as day_name, Count(*) as orders_count
From orders
group by DAYNAME(order_datetime)
order by orders_count desc;

-- Q9) Show the calendar days whose total orders (any status) exceed 3.
--     Use HAVING. Return (order_date, orders_count).

select DATE(order_datetime) as order_date, Count(*) as orders_count
From orders
group by DATE(order_datetime)
order by orders_count desc;

-- Q10) Per store, list payment_method and the number of PAID orders.
--      Return (store_id, payment_method, paid_orders_count).
SELECT store_id,payment_method,Count(status) as paid_orders_count
FROM coffeeshop_db.orders 
Where status = 'paid'
group by  store_id,payment_method
order by store_id;

-- Q11) Among PAID orders, what percent used 'app' as the payment_method?
--      Return a single row with pct_app_paid_orders (0–100).
SELECT 
    ROUND(
        SUM(CASE WHEN payment_method = 'app' THEN paid_orders_count ELSE 0 END) 
        / SUM(paid_orders_count) * 100, 
        2
    ) AS app_payment_percent
FROM (
    SELECT store_id, payment_method, COUNT(status) AS paid_orders_count
    FROM coffeeshop_db.orders
    WHERE status = 'paid'
    GROUP BY store_id, payment_method
) a;

-- Q12) Busiest hour: for PAID orders, show (hour_of_day, orders_count) sorted desc.
SELECT 
    HOUR(order_datetime) AS hour_of_day,
    COUNT(*) AS orders_count
FROM coffeeshop_db.orders
WHERE status = 'paid'
GROUP BY HOUR(order_datetime)
ORDER BY orders_count DESC;

-- ================
