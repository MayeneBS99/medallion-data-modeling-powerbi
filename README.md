# 🍽️ Restaurant Bookings Data Warehouse & Analytics Pipeline

📌 Project Overview

This project end-to-end models and transforms raw restaurant booking and customer data into an analytics-ready Star Schema Data Warehouse using SQL Server (T-SQL) and Analytics Engineering best practices (Medallion Architecture: Bronze $\rightarrow$ Silver $\rightarrow$ Gold).The goal is to provide a clean, reliable, and performant data model to drive business insights around booking channels, revenue trends, customer behaviors, and restaurant performance.

🏗️ Architecture & Data Pipeline (Medallion Architecture)
The data pipeline is structured into three logical layers:

┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│  BRONZE LAYER   │ ───► │   SILVER LAYER   │ ───► │   GOLD LAYER    │
│  (Raw Ingestion)│      │(Cleaned & Typed) │      │  (Star Schema)  │
└─────────────────┘      └──────────────────┘      └─────────────────┘

1. 🥉 Bronze Layer (Raw Data)
Description: Contains raw, ingested data extracted directly from transactional source systems (online customers, offline customers, and reservations).

Characteristics: Preserves raw data structures without modifications.

2. 🥈 Silver Layer (Data Cleansing & Standardisation)
Description: Handles data cleaning, type casting, filtering, and standardisation.

Key Transformations:

Strict type casting (e.g., using TRY_CAST for safe numeric/date parsing and BIT for boolean flags like IS_NET, IS_ONLINE, IS_WALK_IN).

Deduplication and null-handling on primary identifiers (CUSTOMER_UUID, RESERVATION_UUID).

Consolidating data formats across online and offline customer feeds.

3. 🥇 Gold Layer (Dimensional Modeling / Star Schema)
Description: Business-ready data layer organized into a Star Schema optimized for analytical queries and BI tools like Power BI.

Design Principles:

Role-Playing Date Dimension: Independent, continuous calendar dimension (dim_date) linked to both meal dates (DT_DAY_MEAL_DATE) and booking dates (DT_DAY_BOOKING_DATE).

Degenerate Dimensions: Keeping direct transaction-level attributes (e.g., CHANNEL, IS_WALK_IN, LUNCH_TYPE) inside the fact table to avoid unnecessary snowflake schemas.

Unified Customer Dimension: Merging online and offline customer profiles via UNION ALL.

┌──────────────────┐
                        │  dim_customers   │
                        └────────┬─────────┘
                                 │ (1)
                                 │
                                 │ (N)
┌──────────────────┐    ┌────────┴─────────┐    ┌──────────────────┐
│ dim_restaurants  ├────┤fact_reservations ├────┤     dim_date     │
└──────────────────┘(1) (N)└────────┬─────────┘(N) (1)└──────────────────┘
                                 │ (N)
                                 │
                                 │ (1) [Inactive Relation]
                        ┌────────┴─────────┐
                        │     dim_date     │
                        └──────────────────┘


🚀 How to Run
Prerequisites: Ensure access to an active SQL Server instance with the database BOOKINGS_DB.

Execute Scripts in Order:

Run the Bronze layer setup/ingestion scripts.

Run SILVER_views_cleaning.sql to build cleaned Silver layer views.

Run GOLD_star_schema.sql to build the final Gold fact and dimension tables.

Connect to BI: Import the Gold layer tables into Power BI or Tableau and set up relationships between fact_reservations and dimensions.