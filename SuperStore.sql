use project;
CREATE TABLE superstore (
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(20) NOT NULL,
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(20),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Postal_Code VARCHAR(20),
    Region VARCHAR(50),
    Product_ID VARCHAR(20),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(150),
    Sales DECIMAL(10,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(10,2)
);

DESCRIBE superstore;

select * from superstore;

UPDATE superstore SET `order date` = STR_TO_DATE(`order date`, '%m/%d/%Y');
alter table superstore modify `order date` date;

update superstore set `ship date` = str_to_date(`ship date`, "%m/%d/%Y");
alter table superstore modify `ship date` date;

DESCRIBE superstore;

-- Level 1 — Basic Data Exploration
-- ----------------------------------------------------------
-- 1. Total number of orders 
select count(`order id`) as 'Total_Orders' from superstore;

-- ----------------------------------------------------------
-- 2. Find the total sales of the company. 
select round(sum(`Sales`),2) as "Total Sales" From superstore;

-- ----------------------------------------------------------
-- 3. Find the total profit generated. 
select round(sum(`Profit`),2) as "Total Profit" from superstore;

-- ----------------------------------------------------------
-- 4. List the top 10 products with highest sales. 
select `product name`,round(sum(`sales`),2) as "Top 10 Product Sales" from superstore group by `product name` order by round(sum(`sales`),2) desc limit 10;

-- ----------------------------------------------------------
-- 5. Find the number of unique customers.
select count(distinct(`customer name`)) As "Unique Customer Count" from superstore;

-- ----------------------------------------------------------
-- 6. Find the total sales per region.
select `Region`,round(sum(`sales`),2) as "Total Sales by Region" from superstore group by `region`;

-- ----------------------------------------------------------
-- 7. Find the total orders per state.
select `state`,count(`order id`) as "Total Order by State" from superstore group by `state`;

-- ----------------------------------------------------------
-- 8. Find the most sold category.
select `Category`, count(`order id`) as "Order Count" from superstore group by `Category` order by count(`order id`) desc limit 1;
-- ----------------------------------------------------------


-- Level 2 — Business Analysis
-- ----------------------------------------------------------
-- 9. Which region generates the highest profit?
select `Region`, round(sum(`profit`),2) as "Highest Profit By Region" from superstore group by `Region` order by round(sum(`profit`)) desc limit 1;

-- ----------------------------------------------------------
-- 10. Which state has the highest sales?
select `State`, round(sum(`sales`),2) as "Highest Sales By State" from superstore group by `State` order by round(sum(`sales`),2) desc limit 1;

-- ----------------------------------------------------------
-- 11. Find the top 5 customers by total purchase amount.
select `Customer Id`,`Customer Name`,round(sum(`sales`),2) as "Top 5 Customer" from superstore group by `Customer Id`,`Customer Name` order by round(sum(`sales`),2) desc limit 5;

-- ----------------------------------------------------------
-- 12. Which category generates the highest revenue?
select `Category`,round(sum(`sales`),2) as "Highest Revenue in Category" from superstore group by `Category` order by round(sum(`sales`),2) desc limit 5;

-- ----------------------------------------------------------
-- 13. Find monthly sales trend.
select year(`order date`),month(`order date`), round(sum(`sales`),2) as "Yearly Sales Trend" from superstore group by year(`order date`),month(`order date`) order by year(`order date`),month(`order date`) asc;

-- ----------------------------------------------------------
-- 14. Find yearly profit trend.
select year(`order date`), round(sum(`profit`),2) as "Yearly Profit Trend" from superstore group by year(`order date`) order by year(`order date`) asc;

-- ----------------------------------------------------------
-- 15. Which ship mode is used the most?
select `ship mode`,count(`Ship mode`) as "Most used ship mode" from superstore group by `ship mode` order by count(`Ship mode`) desc limit 1;

-- ----------------------------------------------------------
-- 16. Which segment contributes the most sales?
select `Segment`,round(sum(`sales`),2) as "Most Contributed Segment" from superstore group by `Segment` order by sum(`sales`) desc limit 1;

-- ----------------------------------------------------------

-- Level 3 — Advanced SQL
-- ----------------------------------------------------------
-- 17. Find the top product in each category.
select Category,`Product Name`,Total_Sales from 
(select Category,`Product Name`,round(sum(`sales`),2) as Total_Sales,
row_number() over (partition by Category order by sum(`sales`) desc) as "rn" from superstore group by Category, `Product Name`)
t where rn = 1;

-- ----------------------------------------------------------
-- 18. Find the top 3 products in each region.
select Region,`Product Name`,Total_sales from 
(select Region,`Product Name`,round(sum(sales)) as Total_sales,
row_number() over (partition by Region order by sum(sales) desc) as rn from superstore group by Region,`Product Name`) t
where rn<4;

-- ----------------------------------------------------------
-- 19. Rank customers based on total spending.
select `Customer Name`, `Customer ID`,Round(Sum(sales),2) as T_Sales, rank() over (order by Sum(sales) desc) as "Rank"
from superstore group by `Customer Name`,`Customer ID` order by sum(sales) desc;

-- ----------------------------------------------------------
-- 20. Find orders where discount is high but profit is negative.
select `Order ID`, discount, profit from superstore where profit < 0 AND Discount > 0.3
ORDER BY Discount DESC;

-- ----------------------------------------------------------
-- 21. Find average order value per customer.
SELECT `Customer ID`,
       `Customer Name`,
       ROUND(AVG(order_total),2) AS Avg_Order_Value
FROM (
        SELECT `Customer ID`,
               `Customer Name`,
               `Order ID`,
               SUM(Sales) AS order_total
        FROM superstore
        GROUP BY `Customer ID`,`Customer Name`,`Order ID`
     ) t
GROUP BY `Customer ID`,`Customer Name`;


-- ----------------------------------------------------------
-- 22. Find customers who ordered more than 10 times.
select `Customer ID`, `Customer Name`, Count(`Customer ID`) as Count_of_Order from superstore 
group by `Customer ID`, `Customer Name` having Count(`Customer ID`)>10;

-- ----------------------------------------------------------
-- 23. Find products that never made profit.
select `Product ID`,`Product Name`, round(sum(profit),2) from superstore
group by `Product ID`,`Product Name` having sum(profit) <= 0;
-- ----------------------------------------------------------



-- Level 4 — Real Business Questions
-- ----------------------------------------------------------
-- 24. Which city is the most profitable?
select city, round(sum(profit)) as "Prodfitable City" from superstore group by city order by sum(profit) desc limit 1;

-- ----------------------------------------------------------
-- 25. Which sub-category gives highest profit margin?
select `sub-category`, round((sum(profit)/sum(sales)),2) as "Prodfitable Sub Category" from superstore group by `sub-category` 
order by (sum(profit)/sum(sales)) desc limit 1;

-- ----------------------------------------------------------
-- 26. Find top performing month in sales.
select month(`order date`), round(sum(sales),2) as "Top perfoming Month's Sales" from superstore
group by month(`order date`) order by sum(sales) desc limit 1;

-- ----------------------------------------------------------
-- 27. Find worst performing product.
select `Product Name`, round(sum(profit),2) as Total_Profit
from superstore
group by `Product Name`
order by Total_Profit asc
limit 1;

-- ----------------------------------------------------------
-- 28. Which region gives highest average order value?
select Region, round(avg(Order_Value),2) as "Average Order Value"
from
(
    select Region, `Order ID`, sum(sales) as Order_Value
    from superstore
    group by Region, `Order ID`
) t
group by Region order by avg(Order_Value) desc limit 1;

-- ----------------------------------------------------------
-- 29. Identify loss making categories.
select Category, round(sum(profit),2) as "Worst Perfoming Product" from superstore 
group by category having sum(profit)<0;

-- ----------------------------------------------------------
-- 30. Find top 5 cities contributing to total revenue.
Select City, round(sum(sales),2) from superstore group by city order by sum(sales) desc limit 5;

-- ----------------------------------------------------------




-- Level 5 — Advanced (Recruiter Level)
-- ----------------------------------------------------------

-- 31. Rank products by sales within each category.
select Category,`Product Name`,round(Sum(Sales),2) as Sales,rank() over (partition by category order by sum(Sales) desc) as Product_Rank from superstore
group by Category,`Product Name`;

-- ----------------------------------------------------------
-- 32. Calculate running total of sales per month.
SELECT 
    YEAR(`Order Date`) AS Year,
    MONTH(`Order Date`) AS Month,
    round(SUM(Sales),2) AS Monthly_Sales,
    round(SUM(SUM(Sales)) OVER (
        PARTITION BY YEAR(`Order Date`)
        ORDER BY MONTH(`Order Date`)
    ),2) AS Running_Total
FROM superstore
GROUP BY YEAR(`Order Date`), MONTH(`Order Date`)
ORDER BY Year, Month;

-- ----------------------------------------------------------
-- 33. Find top 10% customers by revenue.
SELECT `Customer ID`, `Customer Name`, Total_Sales
FROM (
    SELECT 
        `Customer ID`,
        `Customer Name`,
        ROUND(SUM(Sales),2) AS Total_Sales,
        NTILE(10) OVER (ORDER BY SUM(Sales) DESC) AS decile
    FROM superstore
    GROUP BY `Customer ID`, `Customer Name`
) t
WHERE decile = 1
ORDER BY Total_Sales DESC;

-- ----------------------------------------------------------
-- 34. Find sales contribution percentage by category.
select category, round((sum(sales)/(select sum(sales) from superstore)*100),2) as percent from superstore
group by category;

select category, round(((Sales/T_Sales)*100),2) as Percentage from 
(select category, sum(sales) as Sales from superstore group by category) t
CROSS JOIN
(select sum(sales) as T_Sales from superstore) f
order by Sales;
