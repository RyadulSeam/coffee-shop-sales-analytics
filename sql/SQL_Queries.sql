-- =============================================


-- COFFEE SHOP SALES ANALYTICS - SQL QUERIES


-- =============================================


-- Developed by Ryadul Seam


-- =============================================


-- check the data type  


-- =============================================

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'coffee_shop_sales';


-- =============================================


-- total sales for each month 


-- =============================================


SELECT 
    TO_CHAR(DATE_TRUNC('month', transaction_date), 'Month YYYY') AS month_name,
    SUM(transaction_qty * unit_price) AS total_sales
FROM 
    coffee_shop_sales
GROUP BY 
    DATE_TRUNC('month', transaction_date)
ORDER BY 
    DATE_TRUNC('month', transaction_date);


-- =============================================


-- calculate MOM on total sales  for each month 


-- =============================================


WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(transaction_qty * unit_price) AS total_sales
    FROM 
        coffee_shop_sales
    GROUP BY 
        DATE_TRUNC('month', transaction_date)
),
sales_with_mom AS (
    SELECT 
        month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales,
        ROUND(
            (total_sales - LAG(total_sales) OVER (ORDER BY month)) 
            / NULLIF(LAG(total_sales) OVER (ORDER BY month), 0) * 100, 2
        ) AS mom_percent
    FROM 
        monthly_sales
)
SELECT 
    TO_CHAR(month, 'Mon YYYY') AS month_name,
    total_sales,
	previous_month_sales ,
    mom_percent
FROM 
    sales_with_mom
ORDER BY 
    month;


-- =============================================


-- total orders for each month 


-- =============================================


SELECT 
    TO_CHAR(DATE_TRUNC('month', transaction_date), 'Month YYYY') AS month_name,
    count(transaction_id) AS total_orders 
FROM 
    coffee_shop_sales
GROUP BY 
    DATE_TRUNC('month', transaction_date)
ORDER BY 
    DATE_TRUNC('month', transaction_date);


-- =============================================


-- calculate MOM on total orders for each month 


-- =============================================



WITH monthly_orders AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) AS month,
        COUNT(*) AS total_orders 
    FROM 
        coffee_shop_sales
    GROUP BY 
        DATE_TRUNC('month', transaction_date)
),
orders_with_mom AS (
    SELECT 
        month,
        total_orders,
        LAG(total_orders) OVER (ORDER BY month) AS previous_month_orders
    FROM 
        monthly_orders
),
final AS (
    SELECT 
        month,
        total_orders,
        previous_month_orders,
        ROUND(
            ((total_orders - previous_month_orders)::NUMERIC / NULLIF(previous_month_orders, 0)) * 100,
            2
        ) AS mom_percent
    FROM 
        orders_with_mom
)
SELECT 
    TO_CHAR(month, 'Mon YYYY') AS month_name,
    total_orders,
    previous_month_orders,
    mom_percent
FROM 
    final
ORDER BY 
    month;


-- =============================================


-- total quantity for each month 


-- =============================================



SELECT 
    TO_CHAR(DATE_TRUNC('month', transaction_date), 'Month YYYY') AS month_name,
    SUM(transaction_qty ) AS total_quantity
FROM 
    coffee_shop_sales
GROUP BY 
    DATE_TRUNC('month', transaction_date)
ORDER BY 
    DATE_TRUNC('month', transaction_date);


-- =============================================


-- calculate MOM on total quantity  for each month 


-- =============================================



WITH monthly_quantity AS (
    SELECT 
        DATE_TRUNC('month', transaction_date) AS month,
        SUM(transaction_qty ) AS total_quantity
    FROM 
        coffee_shop_sales
    GROUP BY 
        DATE_TRUNC('month', transaction_date)
),
quantity_with_mom AS (
    SELECT 
        month,
        total_quantity,
        LAG(total_quantity) OVER (ORDER BY month) AS previous_month_quantity,
        ROUND(
            (total_quantity - LAG(total_quantity) OVER (ORDER BY month)) ::NUMERIC
            / NULLIF(LAG(total_quantity) OVER (ORDER BY month), 0) * 100, 2
        ) AS mom_percent
    FROM 
        monthly_quantity
)
SELECT 
    TO_CHAR(month, 'Mon YYYY') AS month_name,
    total_quantity,
	previous_month_quantity ,
    mom_percent
FROM 
    quantity_with_mom
ORDER BY 
    month;


-- =============================================


-- daily trend of total sales , total quantity , total orders 


-- =============================================


select 
		SUM(transaction_qty * unit_price) AS total_sales ,
		 SUM(transaction_qty ) AS total_quantity , 
		count(transaction_id) AS total_orders
from coffee_shop_sales 
where 
		transaction_date = '2023-05-04';


-- =============================================


-- SALES TREND OVER PERIOD 


-- =============================================



select 
		round (avg (total_sales) , 2 ) as average_sales 
from (
		select 
				SUM(transaction_qty * unit_price)  AS total_sales 
		from coffee_shop_sales 
		where 
				extract (month from transaction_date ) = 5 -- Filter for "May" 
		group by 
				transaction_date 

);



-- =============================================


-- DAILY SALES FOR MONTH SELECTED 


-- =============================================



select 
		extract (day from transaction_date ) as day , 
		SUM(transaction_qty * unit_price)  AS total_sales 
		from coffee_shop_sales 
		where 
				extract (month from transaction_date ) = 5 -- Filter for "May" 
		group by 
				transaction_date 
		order by day ;	


-- =============================================


-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”	


-- =============================================



with daily_sales as (
	select 
			extract (day from transaction_date ) as day_of_month ,
			SUM(transaction_qty * unit_price)  AS total_sales
	from 
		coffee_shop_sales 
	where
		extract (month from transaction_date ) = 5 -- Filter for "May"
	group by 
			extract (day from transaction_date ) 
),
sales_with_status as (
	select
			day_of_month ,
			total_sales ,
			avg (total_sales) over ()  as average_sales 
	from daily_sales 
)
select day_of_month ,
		total_sales ,
		case 
			when total_sales > average_sales then 'ABOVE AVERAGE'
			when total_sales < average_sales then 'BELOW AVERAGE'
     		else 'AVERAGE'
		end as sales_status 
from sales_with_status 
order by day_of_month ;


-- =============================================


-- SALES BY WEEKDAY / WEEKEND 


-- =============================================


with daily_sales as (
		select 
				transaction_date ,
				unit_price * transaction_qty as sales_amount 
		from coffee_shop_sales 
		where 
			 extract (month from transaction_date ) = 5 -- Filter for "May"
) 
select 
		case 
			when extract ( dow from transaction_date ) in (0,6) then 'Weekends' -- "Sunday = 0" and "Saturday = 7"
			else 'Weekdays'
		end as day_type ,
		round (sum (sales_amount ),2) as total_sales 
from daily_sales 
group by 
		case 
			when extract ( dow from transaction_date ) in (0,6) then 'Weekends' -- "Sunday = 0" and "Saturday = 7"
			else 'Weekdays'
		end ;


-- =============================================


-- SALES BY STORE LOCATION 


-- =============================================


select 
		store_location ,
		SUM(transaction_qty * unit_price)  AS total_sales 
from coffee_shop_sales 
where extract (month from transaction_date ) = 5 -- Filter for "May" 
group by store_location 
order by total_sales desc ;


-- =============================================


-- SALES BY PRODUCT CATEGORY 


-- =============================================


select 
		product_category ,
		SUM(transaction_qty * unit_price)  AS total_sales 
from coffee_shop_sales 
where extract (month from transaction_date ) = 5 -- Filter for "May" 
group by product_category 
order by total_sales desc ;


-- =============================================


-- SALES BY PRODUCTS (TOP 10) 


-- =============================================



select 
		product_type ,
		SUM(transaction_qty * unit_price)  AS total_sales 
from coffee_shop_sales 
where extract (month from transaction_date ) = 5 -- Filter for "May" 
group by product_type 
order by total_sales desc 
limit 10 ;


-- =============================================


-- SALES BY DAY | HOUR 


-- =============================================



select 
		SUM(transaction_qty * unit_price)  AS total_sales ,
		count (*) as total_orders ,
		SUM(transaction_qty )  AS total_quantity
from coffee_shop_sales 
where 
	extract (dow from transaction_date) = 0 and -- "Sunday = 0" 
	extract (hour from transaction_time ) = 8 -- number of hour = 8 
;



-- =============================================


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY


-- =============================================



WITH sales_by_day AS (
    SELECT
        CASE 
            WHEN EXTRACT(DOW FROM transaction_date) = 0 THEN 'Sunday'
            WHEN EXTRACT(DOW FROM transaction_date) = 1 THEN 'Monday'
            WHEN EXTRACT(DOW FROM transaction_date) = 2 THEN 'Tuesday'
            WHEN EXTRACT(DOW FROM transaction_date) = 3 THEN 'Wednesday'
            WHEN EXTRACT(DOW FROM transaction_date) = 4 THEN 'Thursday'
            WHEN EXTRACT(DOW FROM transaction_date) = 5 THEN 'Friday'
            ELSE 'Saturday'
        END AS day_of_week,
        transaction_qty * unit_price AS sale_amount,
        transaction_qty
    FROM coffee_shop_sales
    WHERE EXTRACT(MONTH FROM transaction_date) = 5
)

SELECT
    day_of_week,
    ROUND(SUM(sale_amount), 2) AS total_sales,
    COUNT(*) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM sales_by_day
GROUP BY day_of_week
ORDER BY CASE
    WHEN day_of_week = 'Sunday' THEN 1
    WHEN day_of_week = 'Monday' THEN 2
    WHEN day_of_week = 'Tuesday' THEN 3
    WHEN day_of_week = 'Wednesday' THEN 4
    WHEN day_of_week = 'Thursday' THEN 5
    WHEN day_of_week = 'Friday' THEN 6
    WHEN day_of_week = 'Saturday' THEN 7
END;


-- =============================================


-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY 			


-- =============================================


select 
		extract (hour from transaction_time) as hour_of_day ,
		SUM(transaction_qty * unit_price)  AS total_sales ,
		count (*) as total_orders ,
		SUM(transaction_qty )  AS total_quantity
from coffee_shop_sales 
where
	 extract (month from transaction_date ) = 5 -- Filter for "May" 
group by hour_of_day 
order by hour_of_day asc ;