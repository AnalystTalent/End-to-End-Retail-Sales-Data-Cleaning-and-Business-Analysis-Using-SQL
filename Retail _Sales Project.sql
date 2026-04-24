-- Exploration of data
SELECT * 
FROM Superstore

--Total number of rows (9993)
  SELECT 
  COUNT (*)
  FROM Superstore

--Creating a new dataset for cleaning
SELECT *
INTO Fresh_Superstore
FROM Superstore;

--Total number of rows 
  SELECT 
  COUNT (*)
  FROM Fresh_Superstore


--duplicate orders (keep latest record)
WITH Dupli AS(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY Order_ID, Customer_ID, Postal_Code, Product_ID,Product_Name,Quantity,Profit ORDER BY Order_Date DESC
 ) AS dup
FROM Fresh_Superstore
)
SELECT * 
FROM Dupli
WHERE dup > 1


--Validating Duplicate
SELECT *
FROM Fresh_Superstore
WHERE Customer_Name = 'Laurel Beltran' AND Order_ID = 'US-2014-150119'

-- Deleting Duplicates
WITH Dupli AS(
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY Order_ID, Customer_ID, Postal_Code, Product_ID,Product_Name,Quantity,Profit ORDER BY Order_Date DESC
 ) AS dup
FROM Fresh_Superstore
)
DELETE 
FROM Dupli
WHERE dup > 1


-- Checking errors and removing spaces
SELECT  DISTINCT (TRIM(Order_ID))
FROM Fresh_Superstore
SELECT  DISTINCT (TRIM(Segment))
FROM Fresh_Superstore

SELECT  DISTINCT (TRIM(Customer_ID))
FROM Fresh_Superstore

UPDATE Fresh_Superstore
SET Customer_Name = UPPER(TRIM(Customer_Name)),
  Product_Name = UPPER(TRIM(Product_Name));

SELECT * 
FROM Fresh_Superstore

-- Check missing values
SELECT * 
FROM Fresh_Superstore
WHERE Customer_ID IS NULL

-- Replace missing values
UPDATE Fresh_Superstore
SET Customer_Name = 'Unknown'
WHERE Customer_Name IS NULL

-- Total number of Customers 
  SELECT 
  COUNT (DISTINCT (Customer_Name))
 FROM Fresh_Superstore

  -- Check invalid sales or profit
SELECT *
FROM Fresh_Superstore
WHERE Sales < 0
   OR Profit < -10000;

--Final Cleaned Data for analysis
 SELECT *
INTO Final_Superstore
FROM Fresh_Superstore
WHERE Sales IS NOT NULL
 AND Profit IS NOT NULL;

--total sales, total profit, avg discount
select 
 sum(Sales) AS Total_Sales,
 sum(Profit) AS Total_Profit,
 avg(discount) AS Avg_Discount
 from Final_Superstore;

 --Category or sub category with the highest sales or profit
 select 
  Category,
 Sub_Category
from Final_Superstore
where Profit > 8399;

 --Top 10 customers by total sales
 Select 
 Customer_Name,
 Sum(Sales) AS Total_sales
 FROM Final_Superstore
 Group by Customer_Name
 Order by Total_sales DESC;

 --Product resulted in higest loss 
 select 
  Category,
  Sub_Category,
 Profit
 from Final_Superstore
where Profit < -1
 order by Profit asc;

 --which region or state is the most profitable
SELECT 
   Region,
   SUM(Profit) AS Total_Profit
FROM Final_Superstore
GROUP BY Region
ORDER BY Total_Profit DESC;

 -- How many repeat customers 
 Select 
 Customer_Name,
 COUNT (DISTINCT Customer_ID) AS total_id
 from Final_Superstore 
 Group by Customer_Name 
 ORDER BY total_id

 --Customer segment with the most profit
 select 
  Segment,
  Sum (Profit) AS Total_Profit
  from Final_Superstore
  group by Segment
  order by Total_Profit;

  -- Average delivery time 
  Select 
  AVG(DATEDIFF(day,Order_Date,Ship_Date)) AS avg_delivery_date
  from Final_Superstore;


  --Average quantity ordered per product or category

select 
Product_Name,
Category,
Sub_Category,
AVG(Quantity) AS Avg_Quantity
from Final_Superstore
group by Product_Name, Category,Sub_Category
order by Avg_Quantity desc

--low Quantity of products sold(slow moving products)
select 
Product_Name,
Category,
Sub_Category,
Count(Quantity) AS act_Quantity
from Final_Superstore
group by Product_Name, Category,Sub_Category
order by act_Quantity asc

--Heavily discounted products
select 
Product_Name,
Category,
Sub_Category,
max(Discount) AS heavily_Dis
from Final_Superstore
group by Product_Name, Category,Sub_Category
order by heavily_Dis desc


-- Cities with highest total sales but lowest Average Profit
select 
 TOP 5 City,
   Sum(Sales) as total_sales,
  avg(Profit) as avg_profit
 from Final_Superstore
group by City
order by total_sales desc ,avg_profit asc

--Compare sales performance yearly 
select 
 sum(Sales) as total_sales,
 YEAR(Order_Date) as yearly
from Final_Superstore
group by YEAR(Order_Date)
order by total_sales;