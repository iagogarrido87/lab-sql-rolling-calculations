-- 1. Get number of monthly active customers.
SELECT YEAR(rental_date) AS Activity_Year,
       MONTH(rental_date) AS Activity_Month,
       COUNT(DISTINCT customer_id) AS Active_Customers
FROM rental
GROUP BY Activity_Year, Activity_Month;


-- 2. Active users in the previous month.
WITH cte_active_users AS (
  SELECT YEAR(rental_date) AS Activity_Year,
         MONTH(rental_date) AS Activity_Month,
         COUNT(DISTINCT customer_id) AS Active_Customers
  FROM rental
  GROUP BY Activity_Year, Activity_Month
)
SELECT Activity_Year, Activity_Month, Active_Customers,
       LAG(Active_Customers) OVER (ORDER BY Activity_Year, Activity_Month) AS Last_Month
FROM cte_active_users;


-- 3. Percentage change in the number of active customers.
WITH cte_active_users AS (
  SELECT YEAR(rental_date) AS Activity_Year,
         MONTH(rental_date) AS Activity_Month,
         COUNT(DISTINCT customer_id) AS Active_Customers
  FROM rental
  GROUP BY Activity_Year, Activity_Month
), cte_active_users_prev AS (
  SELECT Activity_Year, Activity_Month, Active_Customers,
         LAG(Active_Customers) OVER (ORDER BY Activity_Year, Activity_Month) AS Last_Month
  FROM cte_active_users
)
SELECT *,
       (Active_Customers - Last_Month) AS Difference,
       CONCAT(ROUND((Active_Customers - Last_Month) / Active_Customers * 100), '%') AS Percent_Difference
FROM cte_active_users_prev;


-- 4. Retained customers every month.
WITH cte_active_users AS (
  SELECT YEAR(rental_date) AS Activity_Year,
         MONTH(rental_date) AS Activity_Month,
         COUNT(DISTINCT customer_id) AS Active_Customers
  FROM rental
  GROUP BY Activity_Year, Activity_Month
), cte_retained_customers AS (
  SELECT Activity_Year, Activity_Month, Active_Customers,
         LAG(Active_Customers) OVER (ORDER BY Activity_Year, Activity_Month) AS Last_Month
  FROM cte_active_users
)
SELECT *,
       Active_Customers - COALESCE(Last_Month, 0) AS Retained_Customers
FROM cte_retained_customers;


