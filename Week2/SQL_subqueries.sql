USE coffeeshop_db;

-- =========================================================
-- SUBQUERIES & NESTED LOGIC PRACTICE
-- =========================================================

-- Q1) Scalar subquery (AVG benchmark):
--     List products priced above the overall average product price.
--     Return product_id, name, price.
select product_id, name, price
From products
Where price > (
	select avg(price)
	From products
    );

-- Q2) Scalar subquery (MAX within category):
--     Find the most expensive product(s) in the 'Beans' category.
--     (Return all ties if more than one product shares the max price.)
--     Return product_id, name, price.
Select product_id, name, price
From products
Where price > (
			Select Max(price)
			From products p 
			Join categories c
			on p.category_id = c.category_id
			where c.name = 'Beans'
            );

-- Q3) List subquery (IN with nested lookup):
--     List customers who have purchased at least one product in the 'Merch' category.
--     Return customer_id, first_name, last_name.
--     Hint: Use a subquery to find the category_id for 'Merch', then a subquery to find product_ids.
Select customer_id, first_name, last_name
From customers
where customer_id in (
	Select Distinct customer_id 
	From orders
	Where  order_id in (
		select Distinct order_id
		From order_items
		where product_id in (
			Select Distinct product_id
			from products
			where category_id = (
				Select category_id
				From categories
				where name = 'Merch')
				)
			)
        );
    

-- Q4) List subquery (NOT IN / anti-join logic):
--     List products that have never been ordered (their product_id never appears in order_items).
--     Return product_id, name, price.

select product_id, name, price
From products
Where product_id not in (
	Select Distinct product_id
	From order_items
    );

-- Q5) Table subquery (derived table + compare to overall average):
--     Build a derived table that computes total_units_sold per product
--     (SUM(order_items.quantity) grouped by product_id).
--     Then return only products whose total_units_sold is greater than the
--     average total_units_sold across all products.
--     Return product_id, product_name, total_units_sold.

Select oi.product_id, p.name as product_name, oi.total_units_sold
From (
    SELECT i.product_id, sum(i.quantity) AS total_units_sold
    FROM order_items AS i
    GROUP BY i.product_id
) AS oi
JOIN products AS p 
    ON oi.product_id = p.product_id
where oi.total_units_sold > (Select avg(quantity)
							From order_items );



