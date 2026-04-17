-- Dta Analysis

select * from city;
select * from products;
select * from customers;
select * from products;

--report

--Q1 -> Coffee Consumers count
-- How many people in each city are estimated to consume coffee , given that 25% of the population does?

select 
city_name,
round(
(population * 0.25)/1000000,
2) as coffee_consumers_in_millions,
city_rank
from city
order by 2 desc

-- Total revenue from coffee sales 
--Q2.what is the total revenue generated from coffee sales across all cities in the last quarter of 2023?


select
  sum(total) as total_revenue
from sales
where
  extract(year from sales_date)  =2023
  and
  extract(quarter from sales_date) = 4


-- State wise revenue
select 
     ci.city_name,
	 sum(s.total) as total_revenue
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
where
     extract(year from  s.sales_date)   = 2023
	 and
	 extract(quarter from s.sales_date) = 4
group by 1
order by 2 desc


-- Sales count for each product
--Q3.How many units of each coffee product have been sold?

select 
   p.product_name,
   count(s.sales_id) as total_orders
from products as p
left join 
sales as s
on s.product_id = p.product_id
group by 1
order by 2 desc

--Average Sales amount per city
--Q4.what is the average sales amount per customer in each city 

--CITY and total sales
--no. of customers in city
-- total sales/no. of cust

select 
    ci.city_name,
	sum(s.total) as Total_revenue,
	count(distinct s.customer_id) as Total_Customers,
	ROUND(sum(s.total)::NUMERIC
	          /count(distinct s.customer_id)::NUMERIC
			  ,2) as avg_sale_pr_cust
from sales as s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1
order by 2 desc


--City population and coffee consumers
--Q5.Provide a list of cities along with their populations and estimated coffee consumers.


with city_table as

(
select
	city_name,
	round((population * 0.25)/1000000, 2) as coffee_consumers
from city
),
customers_table
as
(
	select
		ci.city_name,
		count(distinct c.customer_id) as unique_cx
	from sales as s
	join customers as c
	on c.customer_id = s.customer_id
	join city as ci
	on ci.city_id = c.city_id
	group by 1
)
select 
	customers_table.city_name,
	city_table.coffee_consumers as coffee_consumer_in_millions,
	customers_table.unique_cx
from city_table 
join
customers_table 
on city_table.city_name = customers_table.city_name



-- -- Q6
-- Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?

SELECT * 
FROM -- table
(
	SELECT 
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) as total_orders,
		DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) as rank
	FROM sales as s
	JOIN products as p
	ON s.product_id = p.product_id
	JOIN customers as c
	ON c.customer_id = s.customer_id
	JOIN city as ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2
	-- ORDER BY 1, 3 DESC
) as t1
WHERE rank <= 3

-- Q.7
-- Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT * FROM products;



SELECT 
	ci.city_name,
	COUNT(DISTINCT c.customer_id) as unique_cx
FROM city as ci
LEFT JOIN
customers as c
ON c.city_id = ci.city_id
JOIN sales as s
ON s.customer_id = c.customer_id
WHERE 
	s.product_id IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
GROUP BY 1


-- -- Q.8
-- Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

with city_table
as
(
select
	ci.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_cxn,
	round(
		sum(s.total)::numeric/
			count(distinct s.customer_id)::numeric
	,2) as avg_sale_pr_cx

	from sales as s
	join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on ci.city_id = c.city_id
	group by 1
	order by 2 desc
),
city_rent
as
(select 
	city_name,
	estimates_rent
from city
)
select 
	cr.city_name,
	cr.estimates_rent,
	ct.total_cxn,
	ct.avg_sale_pr_cx,
	ROUND(cr.estimates_rent::NUMERIC/ct.total_cxn::numeric, 2) as avg_rent_per_cxn
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 5 desc


-- Q.9
-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
-- by each city
with
monthly_sales
as
	(select 
		ci.city_name,
		extract(month from sales_date) as month,
		extract(year from sales_date) as year,
		sum(s.total) as total_sale
	from sales as s
	join customers as c
	on c.customer_id = s.customer_id
	join city as ci
	on ci.city_id = c.city_id
	group by 1,2,3
	order by 1,3,2 asc),
growth_ratio
as
(
select
	city_name,
	month,
	year,
	total_sale as cr_month_sale,
	lag(total_sale , 1) over(partition by city_name order by year,month) as last_month_sale
from monthly_sales
)

select
	city_name,
	month,
	year,
	cr_month_sale,
	last_month_sale,
	round((cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric * 100
	, 2) as Growth_ratio
from growth_ratio
where last_month_sale is not null


-- Q.10
-- Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


with city_table
as
(
select
	ci.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_cxn,
	round(
		sum(s.total)::numeric/
			count(distinct s.customer_id)::numeric
	,2) as avg_sale_pr_cx

	from sales as s
	join customers as c
	on s.customer_id = c.customer_id
	join city as ci
	on ci.city_id = c.city_id
	group by 1
	order by 2 desc
),
city_rent
as
(select 
	city_name,
	estimates_rent,
	round((population * 0.25)/1000000, 3) as estimated_Coffee_consumer_in_millions
from city
)
select 
	cr.city_name,
	total_revenue,
	cr.estimates_rent as total_rent,
	ct.total_cxn,
	estimated_Coffee_consumer_in_millions,
	ct.avg_sale_pr_cx,
	ROUND(cr.estimates_rent::NUMERIC/ct.total_cxn::numeric, 2) as avg_rent_per_cxn
from city_rent as cr
join city_table as ct
on cr.city_name = ct.city_name
order by 2 desc



/*
-- Recomendation
City 1: Pune
	1.Average rent per customer is very less.
	2.Highest total revenue.
	3.Average sales per customer is also high.

City 2: Delhi
	1.Highest estimated coffee consumers which is 7.7 million.
	2.Highest total number of customers, which is 68.
	3.Average rent per customer is 330 (still under 500).

City 3: Jaipur
	1.Highest number of customers, which is 69.
	2.Average rent per customer is very low at 156.
	3.Average sales per customer is better at 11.6k.
	