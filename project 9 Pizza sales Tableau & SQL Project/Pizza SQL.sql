--1. TOTAL REVENUE 
select sum(total_price) as total_revenue 
from pizza_sales

--2. AVG ORDER VALUE 
--how many order value/total money spends every customer for each order
select sum(total_price)/count(distinct order_id) as avg_order_value
from pizza_sales

--3. Total Pizza Sold 
select sum(quantity) as total_pizza_sold
from pizza_sales

--4.Total Orders
select count(distinct order_id) as total_pizza_sold
from pizza_sales

--5. Average Pizzas Per Order 
-- how many pizza did the customers buy for each order
--order_id must use count(distinct) to prevent duplication not using sum 
--if we use sum then all the data including the duplicates will be count
select sum(quantity::numeric)/count(distinct order_id::numeric) as avg_per_order
from pizza_sales 

--6 Hourly Trend for Total Pizzas Sold
--order hours and total pizza sold 
select extract(hour from order_time::time) as hour,
sum(quantity) as total_sold
from pizza_sales
group by 1
order by 1 asc

--7 Weekly Trend for Orders
--weeknumber, year, totalorder
select TO_CHAR(TO_DATE(order_date, 'DD-MM-YYYY'), 'IW') AS weeknumber,
TO_CHAR(TO_DATE(order_date, 'DD-MM-YYYY'), 'IYYY')  AS year,
count(distinct order_id) as total_order
from pizza_sales
group by 1,2

--8 % of Sales by Pizza Category
--pizzacategory, total revenue, pct

SELECT 
    pizza_category,
    SUM(total_price) AS total_revenue,
    ROUND(
        SUM(total_price::numeric) * 100.0 /
        (SELECT SUM(total_price::numeric) FROM pizza_sales),
        2
    ) AS pct
FROM pizza_sales
GROUP BY 1;

-- 9 % of Sales by Pizza Size
SELECT 
    pizza_size,
    SUM(total_price) AS total_revenue,
    ROUND(
        SUM(total_price::numeric) * 100.0 /
        (SELECT SUM(total_price::numeric) FROM pizza_sales),
        2
    ) AS pct
FROM pizza_sales
group by 1
order by 3 desc

--10 Total Pizzas Sold by Pizza Category
select 
pizza_category, sum(quantity) as total_quantity_sold
from pizza_sales 
group by 1
order by 2 desc


--11 Top 5 Pizza by Revenue 
select 
pizza_name, sum(total_price) as total_revenue
from pizza_sales ps 
group by 1
order by 2 desc
limit 5


--12 Bottom 5 Pizzas by Revenue
select 
pizza_name, sum(total_price) as total_revenue
from pizza_sales ps 
group by 1
order by 2 asc
limit 5

--13 Top 5 Pizzas by Quantity
select pizza_name, 
sum(quantity) as total_pizza_sold
from pizza_sales ps
group by 1
order by 2 desc 
limit 5


--14 Bottom 5 Pizzas by Quantity
select pizza_name, 
sum(quantity) as total_pizza_sold
from pizza_sales ps
group by 1
order by 2 asc 
limit 5

--15 Top 5 Pizzas by Total Orders
select pizza_name, 
count(distinct order_id) as total_order
from pizza_sales ps
group by 1
order by 2 desc 
limit 5

--16 Bottom 5 Pizza by Total Orders
select pizza_name, 
count(distinct order_id) as total_order
from pizza_sales ps
group by 1
order by 2 asc
limit 5






select * from pizza_sales