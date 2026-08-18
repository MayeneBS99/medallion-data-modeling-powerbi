-- Data ingestion : Database creation using SQL Server

USE BOOKINGS_DB;
GO

CREATE SCHEMA BRONZE;
GO
CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO


---- Table creations
DROP TABLE IF EXISTS BRONZE.offline_customers;
CREATE TABLE BRONZE.offline_customers (
    CUSTOMER_UUID varchar(60),
    ONLINE_CUSTOMER_UUID varchar(60),
    LOCALE varchar(60),
    STATUS varchar(60),
    TS_CRE varchar(90),
    TS_UPD varchar(90)
);
GO

DROP TABLE IF EXISTS BRONZE.online_customers;
CREATE TABLE BRONZE.online_customers (
    CUSTOMER_UUID varchar(60),
    STATUS varchar(60),
    LOCALE_CODE varchar(60),
    TS_CRE varchar(90),
    TS_UPD varchar(90),
   
);
GO

DROP TABLE IF EXISTS BRONZE.reservations;
CREATE TABLE BRONZE.reservations (
    CUSTOMER_UUID varchar(90),
    DT_DAY_BOOKING_DATE varchar(90),
    DT_DAY_MEAL_DATE varchar(90),
    AMT_REVENUE_EUR varchar(90),
    AMT_REVENUE_USD varchar(90),
    AMT_REVENUE_LOCAL varchar(90),
    IS_NET varchar(90),
    CHANNEL varchar(90),
    RESERVATION_UUID varchar(90),
    RESTAURANT_UUID varchar(90),
    RESTAURANT_CITY varchar(90),
    RESTAURANT_COUNTRY varchar(90),
    IS_ONLINE varchar(90),
    PARTY_SIZE varchar(90),
    IS_WALK_IN varchar(90),
    LUNCH_TYPE varchar(90),
    TS_CRE varchar(90),
    TS_UPD varchar(90)
);
GO

--- Data ingestion

BULK INSERT BRONZE.offline_customers 
FROM 'C:\Users\mayen\ML_DL_PROJECTS\medallion-data-modeling-powerbi\data\raw\offline_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

BULK INSERT BRONZE.online_customers 
FROM 'C:\Users\mayen\ML_DL_PROJECTS\medallion-data-modeling-powerbi\data\raw\online_customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

BULK INSERT BRONZE.reservations 
FROM 'C:\Users\mayen\ML_DL_PROJECTS\medallion-data-modeling-powerbi\data\raw\reservations.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
GO

------------------------------
/* 
offline customer
changer le Null de LOCALE en quelque chose de diff
selectionner les lignes pour lesquel online customer est null et customer id not null
changer le nom LOCALE en LOCALE_CODE
*/
select *
from bronze.online_customers;

select STATUS, count(*)
from bronze.online_customers
group by STATUS;

select MAX(DT_DAY_MEAL_DATE) from bronze.reservations;