select * from orders;
--change DDL using alter table to change type timestamp --> date in order_date column
alter table orders
alter column order_date
type date
using order_date::DATE;

--find top 10 highest revenue generating products
select 
	product_id, 
	sum(sale_price::numeric) as sales 
from orders 
group by orders.product_id 
order by sales DESC
limit 10;

--find top 5 highest selling products in each region
--based on this code below we can select each region by adding ',' comma
--so the highest selling product in East is TEC-CO-10004722, sales = 29099
-- and Central is TEC-CO-10004722	sales = 16975 and so on 


--to decide 5 highest selling product we can use CTE and rank it
--after creating 1 CTE the results also presnt 0 in sales, so we can only rank top 1-5 therefore we create sub_query
with rank_region as(
select 
	region,product_id,
	sum(sale_price::numeric) as sales
from orders 
group by region,product_id
order by region,sales desc 
)
--sub_query
select * from (
select 
	*, 
	dense_rank() over(partition by region order by sales DESC) as ranking
from rank_region) as sub_rank 
where ranking <= 5

--find month over month growth comparison for 2022 and 2023 sales 
--eg: jan 2022 , jan 2023
with cte as (
select 
sum(sale_price::numeric) as sales,
--extract(month from order_date)|| '-' ||  extract(year from order_date) as date
extract(Month from order_date) as month,
extract(Year from order_date)as year
from orders 
group by month, year
--order by year desc
)
select month,
sum(case when year=2022 then sales else 0 end) as sales_2022,
sum(case when year=2023 then sales else 0 end) as sales_2023
from cte
group by month
order by month asc

--for each category which month had highest sales 
with category as (
select distinct(category) as category, 
extract(month from order_date) as month,
extract(year from order_date)as year,
sum(sale_price::numeric) as sales
from orders
group by category, month, year 
order by category,sales desc
) 
select * from(
select *,
dense_rank() over(partition by category order by sales desc) as ranking
from category) as sub_rank
where ranking =1


--which sub category had highest growth by profit in 2023 compare to 2022
with sub_category as(
select sub_category,
extract(year from order_date)as year,
sum(sale_price::numeric) as sales
from orders
group by orders.sub_category,  year 
order by sales desc
),
cte_2 as(
select sub_category,
sum(case when year=2022 then sales else 0 end) as sales_2022,
sum(case when year=2023 then sales else 0 end) sales_2023
from sub_category
group by sub_category
)
select *
,(sales_2023-sales_2022)*100/sales_2022 as growth_percentage
from cte_2
order by growth_percentage desc
limit 1












