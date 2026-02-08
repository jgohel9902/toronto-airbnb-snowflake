-- 05_ai_insights.sql
-- Purpose: Generate AI-assisted executive summary + store structured insights (Cortex + SQL fallback)

USE WAREHOUSE TORONTO_WH;
USE DATABASE TORONTO_AIRBNB_INTEL;
USE SCHEMA TORONTO_AIRBNB_INTEL.GOLD;

-- 1) Insight text (single row) built from executive snapshot
CREATE OR REPLACE VIEW TORONTO_AIRBNB_INTEL.GOLD.V_AI_INSIGHT_TEXT AS
SELECT
  'Toronto Airbnb Snapshot (' || TO_VARCHAR(snapshot_date) || '): ' ||
  'Total listings=' || total_listings ||
  ', Total hosts=' || total_hosts ||
  ', Avg price=$' || avg_price ||
  -- median_price exists only if you used the upgraded GOLD script; if not, remove this line
  ', Median price=$' || COALESCE(TO_VARCHAR(median_price), 'N/A') ||
  ', Avg minimum nights=' || avg_minimum_nights ||
  ', Avg availability (365 days)=' || avg_availability_365 ||
  '. Top premium neighbourhood=' || top_premium_neighbourhood ||
  '. Top demand neighbourhood=' || top_demand_neighbourhood ||
  '.'
  AS insight_text
FROM TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT;

-- 2) Store executive summaries (AI + fallback)
CREATE OR REPLACE TABLE TORONTO_AIRBNB_INTEL.GOLD.T_EXEC_SUMMARY (
  summary_source STRING,
  summary_text STRING,
  generated_on TIMESTAMP_NTZ
);

-- Clear and re-insert (safe rerun)
TRUNCATE TABLE TORONTO_AIRBNB_INTEL.GOLD.T_EXEC_SUMMARY;


-- 2A) Fallback summary (still useful in case Cortex permissions change)
INSERT INTO TORONTO_AIRBNB_INTEL.GOLD.T_EXEC_SUMMARY
SELECT
  'SQL_FALLBACK' AS summary_source,
  'Executive Summary: Toronto has ' || total_listings || ' active listings across ' || total_hosts || ' hosts. ' ||
  'Average price is $' || avg_price || ' with an average minimum stay of ' || avg_minimum_nights || ' nights. ' ||
  'Top premium neighbourhood is ' || top_premium_neighbourhood || ', while the highest-demand neighbourhood is ' || top_demand_neighbourhood || '.'
  AS summary_text,
  CURRENT_TIMESTAMP() AS generated_on
FROM TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT;

-- 3) Structured insight bullets (table)
CREATE OR REPLACE TABLE TORONTO_AIRBNB_INTEL.GOLD.T_INSIGHTS (
  insight_id INTEGER,
  insight_type STRING,
  insight_text STRING,
  generated_on DATE
);

TRUNCATE TABLE TORONTO_AIRBNB_INTEL.GOLD.T_INSIGHTS;

INSERT INTO TORONTO_AIRBNB_INTEL.GOLD.T_INSIGHTS
SELECT
  1 AS insight_id,
  'Market Scale' AS insight_type,
  'Toronto Airbnb market contains ' || total_listings || ' active listings operated by ' || total_hosts ||
  ' hosts, indicating a highly competitive short-term rental environment.' AS insight_text,
  CURRENT_DATE() AS generated_on
FROM TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT

UNION ALL

SELECT
  2,
  'Pricing Insight',
  'The average nightly price is $' || avg_price ||
  ', suggesting a mid-to-upper pricing segment for short-term stays in Toronto.',
  CURRENT_DATE()
FROM TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT

UNION ALL

SELECT
  3,
  'Demand vs Premium',
  'The highest-priced neighbourhood (' || top_premium_neighbourhood ||
  ') is different from the highest-demand neighbourhood (' || top_demand_neighbourhood ||
  '), indicating pricing inefficiencies and opportunity zones.',
  CURRENT_DATE()
FROM TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT

UNION ALL

SELECT
  4,
  'Availability Strategy',
  'Average availability of ' || avg_availability_365 ||
  ' days per year suggests many listings operate as near-full-time rentals rather than occasional hosting.',
  CURRENT_DATE()
FROM TORONTO_AIRBNB_INTEL.GOLD.V_EXECUTIVE_SNAPSHOT;

-- Optional checks (great for screenshots)
SELECT * FROM TORONTO_AIRBNB_INTEL.GOLD.T_EXEC_SUMMARY ORDER BY generated_on DESC;
SELECT * FROM TORONTO_AIRBNB_INTEL.GOLD.T_INSIGHTS ORDER BY insight_id;
