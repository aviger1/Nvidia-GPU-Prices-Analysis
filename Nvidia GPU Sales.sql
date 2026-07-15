-- Create a table describing the relations between street price (scalping) and the customer satisfaction score from the sale
SELECT
	sale_id,
    customer_satisfaction_score css,
	average_street_price_usd aspu
FROM nvidia_gpu_sales_synthetic_2026;

-- Create a Query Grouping the sales by the customer segments and counting the # of sales
CREATE TABLE total_revenue_by_segment
SELECT customer_segment,
		gpu_family,
	sum(units_sold) AS number_of_sales,
    AVG(avg_street_price_usd) AS aspu,
    CAST(sum(revenue_usd) AS DECIMAL(20,2)) AS total_revenue
FROM `nvidia_gpu_sales_synthetic_2026`
GROUP BY customer_segment, gpu_family
ORDER BY number_of_sales DESC;

-- Cluster sales into personas, region+segment+price premium. Grouping the sales by general regional markets.

CREATE TABLE regional_segments_premiums
SELECT 
		region,
		customer_segment,
	sum(units_sold) AS number_of_sales,
    CAST(AVG(avg_street_price_usd) AS DECIMAL(20,2)) AS ASPU,
    CAST(AVG(price_premium_pct) AS DECIMAL (20,2)) AS Price_Premium_Pct,
    CAST(sum(revenue_usd) AS DECIMAL(20,2)) AS total_revenue
FROM `nvidia_gpu_sales_synthetic_2026`
GROUP BY region, customer_segment
ORDER BY region DESC;

-- Street Price Premiums Time-Series 2024-2026, and in relation to stock status periods
CREATE TABLE gpu_instock_price
SELECT
	DATE_FORMAT(sale_date, '%Y-%m'),
    gpu_model,
    stock_status,
    CAST(AVG(price_premium_pct) AS DECIMAL(20,2)) AS Price_Premium_Pct
FROM nvidia_gpu_sales_synthetic_2026
WHERE sale_date BETWEEN '2024-01-01' AND '2026-12-31'
GROUP BY DATE_FORMAT(sale_date, '%Y-%m'),gpu_model,stock_status
ORDER BY gpu_model, DATE_FORMAT(sale_date, '%Y-%m');

-- Deeper analysis finding which model was most affected by the different stock statuses
CREATE TABLE gpumodels_stock_premiums
SELECT
	DISTINCT gpu_model,
	stock_status,
	CAST(AVG(price_premium_pct) AS DECIMAL (20,2)) AS Price_Premium_Pct
FROM `gpu_instock_price`
GROUP BY gpu_model, stock_status
ORDER BY gpu_model, Price_Premium_Pct DESC;

--     Which region shows the largest MSRP-to-street-price gap, and does it differ between gaming and datacenter parts?
CREATE TABLE region_street_msrp_gap
SELECT
	region,
    customer_segment,
    CAST(AVG(avg_street_price_usd-msrp_usd) AS DECIMAL (10,2)) AS street_price_gap_msrp
FROM nvidia_gpu_sales_synthetic_2026
GROUP BY region, customer_segment
ORDER BY region ASC, street_price_gap_msrp DESC