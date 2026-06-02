USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.
Select p.name as product_name, c.name as category_name, p.price
From products p
Join categories c 
on p.category_id = c.category_id;
-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.
Select i.order_id, o.order_datetime, s.name as store_name, p.name as product_name, i.quantity, i.quantity*p.price as line_total
From products p
Join categories c 
on p.category_id = c.category_id
Join order_items i 
on p.product_id = i.product_id
join orders o 
on o.order_id = i.order_id
join stores s 
on s.store_id = o.store_id
order by o.order_datetime,i.order_id ;

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).

SELECT concat(c.first_name,' ', c.last_name) as customer_name,s.name as store_name,o.order_datetime ,sum(quantity*price) as order_total
FROM coffeeshop_db.orders o
join coffeeshop_db.order_items i 
on o.order_id = i.order_id
Join coffeeshop_db.products p 
on i.product_id = p.product_id
join coffeeshop_db.customers c 
on c.customer_id = o.customer_id
join stores s 
on o.store_id = s.store_id
Group by concat(c.first_name,' ', c.last_name),s.name,o.order_datetime ;

-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
select first_name, last_name, city, state
From  orders o 
left join customers c 
on c.customer_id = o.customer_id
where o.customer_id is null;

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
Select store_name,product_name,total_units
From (SELECT s.name as store_name, p.name as product_name, sum(quantity) as total_units,
row_number () over (partition by s.name order by sum(quantity) desc) as rRank
FROM coffeeshop_db.stores s 
Join coffeeshop_db.orders o 
on s.store_id = o.store_id
join coffeeshop_db.order_items i 
on o.order_id = i.order_id
join coffeeshop_db.products p
on i.product_id = p.product_id
where status = 'paid'
group by s.name , p.name) a
where a.rRank = 1;

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.

Select s.name as store_name,p.name as product_name,on_hand
From stores s
Join inventory i 
on s.store_id = i.store_id
Join products p 
on p.product_id = i.product_id
where on_hand < 12;

-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').

Select s.name as store_name, Concat(e.first_name,' ' ,e.last_name) as manager_name, hire_date
From employees e 
Join stores s 
on e.store_id = s.store_id
where title = 'Manager';

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.
with total_revenue As 
	(SELECT  p.name as product_name, sum(i.quantity * p.price) total_revenue
	FROM coffeeshop_db.order_items i 
	Join coffeeshop_db.products p 
	on i.product_id = p.product_id
	join orders o
	on i.order_id = o.order_id
	where o.status = 'paid'
	group by p.name),
    
    avg_revenue as (
    SELECT  p.name as product_name, AVG(i.quantity * p.price) avg_revenue
	FROM coffeeshop_db.order_items i 
	Join coffeeshop_db.products p 
	on i.product_id = p.product_id
	join orders o
	on i.order_id = o.order_id
	where o.status = 'paid'
	group by p.name
    )
    
    Select t.*
    From total_revenue t 
    Join avg_revenue a 
    on t.product_name = a.product_name
    where total_revenue > avg_revenue;


-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.
SELECT concat(first_name,' ', last_name) as customer_name,max(Date(order_datetime)) as last_paid_Date 
FROM coffeeshop_db.customers c
Left join coffeeshop_db.orders o 
on c.customer_id = o.customer_id
where o.status = 'paid'
group by first_name, last_name;

-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
SELECT 
    #s.store_id,
    s.name AS store_name,
    #c.category_id,
    c.name AS category_name,
    SUM(i.quantity) AS total_units,
    SUM(i.quantity * p.price) AS total_revenue
FROM coffeeshop_db.order_items  i
JOIN coffeeshop_db.orders  o 
    ON i.order_id = o.order_id
JOIN coffeeshop_db.products  p 
    ON i.product_id = p.product_id
JOIN coffeeshop_db.categories  c 
    ON p.category_id = c.category_id
JOIN coffeeshop_db.stores  s 
    ON o.store_id = s.store_id
WHERE o.status = 'paid'
GROUP BY s.store_id, c.category_id
ORDER BY s.store_id, total_revenue DESC;
