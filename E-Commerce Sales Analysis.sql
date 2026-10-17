-- ============================================================
-- E-Commerce Business Questions: SQL Answers (52 questions)
-- Dataset: ecommerce_dataset_updated.sql
-- Dialect: MySQL 8.0+ (window functions and CTEs are used)
-- Database: E_Commerce_Project
--
-- IMPORTANT NOTES:
-- 1) The supplied PDF contains 52 questions, not 53.
-- 2) Revenue/sales calculations below use order_items revenue and
--    include all order statuses unless the question explicitly asks
--    about order status. To count only completed sales, add
--    `WHERE o.order_status = 'Delivered'` to the relevant query.
-- 3) Churn/inactivity is defined here as no order in the last 90 days.
-- ============================================================
USE E_Commerce_Project;

-- Q1. What is our total revenue so far?
SELECT ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM order_items oi;

-- Q2. How many total orders have we received?
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q3. How many total customers do we have?
SELECT COUNT(*) AS total_customers
FROM customers;

-- Q4. How many products do we sell?
SELECT COUNT(*) AS total_products
FROM products;

-- Q5. What is the average amount spent per order?
WITH order_totals AS (
    SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id
)
SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM order_totals;

-- Q6. Top 5 best-selling products (by quantity sold)
SELECT p.product_id, p.product_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Q7. Which category generates the most revenue?
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC
LIMIT 1;

-- Q8. Top 5 most valuable customers (by total revenue)
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Q9. Monthly revenue trend
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- Q10. Which city generates the most sales?
SELECT c.city,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_sales
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.city
ORDER BY total_sales DESC
LIMIT 1;

-- Q11. Which customers purchase repeatedly?
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;

-- Q12. Which customers have never placed an order?
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- Q13. Which customers have been inactive in the last 90 days?
-- Includes customers who have never ordered (last_order_date is NULL).
SELECT c.customer_id, c.customer_name,
       MAX(o.order_date) AS last_order_date
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING MAX(o.order_date) < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    OR MAX(o.order_date) IS NULL
ORDER BY last_order_date;

-- Q14. What is the best-selling category (by quantity sold)?
SELECT p.category, SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- Q15. Which product generates the highest revenue?
SELECT p.product_id, p.product_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC
LIMIT 1;

-- Q16. Which product generates the lowest revenue?
-- Includes products with no sales (their revenue is reported as 0).
SELECT p.product_id, p.product_name,
       ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS total_revenue
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue ASC
LIMIT 1;

-- Q17. On average, how many product units are bought per order?
WITH order_quantities AS (
    SELECT o.order_id, SUM(oi.quantity) AS units_in_order
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id
)
SELECT ROUND(AVG(units_in_order), 2) AS average_units_per_order
FROM order_quantities;

-- Q18. Which orders are worth more than 10,000?
SELECT o.order_id, o.order_date, o.order_status,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.order_date, o.order_status
HAVING SUM(oi.quantity * oi.unit_price) > 10000
ORDER BY order_value DESC;

-- Q19. Which customers have the highest average order value?
WITH order_totals AS (
    SELECT o.order_id, o.customer_id,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_id, o.customer_id
)
SELECT c.customer_id, c.customer_name,
       ROUND(AVG(ot.order_value), 2) AS average_order_value,
       COUNT(*) AS order_count
FROM order_totals ot
JOIN customers c ON c.customer_id = ot.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY average_order_value DESC;

-- Q20. Top 3 cities by revenue
SELECT c.city,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.city
ORDER BY total_revenue DESC
LIMIT 3;

-- Q21. Rank customers based on revenue
WITH customer_revenue AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS revenue
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT customer_id, customer_name, ROUND(revenue, 2) AS total_revenue,
       DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM customer_revenue
ORDER BY revenue_rank, customer_id;

-- Q22. Top-selling product in each category (by quantity)
WITH product_sales AS (
    SELECT p.category, p.product_id, p.product_name,
           SUM(oi.quantity) AS quantity_sold,
           DENSE_RANK() OVER (
               PARTITION BY p.category ORDER BY SUM(oi.quantity) DESC
           ) AS category_rank
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT category, product_id, product_name, quantity_sold
FROM product_sales
WHERE category_rank = 1
ORDER BY category;

-- Q23. Revenue running total over time (daily)
WITH daily_revenue AS (
    SELECT o.order_date,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.order_date
)
SELECT order_date, ROUND(revenue, 2) AS daily_revenue,
       ROUND(SUM(revenue) OVER (ORDER BY order_date), 2) AS running_total_revenue
FROM daily_revenue
ORDER BY order_date;

-- Q24. Previous order date for each customer
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER (
           PARTITION BY customer_id ORDER BY order_date, order_id
       ) AS previous_order_date
FROM orders
ORDER BY customer_id, order_date, order_id;

-- Q25. Next order date for each customer, if any
SELECT customer_id, order_id, order_date,
       LEAD(order_date) OVER (
           PARTITION BY customer_id ORDER BY order_date, order_id
       ) AS next_order_date
FROM orders
ORDER BY customer_id, order_date, order_id;

-- Q26. Days between consecutive orders for each customer
SELECT customer_id, order_id, order_date,
       LAG(order_date) OVER (
           PARTITION BY customer_id ORDER BY order_date, order_id
       ) AS previous_order_date,
       DATEDIFF(
           order_date,
           LAG(order_date) OVER (
               PARTITION BY customer_id ORDER BY order_date, order_id
           )
       ) AS days_since_previous_order
FROM orders
ORDER BY customer_id, order_date, order_id;

-- Q27. Top 3 customers by revenue
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 3;

-- Q28. Percentage contribution of each product to total revenue
WITH product_revenue AS (
    SELECT p.product_id, p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.product_id, p.product_name
)
SELECT product_id, product_name, ROUND(revenue, 2) AS product_revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_percentage
FROM product_revenue
ORDER BY revenue DESC;

-- Q29. Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_start,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m-01')
), with_previous AS (
    SELECT month_start, revenue,
           LAG(revenue) OVER (ORDER BY month_start) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT DATE_FORMAT(STR_TO_DATE(month_start, '%Y-%m-%d'), '%Y-%m') AS month,
       ROUND(revenue, 2) AS revenue,
       ROUND(previous_month_revenue, 2) AS previous_month_revenue,
       ROUND(100 * (revenue - previous_month_revenue) / NULLIF(previous_month_revenue, 0), 2)
           AS mom_growth_percentage
FROM with_previous
ORDER BY month_start;

-- Q30. Each customer's highest-value order
WITH order_totals AS (
    SELECT o.customer_id, o.order_id, o.order_date,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY o.customer_id, o.order_id, o.order_date
), ranked_orders AS (
    SELECT order_totals.*,
           DENSE_RANK() OVER (
               PARTITION BY customer_id ORDER BY order_value DESC
           ) AS order_rank
    FROM order_totals
)
SELECT c.customer_id, c.customer_name, ro.order_id, ro.order_date,
       ROUND(ro.order_value, 2) AS highest_order_value
FROM ranked_orders ro
JOIN customers c ON c.customer_id = ro.customer_id
WHERE ro.order_rank = 1
ORDER BY c.customer_id;

-- Q31. Customer lifetime value (CLV), calculated as total historical revenue
SELECT c.customer_id, c.customer_name,
       ROUND(COALESCE(SUM(oi.quantity * oi.unit_price), 0), 2) AS lifetime_value
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
LEFT JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_value DESC;

-- Q32. Repeat purchase rate (% of customers with more than one order)
WITH customer_order_counts AS (
    SELECT c.customer_id, COUNT(DISTINCT o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT COUNT(CASE WHEN order_count > 1 THEN 1 END) AS repeat_customers,
       COUNT(*) AS total_customers,
       ROUND(100 * COUNT(CASE WHEN order_count > 1 THEN 1 END) / COUNT(*), 2)
           AS repeat_purchase_rate_pct
FROM customer_order_counts;

-- Q33. New vs returning customers (overall order-history classification)
WITH customer_order_counts AS (
    SELECT c.customer_id, COUNT(o.order_id) AS order_count
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT CASE
           WHEN order_count = 0 THEN 'Never ordered'
           WHEN order_count = 1 THEN 'One-time customer'
           ELSE 'Returning customer'
       END AS customer_type,
       COUNT(*) AS customer_count
FROM customer_order_counts
GROUP BY customer_type
ORDER BY customer_count DESC;

-- Q34. Number of active customers per month (at least one order in month)
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       COUNT(DISTINCT o.customer_id) AS active_customers
FROM orders o
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY month;

-- Q35. Customers who purchase from more than one category
SELECT c.customer_id, c.customer_name,
       COUNT(DISTINCT p.category) AS categories_purchased
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(DISTINCT p.category) > 1
ORDER BY categories_purchased DESC, c.customer_id;

-- Q36. Product pairs most frequently purchased together in the same order
SELECT p1.product_name AS product_1,
       p2.product_name AS product_2,
       COUNT(DISTINCT oi1.order_id) AS orders_bought_together
FROM order_items oi1
JOIN order_items oi2
  ON oi1.order_id = oi2.order_id
 AND oi1.product_id < oi2.product_id
JOIN products p1 ON p1.product_id = oi1.product_id
JOIN products p2 ON p2.product_id = oi2.product_id
GROUP BY oi1.product_id, oi2.product_id, p1.product_name, p2.product_name
ORDER BY orders_bought_together DESC
LIMIT 1;

-- Q37. Average number of days between a customer's consecutive orders
WITH order_gaps AS (
    SELECT customer_id, order_date,
           DATEDIFF(
               order_date,
               LAG(order_date) OVER (
                   PARTITION BY customer_id ORDER BY order_date, order_id
               )
           ) AS days_between_orders
    FROM orders
)
SELECT ROUND(AVG(days_between_orders), 2) AS average_days_between_orders
FROM order_gaps
WHERE days_between_orders IS NOT NULL;

-- Q38. Product category with the fastest month-over-month revenue growth
WITH monthly_category_revenue AS (
    SELECT p.category,
           DATE_FORMAT(o.order_date, '%Y-%m-01') AS month_start,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY p.category, DATE_FORMAT(o.order_date, '%Y-%m-01')
), category_growth AS (
    SELECT category, month_start, revenue,
           LAG(revenue) OVER (PARTITION BY category ORDER BY month_start) AS previous_revenue
    FROM monthly_category_revenue
), growth_rates AS (
    SELECT category, month_start,
           100 * (revenue - previous_revenue) / NULLIF(previous_revenue, 0) AS growth_pct
    FROM category_growth
    WHERE previous_revenue IS NOT NULL
)
SELECT category, month_start, ROUND(growth_pct, 2) AS growth_percentage
FROM growth_rates
WHERE growth_pct IS NOT NULL
ORDER BY growth_pct DESC
LIMIT 1;

-- Q39. Customers at risk of churn (no order in the last 90 days, or never ordered)
SELECT c.customer_id, c.customer_name,
       MAX(o.order_date) AS last_order_date,
       DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING MAX(o.order_date) < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    OR MAX(o.order_date) IS NULL
ORDER BY last_order_date;

-- Q40. RFM analysis (Recency, Frequency, Monetary) for each customer
-- Recency is measured against CURDATE(); scores 5 = best recency/frequency/monetary.
WITH rfm_base AS (
    SELECT c.customer_id, c.customer_name,
           DATEDIFF(CURDATE(), MAX(o.order_date)) AS recency_days,
           COUNT(DISTINCT o.order_id) AS frequency,
           COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS monetary_value
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi ON oi.order_id = o.order_id
    GROUP BY c.customer_id, c.customer_name
), rfm_scores AS (
    SELECT rfm_base.*,
           NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
           NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
           NTILE(5) OVER (ORDER BY monetary_value ASC) AS monetary_score
    FROM rfm_base
)
SELECT customer_id, customer_name, recency_days, frequency,
       ROUND(monetary_value, 2) AS monetary_value,
       recency_score, frequency_score, monetary_score,
       CONCAT(recency_score, frequency_score, monetary_score) AS rfm_segment_code
FROM rfm_scores
ORDER BY monetary_score DESC, frequency_score DESC, recency_score DESC;

-- Q41. Daily sales trend
SELECT o.order_date,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS daily_sales
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Q42. Top 10 best-selling products (by quantity sold)
SELECT p.product_id, p.product_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

-- Q43. Top 10 customers by revenue
SELECT c.customer_id, c.customer_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Q44. Revenue from male vs female customers
SELECT c.gender,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.gender
ORDER BY total_revenue DESC;

-- Q45. Customer churn rate (% customers with no order in the last 90 days).
-- Customers who have never ordered are included as churned/inactive.
WITH customer_last_order AS (
    SELECT c.customer_id, MAX(o.order_date) AS last_order_date
    FROM customers c
    LEFT JOIN orders o ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT COUNT(CASE
                 WHEN last_order_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
                      OR last_order_date IS NULL THEN 1
             END) AS churned_or_inactive_customers,
       COUNT(*) AS total_customers,
       ROUND(100 * COUNT(CASE
                 WHEN last_order_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
                      OR last_order_date IS NULL THEN 1
             END) / COUNT(*), 2) AS churn_rate_pct
FROM customer_last_order;

-- Q46. What percentage of orders are cancelled?
SELECT COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) AS cancelled_orders,
       COUNT(*) AS total_orders,
       ROUND(100 * COUNT(CASE WHEN order_status = 'Cancelled' THEN 1 END) / COUNT(*), 2)
           AS cancellation_percentage
FROM orders;

-- Q47. How many orders were delivered vs cancelled? (includes other statuses too)
SELECT order_status, COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- Q48. Worst-selling category (by quantity sold)
SELECT p.category, SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity_sold ASC
LIMIT 1;

-- Q49. Most expensive product that has been sold (highest unit price)
SELECT DISTINCT p.product_id, p.product_name, p.category,
       oi.unit_price AS sold_unit_price
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
ORDER BY oi.unit_price DESC
LIMIT 1;

-- Q50. Which month had the highest revenue?
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY total_revenue DESC
LIMIT 1;

-- Q51. Number of new customers acquired each month (based on signup_date)
SELECT DATE_FORMAT(signup_date, '%Y-%m') AS signup_month,
       COUNT(*) AS new_customers
FROM customers
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY signup_month;

-- Q52. Percentage contribution of each category to total revenue
WITH category_revenue AS (
    SELECT p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY p.category
)
SELECT category, ROUND(revenue, 2) AS category_revenue,
       ROUND(100 * revenue / SUM(revenue) OVER (), 2) AS revenue_percentage
FROM category_revenue
ORDER BY revenue DESC;

-- END OF 52 QUESTIONS
