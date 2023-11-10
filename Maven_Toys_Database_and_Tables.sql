--Creating Database for Maven Toys.

CREATE DATABASE maven_toys; -- Database name is maven_toys.

--Creating the sales, products, inventory and stores tables in database.

CREATE TABLE IF NOT EXISTS sales ( 
	Sale_ID SERIAL PRIMARY KEY, -- sale_id as primary key
	Date DATE,	
	Store_ID INTEGER, -- store_id as foreign key
	Product_ID INTEGER,
	Units INTEGER ); -- sales table with five columns namely, sales_id, date, store_id, product_id, and units.

CREATE TABLE IF NOT EXISTS products (
	Product_ID SERIAL PRIMARY KEY, -- product_id as primary key
	Product_Name VARCHAR (300),
	Product_Category VARCHAR (300),
	Product_Cost FLOAT,
	Product_Price FLOAT ); -- products table with five columns namely, product_id, product_name, product_category, product_cost, product_price

CREATE TABLE IF NOT EXISTS inventory (
	Store_ID INTEGER,  -- store_id as foreign key
	Product_ID INTEGER,  -- product_id as foreign key
	Stock_On_Hand INTEGER ); -- inventory table with three columns namely store_id, product_id, and stock_on_hand

CREATE TABLE IF NOT EXISTS stores (
	Store_ID SERIAL PRIMARY KEY,   -- Store_id as primary key
	Store_Name VARCHAR (300),     
	Store_City VARCHAR (300),
	Store_Location VARCHAR (300),
	Store_Open_Date DATE ); -- stores table with five columns namely store_id, store_name, store_city, store_location, store_open_date

--Upload data from tables into database
/* Opening the PSQL Tool, the various csv files containing the data for each table
in the maven_toys database were imported into the database using the following codes
\COPY sales FROM 'FILE PATH OF SALES SPECIFIED' DELIMITER ',' CSV HEADER
\COPY products FROM 'FILE PATH OF PRODUCTS SPECIFIED' DELIMITER ',' CSV HEADER
\COPY inventory FROM 'FILE PATH OF INVENTORY SPECIFIED' DELIMITER ',' CSV HEADER
\COPY stores FROM 'FILE PATH OF STORES SPECIFIED' DELIMITER ',' CSV HEADER
*/


-- The following queries were run to observe the data in the tables created
SELECT * FROM sales;
SELECT * FROM products;
SELECT * FROM inventory;
SELECT * FROM stores;
