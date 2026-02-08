-- 04_gold_marts.sql
-- Purpose: Create business-ready GOLD views for dashboards and insights

USE WAREHOUSE TORONTO_WH;
USE DATABASE TORONTO_AIRBNB_INTEL;
USE SCHEMA TORONTO_AIRBNB_INTEL.GOLD;

-- 1) Market KPIs
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_KPI_MARKET AS
SELECT
  COUNT(*) AS total_listings,
  COUNT(DISTINCT host_id) AS total_hosts,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 2) AS median_price,
  ROUND(AVG(minimum_nights), 2) AS avg_minimum_nights,
  ROUND(AVG(availability_365), 2) AS avg_availability_365
FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
WHERE price IS NOT NULL AND price > 0;

-- 2) Neighbourhood performance
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_NEIGHBOURHOOD_PERF AS
SELECT
  neighbourhood,
  COUNT(*) AS listings,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 2) AS median_price,
  ROUND(AVG(availability_365), 2) AS avg_availability_365,
  ROUND(AVG(number_of_reviews), 2) AS avg_reviews,
  SUM(number_of_reviews) AS total_reviews
FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
WHERE neighbourhood IS NOT NULL
  AND price IS NOT NULL
  AND price > 0
GROUP BY neighbourhood;

-- 3) Room type performance
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_ROOMTYPE_PERF AS
SELECT
  room_type,
  COUNT(*) AS listings,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 2) AS median_price,
  ROUND(AVG(minimum_nights), 2) AS avg_minimum_nights,
  ROUND(AVG(availability_365), 2) AS avg_availability_365,
  ROUND(AVG(number_of_reviews), 2) AS avg_reviews,
  SUM(number_of_reviews) AS total_reviews
FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
WHERE room_type IS NOT NULL
  AND price IS NOT NULL
  AND price > 0
GROUP BY room_type;

-- 4) Host concentration (market structure)
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_HOST_CONCENTRATION AS
SELECT
  CASE
    WHEN calculated_host_listings_count = 1 THEN '1 listing'
    WHEN calculated_host_listings_count BETWEEN 2 AND 5 THEN '2–5 listings'
    WHEN calculated_host_listings_count BETWEEN 6 AND 20 THEN '6–20 listings'
    ELSE '21+ listings'
  END AS host_portfolio_bucket,
  COUNT(*) AS listings,
  COUNT(DISTINCT host_id) AS hosts,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(AVG(number_of_reviews), 2) AS avg_reviews,
  SUM(number_of_reviews) AS total_reviews
FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
WHERE calculated_host_listings_count IS NOT NULL
  AND host_id IS NOT NULL
  AND price IS NOT NULL
  AND price > 0
GROUP BY 1;

-- 5) Best value neighbourhoods (demand / price)
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_BEST_VALUE_NEIGHBOURHOODS AS
WITH n AS (
  SELECT
    neighbourhood,
    COUNT(*) AS listings,
    AVG(price) AS avg_price,
    AVG(number_of_reviews) AS avg_reviews,
    SUM(number_of_reviews) AS total_reviews
  FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
  WHERE neighbourhood IS NOT NULL
    AND price IS NOT NULL
    AND price > 0
    AND number_of_reviews IS NOT NULL
  GROUP BY neighbourhood
  HAVING COUNT(*) >= 30
)
SELECT
  neighbourhood,
  listings,
  ROUND(avg_price, 2) AS avg_price,
  ROUND(avg_reviews, 2) AS avg_reviews,
  total_reviews,
  ROUND((avg_reviews / NULLIF(avg_price, 0)), 6) AS value_score
FROM n;

-- 6) Premium neighbourhoods (top price)
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_PREMIUM_NEIGHBOURHOODS AS
SELECT
  neighbourhood,
  COUNT(*) AS listings,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 2) AS median_price,
  ROUND(AVG(availability_365), 2) AS avg_availability_365,
  ROUND(AVG(number_of_reviews), 2) AS avg_reviews
FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
WHERE neighbourhood IS NOT NULL
  AND price IS NOT NULL
  AND price > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 30;

-- 7) Hot neighbourhoods (proxy demand via reviews)
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_HOT_NEIGHBOURHOODS AS
SELECT
  neighbourhood,
  COUNT(*) AS listings,
  ROUND(AVG(number_of_reviews), 2) AS avg_reviews,
  SUM(number_of_reviews) AS total_reviews,
  ROUND(AVG(price), 2) AS avg_price
FROM TORONTO_AIRBNB_INTEL.SILVER.LISTINGS
WHERE neighbourhood IS NOT NULL
  AND number_of_reviews IS NOT NULL
  AND price IS NOT NULL
  AND price > 0
GROUP BY neighbourhood
HAVING COUNT(*) >= 30;

-- 8) Executive snapshot (single-row)
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT AS
SELECT
  k.total_listings,
  k.total_hosts,
  k.avg_price,
  k.median_price,
  k.avg_minimum_nights,
  k.avg_availability_365,
  (SELECT neighbourhood FROM TORONTO_AIRBNB_INTEL.GOLD.V_PREMIUM_NEIGHBOURHOODS ORDER BY avg_price DESC LIMIT 1) AS top_premium_neighbourhood,
  (SELECT neighbourhood FROM TORONTO_AIRBNB_INTEL.GOLD.V_HOT_NEIGHBOURHOODS ORDER BY avg_reviews DESC LIMIT 1) AS top_demand_neighbourhood,
  CURRENT_DATE() AS snapshot_date
FROM TORONTO_AIRBNB_INTEL.GOLD.V_KPI_MARKET k;

