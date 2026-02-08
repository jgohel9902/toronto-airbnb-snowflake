# Toronto Airbnb Market Intelligence  
**Snowflake · SQL · Medallion Architecture · AI (Snowflake Cortex)**

---

## 📌 Project Overview
This project analyzes Airbnb listings in Toronto using **Snowflake’s cloud data platform**.  
It follows a **Bronze → Silver → Gold** medallion architecture and leverages **Snowflake Cortex** to generate **AI-driven executive insights**.

The goal is to demonstrate real-world **data engineering, analytics, and AI integration** by transforming raw listing data into **business-ready KPIs and insights**.

---

## 🧱 Architecture & Data Flow
The project is designed using a layered architecture commonly used in production analytics systems:

- **Bronze Layer**  
  Raw data ingestion from CSV files into Snowflake internal stages and raw tables.

- **Silver Layer**  
  Data cleaning, type casting, deduplication, and data quality validation.

- **Gold Layer**  
  Business-ready analytics views and KPI marts.

- **AI Insights Layer**  
  Natural-language executive summaries generated using **Snowflake Cortex**.

---

## 🔧 Technology Stack
- **Snowflake (Snowsight)**
- **SQL**
- **Snowflake Cortex (AI)**
- **Internal Stages & COPY INTO**
- **GitHub (documentation & version control)**

## 📥 Data Ingestion (Bronze Layer)

A cleaned Toronto Airbnb listings dataset was uploaded as a CSV file into a Snowflake internal stage.
Data was loaded into a Bronze raw table with all columns stored as STRING.
Load validation and row-count checks were performed to ensure ingestion accuracy.

## 🧹 Data Transformation & Quality (Silver Layer)

In the Silver layer:
- Columns were type-cast using TRY_TO_NUMBER, TRY_TO_DECIMAL, and TRY_TO_DATE.
- Price values were normalized by removing currency symbols and commas.
- Empty strings were converted to NULL.
- Duplicate listing IDs were removed.

A Data Quality View was created to track:
- Missing values
- Invalid prices
- Geographic data completeness


## 📊 Business Analytics (Gold Layer)

The Gold layer contains analytics-ready views for decision-making:
- Market KPIs
- Total listings
- Total hosts
- Average and median price
- Average minimum nights
- Average annual availability

Performance Analysis
- Neighbourhood performance
- Room type performance
- Host concentration analysis

Best-value neighbourhoods (demand vs price)
- Premium vs high-demand neighbourhoods
- Executive Snapshot
- A single-row executive summary consolidating all key market metrics.


## 🤖 AI-Generated Insights (Snowflake Cortex)

Snowflake Cortex was used to generate natural-language executive summaries directly within Snowflake.

AI insights:
Convert KPIs into business-readable narratives
Highlight pricing, demand, and availability patterns
Are stored in structured tables for reuse and reporting

This demonstrates AI-assisted analytics without external tools.

## 🚀 Key Skills Demonstrated

- Cloud analytics with Snowflake
- Medallion architecture design
- SQL-based data transformations
- Data quality validation
- Business KPI modeling
- AI-driven insights using Snowflake Cortex
- Professional GitHub documentation


## 👤 Author

Jenil Gohel
Data Analytics | Snowflake | SQL | AI-Driven Insights
