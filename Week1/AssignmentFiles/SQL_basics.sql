USE coffeeshop_db;

-- =========================================================
-- BASICS PRACTICE
-- Instructions: Answer each prompt by writing a SELECT query
-- directly below it. Keep your work; you'll submit this file.
-- =========================================================

-- Q1) List all products (show product name and price), sorted by price descending.
Select name, price 
From products
order by price desc;
-- Q2) Show all customers who live in the city of 'Lihue'.
Select * 
From customers
where city = 'Lihue';
-- Q3) Return the first 5 orders by earliest order_datetime (order_id, order_datetime).
select order_id, order_datetime 
From orders
order by order_datetime
limit 5;
-- Q4) Find all products with the word 'Latte' in the name.
Select *
From products
where name like '%Latte%';
-- Q5) Show distinct payment methods used in the dataset.
Select distinct(payment_method) as payment_method
From orders;
-- Q6) For each store, list its name and city/state (one row per store).
Select distinct name, city, state
From stores;
-- Q7) From orders, show order_id, status, and a computed column total_items
--     that counts how many items are in each order.
Select o.order_id, o.status, sum(i.quantity) as total_items
From orders o
join order_items i 
on o.order_id = i.order_id
group by o.order_id, o.status;

-- Q8) Show orders placed on '2025-09-04' (any time that day).
select *
From orders
where DATE(order_datetime) = '2025-09-04';
-- Q9) Return the top 3 most expensive products (price, name).
Select name, price
From products
order by price desc
limit 3;
-- Q10) Show customer full names as a single column 'customer_name'
--      in the format "Last, First".
Select concat(first_name, ' ', last_name) as  customer_name
From customers;

