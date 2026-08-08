--to check metadata about the tables and columns
SELECT * FROM INFORMATION_SCHEMA.TABLES;

SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

--explore countries our customers come from

 SELECT DISTINCT country FROM gold.dim_customers;

 --explore categories 
 SELECT DISTINCT category,subcategory,product_name FROM gold.dim_products;

 --first and last order date
SELECT order_date FROM gold.fact_sales;
SELECT MIN(order_date) AS first_order, MAX(order_date) AS latest_order  FROM gold.fact_sales;

--How many years of sales are available
SELECT DATEDIFF(YEAR,MIN(order_date),MAX(order_date)) AS number_of_years FROM gold.fact_sales;

--youngest and oldest customers

SELECT 
MIN(birthdate) AS oldest_customer,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS Age,
MAX(birthdate) AS youngest_customer,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS Age
FROM gold.dim_customers;

--total sales
SELECT SUM(sales_amount) as TOTAL_SALES FROM gold.fact_sales;

--total number of items sold
SELECT SUM(quantity) AS Total_items_sold FROM gold.fact_sales;

--average sellling price
SELECT AVG(price) AS avg_selling_price FROM gold.fact_sales;

--total number of orders
SELECT COUNT(order_number) AS Total_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT order_number) AS Total_orders FROM gold.fact_sales; -- -> removing duplictes

-- total number of products
SELECT COUNT(product_key) AS total_products FROM gold.dim_products; 

--total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

--total number of customers who placed an order
SELECT COUNT(DISTINCT customer_key) AS ordered_customers FROM gold.fact_sales;

--GENERAL REPORT
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) as TOTAL_SALES FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS Total_items_sold FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name, AVG(price) AS avg_selling_price FROM gold.fact_sales
UNION ALL
SELECT 'Total No. of Orders' AS measure_name, COUNT(DISTINCT order_number) AS Total_orders FROM gold.fact_sales
UNION ALL
SELECT 'Total No. of Products' AS measure_name,  COUNT(product_key) AS total_products FROM gold.dim_products
UNION ALL
SELECT 'Total No. of Customers' AS measure_name, COUNT(customer_key) AS total_customers FROM gold.dim_customers
UNION ALL
SELECT 'Total No. of Orderd Customers' AS measure_name, COUNT(DISTINCT customer_key) AS ordered_customers FROM gold.fact_sales;

-- total customers by countries
SELECT country,COUNT(customer_key) AS Total_Customers FROM gold.dim_customers GROUP BY country ORDER BY Total_Customers DESC;

-- total customers by gender
SELECT gender,COUNT(customer_key) AS Total_Customers FROM gold.dim_customers GROUP BY gender;

-- total products by category
SELECT category, COUNT(product_key) AS Total_Products FROM gold.dim_products GROUP BY category; 

-- avg cost in each category
SELECT category, AVG(cost) AS Average_Costs FROM gold.dim_products GROUP BY category;

-- total revenue by category
SELECT d.category, SUM(f.sales_amount) AS Total_Revenue
FROM gold.dim_products d
LEFT JOIN gold.fact_sales f
ON d.product_key=f.product_key
GROUP BY category
ORDER BY Total_Revenue DESC;

-- total revenue by each customer
SELECT c.customer_id, c.first_name,c.last_name,SUM(f.sales_amount) AS Total_Revenue FROM gold.dim_customers c LEFT JOIN gold.fact_sales f ON c.customer_key=f.customer_key GROUP BY c.customer_id,c.first_name,c.last_name ORDER BY Total_Revenue DESC;

--total distributoion of items (quantity) across the countries
SELECT c.country,SUM(f.quantity) as total_items FROM gold.dim_customers c LEFT JOIN gold.fact_sales f ON c.customer_key=f.customer_key GROUP BY c.country ORDER BY  total_items DESC;

--top 10 highest revenue generating products
SELECT * FROM (
SELECT c.customer_key,
c.first_name,
c.last_name,
SUM(f.sales_amount) AS total_revenue,
ROW_NUMBER() OVER(ORDER BY SUM(f.sales_amount) DESC) AS ranked
FROM gold.dim_customers c
LEFT JOIN gold.fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name)t
WHERE ranked <=10;

--bottom 3 customers with fewest orders placed
SELECT TOP 3
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.dim_customers c
LEFT JOIN   gold.fact_sales f
ON c.customer_key = f.customer_key
GROUP BY c.customer_key,
c.first_name,
c.last_name
ORDER BY total_orders;
