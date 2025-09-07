WITH customer_date AS (
	SELECT
		s.customerkey,
		CONCAT(TRIM(c.givenname), ' ', TRIM(c.surname)) AS full_name,
		MAX(s.orderdate) AS last_purchase_date,
		MIN(s.orderdate) AS first_purchase_date
	FROM sales s
	LEFT JOIN customer c ON s.customerkey = c.customerkey
	GROUP BY 
		s.customerkey,
		full_name 
),
customer_churn AS (
	SELECT 
		cd.customerkey,
		cd.full_name,
		cd.last_purchase_date,
		cd.first_purchase_date,
		CASE 
	        WHEN (EXTRACT(YEAR FROM AGE((SELECT MAX(orderdate) FROM sales), cd.last_purchase_date)) * 12 
	              + EXTRACT(MONTH FROM AGE((SELECT MAX(orderdate) FROM sales), cd.last_purchase_date))) > 6
	        THEN 'Churned'
	        ELSE 'Active'
	    END AS customer_status	
	FROM customer_date cd
	WHERE cd.first_purchase_date < (SELECT MAX(orderdate) FROM sales) - INTERVAL '6 months'
)

SELECT
	TO_CHAR(first_purchase_date , 'YYYY') AS cohort_year,
	customer_status,
	COUNT(customerkey) AS num_customers,
	SUM(COUNT(customerkey)) OVER(PARTITION BY TO_CHAR(first_purchase_date , 'YYYY')) AS total_customers,
	ROUND(COUNT(customerkey) / SUM(COUNT(customerkey)) OVER(PARTITION BY TO_CHAR(first_purchase_date , 'YYYY')), 2) AS status_percent
FROM customer_churn
GROUP BY 
	cohort_year,
	customer_status
ORDER BY 
	cohort_year,
	customer_status
