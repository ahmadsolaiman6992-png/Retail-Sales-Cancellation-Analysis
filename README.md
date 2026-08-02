# Retail-Sales-Cancellation-Analysis
SQL analysis of retail sales and order cancellations using CTEs, window functions, and Python visualizations to uncover key business drivers behind cancellation patterns.

## Business Understanding

### Business Question
What factors are associated with order cancellations, and what actions can help reduce them?

---

## Dataset

The analysis is based on the Online Retail dataset, which contains three tables:

- fact_sales: 536,613 records
- dim_customers: 4,364 records
- dim_products: 3,926 records

---

## Tools

- SQLite
- SQL
- Python (Pandas, Matplotlib) — for visualizations

---

## How to Run This Project

1. Clone this repository
2. Open retail_sales.db in DB Browser for SQLite (or your preferred SQL tool)
3. Run the queries in queries.sql in order to reproduce the analysis
4. Visualizations were generated using the Python script in visuals.py (requires Pandas and Matplotlib)

---

# Data Exploration

## Top Countries by Revenue



![Top Countries](visuals/top_countries.png)



The United Kingdom generated the highest revenue by a significant margin, followed by the Netherlands, Germany, and EIRE.

---

## Top Products by Revenue



![Top Products](visuals/top_products.png)



REGENCY CAKESTAND 3 TIER was the highest revenue-generating product.

---

## Monthly Sales Trend



![Sales Trend](visuals/sales_trend.png)



Revenue reached its peak in November 2011, while April 2011 recorded the lowest monthly revenue.

---

## Average Order Value by Country

The Netherlands recorded the highest average order value, followed by Singapore and Australia.

---

## Revenue Distribution Across Countries



![Revenue Distribution](visuals/revenue_distribution.png)



The United Kingdom generated approximately 85% of total revenue, indicating a highly concentrated customer base and potential geographic risk.

---

# Cancellation Analysis

## Cancellation Rate by Country



![Cancellation by Country](visuals/cancellation_by_country.png)



Although the United Kingdom recorded the highest number of cancelled orders, its cancellation rate remained close to the overall average. Italy and Switzerland showed the highest cancellation rates among countries with a meaningful number of orders.

---

## Overall Cancellation Rate

Overall cancellation rate: 14.75%

A total of 3,422 orders were cancelled out of 23,198 orders.

---

## Monthly Cancellation Trend



![Cancellation Trend](visuals/cancellation_trend.png)



January, June, and October exhibited relatively high cancellation rates despite not being the highest-sales months, suggesting that operational or seasonal factors may influence cancellation behavior.

---

## Impact of Order Value on Cancellation



![Order Value vs Cancellation](visuals/order_value.png)



More than half of cancelled orders belonged to the highest-value order group, suggesting that expensive orders are more likely to be cancelled.

---

## Impact of Product Price on Cancellation



![Price vs Cancellation](visuals/price_vs_cancellation.png)



Cancelled orders had a moderately higher average product price (4.42) than completed orders (3.28), suggesting that product price may be associated with cancellations, although it is unlikely to be the only contributing factor.

---

## Top Cancelled Products During High-Cancellation Months

REGENCY CAKESTAND 3 TIER consistently appeared among the most frequently cancelled products during January, June, and October. Further analysis is required to determine whether its cancellation rate is unusually high relative to its sales volume.

---

## Customer-Level Cancellation Analysis

Customer 13115 initially appeared to have an unusually high cancellation rate. However, further investigation showed that cancelled orders were consistently small correction orders, while completed orders were large wholesale purchases.

This suggests that cancellations were likely due to order adjustments rather than customer dissatisfaction, preventing the customer from being incorrectly classified as high-risk.

---

# Advanced SQL Techniques

This project demonstrates the use of several advanced SQL features, including:

- Common Table Expressions (CTEs)
- Window Functions
- RANK()
- Aggregate Functions
- CASE WHEN

---
# Key Findings

- The United Kingdom generated approximately 85% of total revenue.
- Italy and Switzerland recorded the highest cancellation rates among major markets.
- High-value orders were more likely to be cancelled.
- Cancelled orders had slightly higher average product prices.
- November was the strongest sales month.
- Customer 13115 was identified as a valuable wholesale customer rather than a high-risk customer after detailed investigation.

---

# Recommendations

1. Reduce geographic risk by expanding into new markets while maintaining the strong UK customer base.

2. Investigate the high cancellation rates in Switzerland and Italy to identify operational or market-specific issues.

3. Review the checkout and order confirmation process for high-value orders to reduce unnecessary cancellations.

4. Simplify the ordering process for wholesale customers to minimize order correction cancellations.

---

## Author

Ahmad Solaiman

GitHub: https://github.com/ahmadsolaiman6992-png
