WITH customer_ltv AS (
	SELECT 
		customerkey,
		full_name,
		SUM(total_revenue) AS total_ltv
	FROM cohort_analysis
	GROUP BY 
		customerkey,
		full_name
),

customer_segments AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_ltv) AS ltv_25th,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_ltv) AS ltv_75th
	FROM customer_ltv
),

segment_values AS (
	SELECT 
		cl.customerkey,
		cl.full_name,
		cl.total_ltv,
		CASE 
			WHEN cl.total_ltv < ltv_25th THEN '3 - Low'
			WHEN cl.total_ltv > ltv_75th THEN '1 - High'
			ELSE '2 - Mid'
		END AS customer_segment
	FROM
		customer_ltv cl,
		customer_segments cs
)

SELECT 
	customer_segment,
	SUM(total_ltv) AS total_ltv,
	COUNT(customerkey) AS customer_count,
	ROUND(SUM(total_ltv) / COUNT(customerkey)) AS avg_ltv
FROM segment_values
GROUP BY customer_segment
ORDER BY customer_segment 