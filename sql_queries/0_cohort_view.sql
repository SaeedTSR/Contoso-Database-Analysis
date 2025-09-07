CREATE VIEW cohort_analysis AS
WITH customer_revenue AS (
	SELECT
		s.customerkey,
		s.orderdate,
		CONCAT(TRIM(c.givenname), ' ', TRIM(c.surname)) AS full_name,
		c.age,
		c.countryfull,
		ROUND(SUM((netprice * quantity * exchangerate)::numeric), 2) AS total_revenue,
		COUNT(s.orderkey) AS order_count
	FROM sales s
	LEFT JOIN customer c ON s.customerkey = c.customerkey
	GROUP BY
		s.customerkey,
		s.orderdate,
		full_name,
		c.age,
		c.countryfull
)
SELECT 
	*,
	MIN(TO_CHAR(orderdate, 'YYYY')) OVER (PARTITION BY customerkey) AS cohort_year
FROM customer_revenue