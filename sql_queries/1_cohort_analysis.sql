SELECT 
	ca.cohort_year,
	SUM(ca.total_revenue ) AS total_revenue,
	COUNT(DISTINCT ca.customerkey) AS customer_count,
	ROUND(SUM(ca.total_revenue ) / COUNT(DISTINCT ca.customerkey)) AS revenue_per_customer
FROM cohort_analysis ca
GROUP BY ca.cohort_year