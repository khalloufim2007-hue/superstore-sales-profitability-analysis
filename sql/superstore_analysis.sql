-- ============================================
-- SUPERSTORE SALES ANALYSIS
-- Data Analyst Portfolio Project
-- Database: MySQL
-- ============================================

USE superstore;


-- ============================================
-- 1. DATA QUALITY CHECK
-- ============================================

-- Total number of rows
SELECT COUNT(*) AS total_rows
FROM `superstore.csv 1`;

-- Missing values in important columns
SELECT
    SUM(`Order ID` IS NULL) AS missing_order_id,
    SUM(`Customer ID` IS NULL) AS missing_customer_id,
    SUM(Sales IS NULL) AS missing_sales,
    SUM(Profit IS NULL) AS missing_profit
FROM `superstore.csv 1`;

-- Duplicate Row IDs
SELECT
    `Row ID`,
    COUNT(*) AS duplicate_count
FROM `superstore.csv 1`
GROUP BY `Row ID`
HAVING COUNT(*) > 1;


-- ============================================
-- 2. OVERALL BUSINESS KPIs
-- ============================================

SELECT
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT `Customer ID`) AS total_customers,
    CONCAT('$', ROUND(SUM(Sales) / 1000000, 2), 'M') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`;


-- ============================================
-- 3. YEARLY SALES & PROFIT
-- ============================================

SELECT
    YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS order_year,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y'))
ORDER BY order_year;


-- ============================================
-- 4. YEAR-OVER-YEAR GROWTH
-- ============================================

WITH yearly AS (
    SELECT
        YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y')) AS order_year,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit
    FROM `superstore.csv 1`
    GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%d/%m/%Y'))
),
growth AS (
    SELECT
        order_year,
        total_sales,
        total_profit,
        LAG(total_sales) OVER (ORDER BY order_year) AS previous_sales,
        LAG(total_profit) OVER (ORDER BY order_year) AS previous_profit
    FROM yearly
)
SELECT
    order_year,
    CONCAT('$', ROUND(total_sales / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(total_profit / 1000, 1), 'K') AS total_profit,
    CASE
        WHEN previous_sales IS NULL THEN NULL
        ELSE CONCAT(
            ROUND(
                (total_sales - previous_sales)
                / previous_sales * 100,
                2
            ),
            '%'
        )
    END AS sales_growth,
    CASE
        WHEN previous_profit IS NULL THEN NULL
        ELSE CONCAT(
            ROUND(
                (total_profit - previous_profit)
                / previous_profit * 100,
                2
            ),
            '%'
        )
    END AS profit_growth
FROM growth
ORDER BY order_year;


-- ============================================
-- 5. CATEGORY PERFORMANCE
-- ============================================

SELECT
    Category,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY Category
ORDER BY SUM(Profit) DESC;


-- ============================================
-- 6. SUB-CATEGORY PERFORMANCE
-- ============================================

SELECT
    `Sub-Category`,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY `Sub-Category`
ORDER BY SUM(Profit) DESC;


-- ============================================
-- 7. LOSS-MAKING SUB-CATEGORIES
-- ============================================

SELECT
    `Sub-Category`,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY SUM(Profit) ASC;


-- ============================================
-- 8. DISCOUNT & PROFITABILITY ANALYSIS
-- ============================================

SELECT
    Discount,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY Discount
ORDER BY Discount;


-- ============================================
-- 9. TABLES & DISCOUNT
-- ============================================

SELECT
    Discount,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
WHERE `Sub-Category` = 'Tables'
GROUP BY Discount
ORDER BY Discount;


-- ============================================
-- 10. TOP 10 PRODUCTS BY PROFIT
-- ============================================

SELECT
    `Product Name`,
    Category,
    `Sub-Category`,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit
FROM `superstore.csv 1`
GROUP BY
    `Product Name`,
    Category,
    `Sub-Category`
ORDER BY SUM(Profit) DESC
LIMIT 10;


-- ============================================
-- 11. TOP 10 LOSS-MAKING PRODUCTS
-- ============================================

SELECT
    `Product Name`,
    Category,
    `Sub-Category`,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit
FROM `superstore.csv 1`
GROUP BY
    `Product Name`,
    Category,
    `Sub-Category`
HAVING SUM(Profit) < 0
ORDER BY SUM(Profit) ASC
LIMIT 10;


-- ============================================
-- 12. TOP 10 CUSTOMERS BY PROFIT
-- ============================================

SELECT
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit
FROM `superstore.csv 1`
GROUP BY `Customer Name`
ORDER BY SUM(Profit) DESC
LIMIT 10;


-- ============================================
-- 13. REGIONAL PERFORMANCE
-- ============================================

SELECT
    Region,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY Region
ORDER BY SUM(Profit) DESC;


-- ============================================
-- 14. REGION + CATEGORY PERFORMANCE
-- ============================================

SELECT
    Region,
    Category,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY Region, Category
ORDER BY Region, SUM(Profit) DESC;


-- ============================================
-- 15. CUSTOMER SEGMENT PERFORMANCE
-- ============================================

SELECT
    Segment,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    COUNT(DISTINCT `Customer ID`) AS total_customers,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY Segment
ORDER BY SUM(Profit) DESC;


-- ============================================
-- 16. SEGMENT + CATEGORY PERFORMANCE
-- ============================================

SELECT
    Segment,
    Category,
    CONCAT('$', ROUND(SUM(Sales) / 1000, 1), 'K') AS total_sales,
    CONCAT('$', ROUND(SUM(Profit) / 1000, 1), 'K') AS total_profit,
    CONCAT(
        ROUND(SUM(Profit) / SUM(Sales) * 100, 2),
        '%'
    ) AS profit_margin
FROM `superstore.csv 1`
GROUP BY Segment, Category
ORDER BY Segment, SUM(Profit) DESC;


-- ============================================
-- 17. ORDER ECONOMICS
-- ============================================

SELECT
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(
        SUM(Sales) / COUNT(DISTINCT `Order ID`),
        2
    ) AS sales_per_order,
    ROUND(
        SUM(Profit) / COUNT(DISTINCT `Order ID`),
        2
    ) AS profit_per_order
FROM `superstore.csv 1`;


-- ============================================
-- 18. TOP 3 PRODUCTS BY CATEGORY
-- Advanced SQL: CTE + RANK()
-- ============================================

WITH product_profit AS (
    SELECT
        `Product Name`,
        Category,
        SUM(Profit) AS total_profit
    FROM `superstore.csv 1`
    GROUP BY
        `Product Name`,
        Category
),
ranked_products AS (
    SELECT
        `Product Name`,
        Category,
        total_profit,
        RANK() OVER (
            PARTITION BY Category
            ORDER BY total_profit DESC
        ) AS product_rank
    FROM product_profit
)
SELECT
    Category,
    product_rank,
    `Product Name`,
    CONCAT('$', ROUND(total_profit / 1000, 1), 'K') AS total_profit
FROM ranked_products
WHERE product_rank <= 3
ORDER BY Category, product_rank;