-- DATA ANALYSIS
-- Question 1
-- A. Which product categories drive the biggest profits?
-- B. Is this the same across store locations?

-- Solution to A
/*
To get the product category with the biggest profits, 
a profit table 't1' was created using the below codes.
*/

SELECT
	p.product_category AS p_category,
	p.product_name,
 	s.date,
	(p.product_price * s.units) AS revenue,
	(p.product_cost * s.units) AS cost_price,
	(p.product_price * s.units)-(p.product_cost * s.units) AS profits
FROM products p
JOIN sales s
ON s.product_id = p.product_id;

/*
Next, the profits for each product category was pulled from t1 and 
ordered from highest to lowest using the below codes. (smile emoji)
*/
SELECT
	p_category,
	SUM(profits) sum_profits
FROM
	(SELECT
		p.product_category AS p_category,
	 	p.product_name,
	 	s.date,
		(p.product_price * s.units) AS revenue,
		(p.product_cost * s.units) AS cost_price,
		(p.product_price * s.units)-(p.product_cost * s.units) AS profits
	FROM products p
	JOIN sales s
	ON s.product_id = p.product_id) t1 --
GROUP BY 1
ORDER BY sum_profits DESC;

/*
From the results, the 'Toys' category recorded the highest profits 
of $ 1,079,527.00 for the company. 
*/

------------------------------------------------------------------------------
-- Question 1
-- B. Is this the same across store locations?
-- Solution B
/*
To answer the question of whether the product category with the
the highest profits is the same across the various store locations, 
a profit table 't2' with store locations was created with the below 
codes.
*/

SELECT
	p.product_category AS p_category,
	str.store_location AS str_location,
	(p.product_price * s.units) AS revenue,
	(p.product_cost * s.units) AS cost_price,
	(p.product_price * s.units)-(p.product_cost * s.units) AS profits
FROM products p
JOIN sales s
ON s.product_id = p.product_id
JOIN stores str 
ON s.store_id = str.store_id;

/*
Finally, the profits for each product category at the different store locations 
was pulled from 't2' using the below codes. (smile emoji)
*/

SELECT
	str_location,
	p_category,
	SUM(profits) sum_profits
FROM
	(SELECT
		p.product_category AS p_category,
	 	str.store_location AS str_location,
		(p.product_price * s.units) AS revenue,
		(p.product_cost * s.units) AS cost_price,
		(p.product_price * s.units)-(p.product_cost * s.units) AS profits
	FROM products p
	JOIN sales s
	ON s.product_id = p.product_id
	JOIN stores str 
	ON s.store_id = str.store_id
	) t2
GROUP BY 1,2
ORDER BY str_location;
/* 
The results revealed that the 'Toys' product category recorded the highest 
profits in 'Residential' and 'Downtown' store locations, whiles stores
located at 'Airport' and 'Commercial' places saw 'Electronics' products
generating the highest profits for Maven Toys.
*/

/*
Given the high profitability of 'Toys,' Maven Toys should ensure that 
these products are well-stocked in stores located in residential and downtown areas to meet customer demand.
Similarly, for 'Electronics,' adequate inventory management strategies 
should be in place to meet demand in airport and commercial locations.
*/
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

-- Question 2
-- A. How much money is tied up at the inventory at the toy stores?
-- B. How long will it last?

-- Solution A
/*
To know the amount of money is tied up at the inventory at the toy stores,
a table containing the **current** inventory of toys products and their respective prices 
and potential revenue were created with the following codes
*/
SELECT
	p.product_category AS p_category,
	p.product_name,
	p.product_price,
	i.stock_on_hand,
	s.date,
	p.product_price * i.stock_on_hand AS potential_toys_revenue
FROM products p
JOIN inventory i
ON i.product_id = p.product_id
JOIN sales s
ON s.product_id = p.product_id
WHERE p.product_category = 'Toys' AND
	  s.date = (SELECT
					date
				FROM sales
				ORDER BY date DESC
				LIMIT 1);

/*
The product and the sum of potential revenue for the product
was pulled from the table as **current** money tied up at inventory at
the toys store using the following codes
*/
SELECT
	p_category,
	SUM(potential_toys_revenue) AS money_tied_at_toys_inventory
FROM
	(SELECT
		p.product_category AS p_category,
		p.product_name,
		p.product_price,
		i.stock_on_hand,
		s.date,
		p.product_price * i.stock_on_hand AS potential_toys_revenue
	FROM products p
	JOIN inventory i
	ON i.product_id = p.product_id
	JOIN sales s
	ON s.product_id = p.product_id
	WHERE p.product_category = 'Toys' AND
		  s.date = (SELECT
						date
					FROM sales
					ORDER BY date DESC
					LIMIT 1)
	) t5
GROUP BY 1;
/*
The results indicate that an amount of $7,841,700.81 is currently tied up at inventory
*/
--------------------------------------------------------------------------------------

-- Question 2
-- B. How long will it last?

/*
To know how long the toys at the inventory will last,
one may need to know the average daily sales made from 
the toys category, and the amount of money tied up at
the toys inventory. A simple ratio between the two will
indicate how long the toys will last at the inventory.
Thus Money_tied_up_at_inventory/Average_daily_sales_from_toys.
*/

/*
The amount of money tied up at the toys inventory was already
calculated. Reference to code above. 
Now, to know the average daily sales made from toys, the below 
codes were used.
*/

SELECT 
	p_category,
	AVG(sum_sales_toys) AS avg_toys_sales_per_day
FROM 
	(SELECT
		p_category,
		sales_date,
		SUM(toys_sales) AS sum_sales_toys
	FROM 
		(SELECT
			p.product_category AS p_category,
			p.product_name AS p_name,
			s.date AS sales_date,
			(p.product_price * s.units) AS toys_sales
		FROM products p
		JOIN sales s
		ON s.product_id = p.product_id
		WHERE p.product_category = 'Toys')t3 -- Toys sales table
	GROUP BY 1,2) t4 -- Total sales made from toys per day.
GROUP BY p_category; -- Average daily sales of toys.

-- Dividing the two results, the below codes were used.

WITH t6 AS (
SELECT
	p_category,
	SUM(potential_toys_revenue) AS money_tied_at_toys_inventory
FROM
	(SELECT
		p.product_category AS p_category,
		p.product_name,
		p.product_price,
		i.stock_on_hand,
		s.date,
		p.product_price * i.stock_on_hand AS potential_toys_revenue
	FROM products p
	JOIN inventory i
	ON i.product_id = p.product_id
	JOIN sales s
	ON s.product_id = p.product_id
	WHERE p.product_category = 'Toys' AND
		  s.date = (SELECT
						date
					FROM sales
					ORDER BY date DESC
					LIMIT 1)
	) t5
GROUP BY 1), -- Current money tied up at toys inventory.


t7 AS ( 
SELECT 
	p_category,
	AVG(sum_sales_toys) AS avg_toys_sales_per_day
FROM 
	(SELECT
		p_category,
		sales_date,
		SUM(toys_sales) AS sum_sales_toys
	FROM 
		(SELECT
			p.product_category AS p_category,
			p.product_name AS p_name,
			s.date AS sales_date,
			(p.product_price * s.units) AS toys_sales
		FROM products p
		JOIN sales s
		ON s.product_id = p.product_id
		WHERE p.product_category = 'Toys')t3 
	GROUP BY 1,2) t4 
GROUP BY p_category) -- Average daily sales of toys.
	
-- Final Table
SELECT 
	t6.p_category,
	t6.money_tied_at_toys_inventory,
	t7.avg_toys_sales_per_day,
	(t6.money_tied_at_toys_inventory/t7.avg_toys_sales_per_day) AS days_toys_will_last_at_inventory
FROM t6
JOIN t7
ON t7.p_category = t6.p_category; --Query to get how long the toys will be at the inventory

/*
The insights gained can help Maven Toys optimize its inventory management strategies. 
Since the current inventory is expected to last for an extended period, 
the company might consider adjusting procurement or marketing strategies to maintain an optimal balance.
*/

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------

-- Question 3
-- Are sales being lost with out_of_stocks product at certain location?

-- Answer
/*
To answer, one has to find the average daily sales made by out of stock 
products at certain locations. This would represent the amount of 
money being lost by these products per day as long as they are out of stocks.
*/
/*
The query below was used to run the sales table for most recent out of stock 
products at Maven Toys.
*/
SELECT 
	str.store_id AS store_id,
	str.store_name AS store_name,
	p.product_category AS product_category,
	p.product_name AS product_name,
	str.store_location AS store_location,
	s.date AS most_recent_sales_date,
	i.stock_on_hand AS stock_on_hand,
	(p.product_price * s.units) AS os_sales
		
FROM products p
JOIN sales s
ON s.product_id = p.product_id
JOIN inventory i
ON i.product_id = p.product_id
JOIN stores str
ON i.store_id = str.store_id
WHERE i.stock_on_hand = 0 AND
	 s.date = (SELECT
					date
			   FROM sales
			   ORDER BY date DESC
			   LIMIT 1) --- current sales date
ORDER BY store_id; --- Sales table of recent out of stock products at certain locations.

/*
The historical sales data for the current out of stock product was pulled out using 
the query below. 
*/
SELECT DISTINCT
			table1.store_id,
			table1.store_name,
			table1.product_category AS product_category,
			table1.product_name,
			table1.store_location AS store_location,
			table1.stock_on_hand,
			table1.most_recent_sales_date,
			s.date AS historical_sales_date,
			table1.os_sales AS os_sales
FROM (
	
		SELECT 
			str.store_id AS store_id,
			str.store_name AS store_name,
			p.product_category AS product_category,
			p.product_name AS product_name,
			str.store_location AS store_location,
			s.date AS most_recent_sales_date,
			i.stock_on_hand AS stock_on_hand,
			(p.product_price * s.units) AS os_sales
		
		FROM products p
		JOIN sales s
		ON s.product_id = p.product_id
		JOIN inventory i
  		ON i.product_id = p.product_id
		JOIN stores str
		ON i.store_id = str.store_id
		WHERE i.stock_on_hand = 0 AND
		s.date =  (SELECT
					date
			  	  FROM sales
			  	  ORDER BY date DESC
			  	  LIMIT 1)--- current sales date
		ORDER BY store_id)table1--- Sales table of recent out of stock products at certain locations.
JOIN sales s
ON	table1.store_id = s.store_id	
ORDER BY historical_sales_date DESC; -- historical sales data/table for the current out of stock product

/*
Next was to pull out the sum of sales for these products per day. The query below was used. 
*/


SELECT
	product_category,
	store_location,
	historical_sales_date,
	SUM(os_sales) sum_os_sales
FROM  (

	SELECT DISTINCT
			table1.store_id,
			table1.store_name,
			table1.product_category AS product_category,
			table1.product_name,
			table1.store_location AS store_location,
			table1.stock_on_hand,
			table1.most_recent_sales_date,
			s.date AS historical_sales_date,
			table1.os_sales AS os_sales
	FROM (
	
		SELECT 
			str.store_id AS store_id,
			str.store_name AS store_name,
			p.product_category AS product_category,
			p.product_name AS product_name,
			str.store_location AS store_location,
			s.date AS most_recent_sales_date,
			i.stock_on_hand AS stock_on_hand,
			(p.product_price * s.units) AS os_sales
		
		FROM products p
		JOIN sales s
		ON s.product_id = p.product_id
		JOIN inventory i
  		ON i.product_id = p.product_id
		JOIN stores str
		ON i.store_id = str.store_id
		WHERE i.stock_on_hand = 0 AND
		s.date =  (SELECT
					date
			  	  FROM sales
			  	  ORDER BY date DESC
			  	  LIMIT 1)--- current sales date
		ORDER BY store_id)table1--- Sales table of recent out of stock products at certain locations.
	JOIN sales s
	ON	table1.store_id = s.store_id	
	ORDER BY historical_sales_date DESC  -- historical sales data/table for the current out of stock product
) table2
GROUP BY 1,2,3; --sum of sales for these products per day

/*
Finally, the information on the average daily sales at certain locations for these products 
were pulled out using the codes below. 
*/

WITH cte AS (
SELECT
	product_category,
	store_location,
	historical_sales_date,
	SUM(os_sales) sum_os_sales
FROM  (

	SELECT DISTINCT
			table1.store_id,
			table1.store_name,
			table1.product_category AS product_category,
			table1.product_name,
			table1.store_location AS store_location,
			table1.stock_on_hand,
			table1.most_recent_sales_date,
			s.date AS historical_sales_date,
			table1.os_sales AS os_sales
	FROM (
	
		SELECT 
			str.store_id AS store_id,
			str.store_name AS store_name,
			p.product_category AS product_category,
			p.product_name AS product_name,
			str.store_location AS store_location,
			s.date AS most_recent_sales_date,
			i.stock_on_hand AS stock_on_hand,
			(p.product_price * s.units) AS os_sales
		
		FROM products p
		JOIN sales s
		ON s.product_id = p.product_id
		JOIN inventory i
  		ON i.product_id = p.product_id
		JOIN stores str
		ON i.store_id = str.store_id
		WHERE i.stock_on_hand = 0 AND
		s.date =  (SELECT
					date
			  	  FROM sales
			  	  ORDER BY date DESC
			  	  LIMIT 1)--- current sales date
		ORDER BY store_id)table1--- Sales table of recent out of stock products at certain locations.
	JOIN sales s
	ON	table1.store_id = s.store_id	
	ORDER BY historical_sales_date DESC -- historical sales data/table for the current out of stock product
) table2
GROUP BY 1,2,3 ) --sum of sales for these products per day.

SELECT
	product_category,
	store_location,
	AVG(sum_os_sales) AS avg_sales_per_day
FROM cte
GROUP BY 1,2; -- average daily sales at certain locations for these products

/*
The average daily sales at certain locations for out_of_stocks products
is represented in the table when the above query is run.
This table shows the amount of money lost daily by Maven toys for 
these products as long as they remain out of stock.
*/

/*
The analysis provides valuable insights into the financial impact of out-of-stock situations. 
Maven Toys can use this information to prioritize inventory management and reduce the occurrence of stockouts.
Understanding the average daily sales of out-of-stock products at specific locations allows the company 
to quantify the revenue loss associated with inventory gaps. 
Maven Toys can implement more robust inventory forecasting and replenishment strategies to minimize stockouts.
*/
