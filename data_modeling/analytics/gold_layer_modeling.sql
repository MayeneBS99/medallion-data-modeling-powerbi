--star schema implementation


-- fact table : reservations_gold

USE BOOKINGS_DB;
GO

DROP TABLE IF EXISTS GOLD.fact_reservations;
GO 

WITH data as (
    SELECT RESERVATION_UUID,
    ROW_NUMBER() OVER(PARTITION BY CUSTOMER_UUID ORDER BY DT_DAY_BOOKING_DATE ASC, RESERVATION_UUID ASC) AS NET_CHANNEL_BOOKING_RANK
    FROM SILVER.reservations_silver
    WHERE IS_NET= 1 AND CHANNEL = 'TheFork Network'
),

data2 as (
    SELECT

    j.RESERVATION_UUID,

     ------- foreign keys and dates
    j.CUSTOMER_UUID,
    j.RESTAURANT_UUID,
    j.DT_DAY_BOOKING_DATE,
    j.DT_DAY_MEAL_DATE,
    
    ------- numeric fields
    j.AMT_REVENUE_EUR,
    j.AMT_REVENUE_USD,
    j.AMT_REVENUE_LOCAL,
    j.PARTY_SIZE,

    ------- descriptive fields
    j.IS_NET,
    j.CHANNEL,
    j.IS_ONLINE,
    j.IS_WALK_IN,
    j.LUNCH_TYPE,

    ---- new fields
    k.NET_CHANNEL_BOOKING_RANK
 

FROM SILVER.reservations_silver as j 
LEFT JOIN data as k on j.RESERVATION_UUID = k.RESERVATION_UUID
WHERE j.RESERVATION_UUID IS NOT NULL
)

SELECT *
INTO GOLD.fact_reservations
FROM data2;
GO


-------------------------------- Restaurants

DROP TABLE IF EXISTS GOLD.dim_restaurants;
GO 
SELECT DISTINCT
    RESTAURANT_UUID,
    RESTAURANT_CITY,
    RESTAURANT_COUNTRY   
INTO GOLD.dim_restaurants
FROM SILVER.reservations_silver
WHERE RESTAURANT_UUID IS NOT NULL ;
GO


-------------------------------- DATETIME

DROP TABLE IF EXISTS GOLD.dim_date;
GO 

WITH DateSequence AS (
    SELECT CAST('2022-01-01' AS DATE) AS DateValue

    UNION ALL
    
    SELECT DATEADD(day, 1, DateValue)
    FROM DateSequence
    WHERE DateValue < '2026-12-31'
)

SELECT
    DateValue AS date_day,
    YEAR(DateValue) AS year,
    MONTH(DateValue) AS month,
    DATENAME(month, DateValue) AS month_name,
    DATEPART(quarter, DateValue) AS quarter,
    DAY(DateValue) AS day_of_month,
    DATENAME(weekday, DateValue) AS day_name,
    DATEPART(weekday, DateValue) AS day_of_week
INTO GOLD.dim_date
FROM DateSequence
OPTION (MAXRECURSION 0); /* ajouter un commentaire*/
GO


---------------------------------- Customers

DROP TABLE IF EXISTS GOLD.dim_customers;
GO 

WITH data as (
    SELECT
    CUSTOMER_UUID,
    LOCALE_CODE,
    STATUS,
    CATEGORY
FROM SILVER.offline_customers_silver

UNION ALL

SELECT
    CUSTOMER_UUID,
    LOCALE_CODE,
    STATUS,
    CATEGORY
FROM SILVER.online_customers_silver
)

SELECT DISTINCT
    CUSTOMER_UUID,
    LOCALE_CODE,
    STATUS,
    CATEGORY
INTO GOLD.dim_customers
FROM data 
WHERE CUSTOMER_UUID is not null AND CUSTOMER_UUID in (
                            SELECT DISTINCT CUSTOMER_UUID 
                            FROM SILVER.reservations_silver
);

GO

select * from GOLD.fact_reservations;
select * from GOLD.dim_restaurants;
select * from GOLD.dim_date;
select * from GOLD.dim_customers;

select *
from GOLD.fact_reservations as j join GOLD.dim_customers as k on j.CUSTOMER_UUID = k.CUSTOMER_UUID
where k.CATEGORY = 'offline';