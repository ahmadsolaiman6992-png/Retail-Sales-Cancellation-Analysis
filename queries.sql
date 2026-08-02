/* =========================================
   DATA EXPLORATION
========================================= */

/* Top Countries by Revenue */

SELECT dim_customers.Country , count(fact_sales.InvoiceNo) as country_count,sum(fact_sales.Quantity*fact_sales.UnitPrice) as income
FROM dim_customers join fact_sales
on dim_customers.CustomerID=fact_sales.CustomerID
GROUP by dim_customers.Country
order by income desc
LIMIT 10;
/* Top Products by Revenue */

SELECT dim_products.StockCode,dim_products.Description,sum(fact_sales.Quantity*fact_sales.UnitPrice) as income  
from dim_products join fact_sales
on dim_products.StockCode=fact_sales.StockCode
GROUP by dim_products.StockCode
order by income DESC
LIMIT 10 ;

/* sale trends */
SELECT strftime('%Y-%m',InvoiceDate) as new_date,sum(fact_sales.Quantity*fact_sales.UnitPrice) as income
 from fact_sales
 GROUP by new_date
 ORDER by new_date;
/* Top countries by average of Revenue*/
SELECT dim_customers.Country , avg(fact_sales.Quantity*fact_sales.UnitPrice) as income_mean
FROM dim_customers join fact_sales
on dim_customers.CustomerID=fact_sales.CustomerID
GROUP by dim_customers.Country
order by income_mean desc
LIMIT 10;
/*- Average Order Value by Country */
with income_invoice as (
SELECT InvoiceNo,CustomerID,sum(Quantity*UnitPrice)as income_invoice
from fact_sales
GROUP by InvoiceNo)
SELECT Country, avg(income_invoice) as average_by_invoice
FROM income_invoice JOIN dim_customers
on income_invoice.CustomerID=dim_customers.CustomerID
GROUP by Country
order by average_by_invoice desc

/*- Revenue Distribution Across Countries*/
WITH country_revenue AS (
    SELECT
        Country,
        SUM(Quantity * UnitPrice) AS revenue
    FROM dim_customers
    JOIN fact_sales
        ON dim_customers.CustomerID = fact_sales.CustomerID
    GROUP BY Country
)

SELECT
    Country,
    revenue,
    SUM(revenue) OVER () AS total_revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue,
    ROUND(
        SUM(revenue) OVER (ORDER BY revenue DESC) * 100.0
        / SUM(revenue) OVER (),
        2
    ) AS cumulative_percentage
FROM country_revenue
ORDER BY revenue DESC;

/* =========================================
   CANCELLATION ANALYSIS
========================================= */

/* Countries with Highest Cancellation Rate */

WITH country_stats AS (
    SELECT 
        Country,
        COUNT(DISTINCT CASE WHEN is_cancelled = 'True' THEN InvoiceNo END) AS number_cancelled,
        COUNT(DISTINCT InvoiceNo) AS Country_count
    FROM fact_sales 
    JOIN dim_customers 
        ON fact_sales.CustomerID = dim_customers.CustomerId
    GROUP BY Country
)
SELECT 
    Country,
    number_cancelled,
    Country_count,
    ROUND(number_cancelled * 100.0 / Country_count, 2) AS cancellation_rate
FROM country_stats
ORDER BY cancellation_rate DESC;



/* Impact of Order Value on Cancellation  */
WITH invoice_value AS (
    SELECT
        InvoiceNo,
        is_cancelled,
        ABS(SUM(Quantity * UnitPrice)) AS invoice_value
    FROM fact_sales
    GROUP BY InvoiceNo, is_cancelled
),

invoice_class AS (
    SELECT
        InvoiceNo,
        is_cancelled,
        invoice_value,
        NTILE(4) OVER (ORDER BY invoice_value) AS quartile
    FROM invoice_value
)

SELECT
    quartile,
    COUNT(*) AS total_invoices,
    SUM(
        CASE
            WHEN is_cancelled = 'True' THEN 1
            ELSE 0
        END
    ) AS cancelled_invoices,
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN is_cancelled = 'True' THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS cancellation_rate
FROM invoice_class
GROUP BY quartile
ORDER BY quartile;



/* cancellation trend */

with monthly_count as (SELECT strftime('%Y-%m',InvoiceDate) as new_date,sum(case
WHEN is_cancelled='True' then 1
else 0
END ) as number_cancellation_monthly,count(*) as total_orders
 from fact_sales
 GROUP by new_date
 ORDER by new_date)
 SELECT new_date,number_cancellation_monthly,total_orders,round(100.0*number_cancellation_monthly/total_orders,2) as cancellation_rate
 from monthly_count
ORDER by cancellation_rate DESC

/*Top Cancelled Products During High-Cancellation Months */
WITH cancelled_products AS (
    SELECT
        strftime('%Y-%m', InvoiceDate) AS month,
        Description,
        COUNT(*) AS cancellation_count
    FROM fact_sales
    JOIN dim_products
        ON fact_sales.StockCode = dim_products.StockCode
    WHERE is_cancelled = 'True'
      AND strftime('%m', InvoiceDate) IN ('01', '06', '10')
    GROUP BY month, Description
),

ranked AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY month
               ORDER BY cancellation_count DESC
           ) AS ranking
    FROM cancelled_products
)

SELECT
    month,
    Description,
    cancellation_count
FROM ranked
WHERE ranking <= 5
ORDER BY month, cancellation_count DESC;


/*   Impact of Product Price on Cancellation */
SELECT DISTINCT is_cancelled ,avg( UnitPrice)over(PARTITION by is_cancelled) as UnitPrice_avg
FROM fact_sales 
ORDER by UnitPrice_avg DESC
/*Customer-level Cancellation Analysis*/
SELECT 
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders,
    COUNT(DISTINCT CASE WHEN is_cancelled = 'True' THEN InvoiceNo END) AS cancelled_orders,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN is_cancelled = 'True' THEN InvoiceNo END) / COUNT(DISTINCT InvoiceNo), 2) AS customer_cancellation_rate
FROM fact_sales
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) >= 3 
ORDER BY customer_cancellation_rate DESC
LIMIT 20;
/*the customer 13115 proudects cancellation*/
SELECT 
    InvoiceNo,
    is_cancelled,
    COUNT(DISTINCT StockCode) AS num_distinct_products,
    SUM(Quantity) AS total_items
FROM fact_sales
WHERE CustomerID = 13115
GROUP BY InvoiceNo, is_cancelled
ORDER BY is_cancelled DESC, num_distinct_products DESC;


/* =========================================
   ADVANCED SQL
========================================= */

/* Revenue Ranking by Country */

with Country_income as (
SELECT Country ,sum( Quantity*UnitPrice) as revenue
 from fact_sales join dim_customers
on fact_sales.CustomerID=dim_customers.CustomerID
GROUP by country)
SELECT country , rank()over(ORDER by revenue DESC) as ranking
from Country_income



/* Order Value Categories Using CTE */
SELECT 
    InvoiceNo,
    SUM(Quantity * UnitPrice) AS invoice_value,
    CASE 
        WHEN SUM(Quantity * UnitPrice) < 20 THEN 'Low'
        WHEN SUM(Quantity * UnitPrice) < 100 THEN 'Medium'
        ELSE 'High'
    END AS value_category
FROM fact_sales
WHERE is_cancelled = 'False'  -- Excluding cancelled orders to calculate actual value only
GROUP BY InvoiceNo
ORDER BY invoice_value DESC;


/* the products that the costumer who is the most cancellation  */
SELECT Description,count(fact_sales.StockCode) AS count_all, sum( CASE
                WHEN is_cancelled = 'True' THEN 1
                ELSE 0
            END
        ) as count_cancellation
FROM fact_sales join dim_products
on fact_sales.StockCode=dim_products.StockCode
WHERE CustomerID =13115
GROUP by Description
ORDER by count_cancellation DESC , count_all
/* Overall Cancellation Rate */
SELECT 
count(distinct case when is_cancelled ='True' then InvoiceNo END) as total_cancelled,
count(DISTINCT InvoiceNo) as total_orders,
round(100.0*count(distinct case when is_cancelled='True' then InvoiceNo end)/count(distinct InvoiceNo),2) as oveall_cancellaion_rate
FROM fact_sales;
