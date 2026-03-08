/*
* PROJECT:       Hotel Bookings Analysis
* SCRIPT:        04_data_preparation.sql
* DESCRIPTION:   Data preparation for BI import. 
* AUTHOR:        Kamila Třešničková
* DATE:          2026-03-07
*/

-- =============================================================================
-- FINAL TABLE FOR POWER BI IMPORT
-- =============================================================================

-- Drop if exists to allow re-runs
DROP TABLE IF EXISTS hotel_bookings_final;

CREATE TABLE hotel_bookings_final AS
SELECT 
    -- 1. IDENTIFIERS & CATEGORIES
        hotel,
        is_canceled,
        TO_DATE(CONCAT(arrival_date_year, '-', arrival_date_month, '-', arrival_date_day_of_month), 'YYYY-Month-DD') AS arrival_date_full,
        arrival_date_year,
        arrival_date_month,
        arrival_date_week_number,
        arrival_date_day_of_month,
    
    -- 2. STAY DETAILS (Keeping raw columns for flexibility)
        stays_in_weekend_nights,
        stays_in_week_nights,
        (stays_in_weekend_nights + stays_in_week_nights) AS total_stay_nights,
    
    -- 3. GUEST DEMOGRAPHICS
        adults,
        children,
        babies,
        CASE 
            WHEN children > 0 OR babies > 0 THEN 'Family' 
            ELSE 'No Children' 
        END AS guest_segment,
        meal,
        country,
    
    -- 4. BOOKING DETAILS
        market_segment,
        distribution_channel,
        is_repeated_guest,
        previous_cancellations,
        previous_bookings_not_canceled,
        reserved_room_type,
        assigned_room_type,
        CASE 
            WHEN reserved_room_type = assigned_room_type THEN 0 
            ELSE 1 
        END AS is_upgraded,
    
    -- 5. OPERATIONS & REVENUE
        booking_changes,
        deposit_type,
        agent,       
        company,     
        days_in_waiting_list,
        customer_type,
        adr,
        CASE 
            WHEN is_canceled = 0 THEN adr * (stays_in_weekend_nights + stays_in_week_nights) 
            ELSE 0 
        END AS revenue_actual,
        required_car_parking_spaces,
        total_of_special_requests,
    
    -- 6. STATUS & TIME SEGMENTS
        reservation_status,      -- Vracíme zpět
        reservation_status_date, -- Vracíme zpět
        lead_time,
        CASE 
            WHEN lead_time <= 7 THEN '01. Last Minute (0-7 days)'
            WHEN lead_time <= 30 THEN '02. Short Term (8-30 days)'
            WHEN lead_time <= 90 THEN '03. Medium Term (31-90 days)'
            WHEN lead_time <= 180 THEN '04. Long Term (91-180 days)'
        ELSE '05. Very Long Term (180+ days)'
        END AS lead_time_group

FROM hotel_bookings
WHERE market_segment IS NOT NULL; -- Filters out those 2 'Undefined' rows we found during EDA for cleaner analysis.

-- Quick check of the final table
SELECT * FROM hotel_bookings_final LIMIT 5;
SELECT COUNT(*) FROM hotel_bookings_final;

-- =============================================================================
-- END OFFINAL TABLE FOR POWER BI IMPORT
-- =============================================================================

-- =============================================================================
-- DATE DIMENSION TABLE FOR POWER BI IMPORT
-- =============================================================================

DROP TABLE IF EXISTS dim_calendar;

CREATE TABLE dim_calendar AS
SELECT
    -- Tento sloupec "calendar_date" propojíme v Power BI 
    -- s tvým sloupcem "arrival_date_full"
    generated_day AS calendar_date, 
    
    EXTRACT(YEAR FROM generated_day) AS year,
    EXTRACT(MONTH FROM generated_day) AS month_num,
    TO_CHAR(generated_day, 'TMMonth') AS month_name, 
    EXTRACT(QUARTER FROM generated_day) AS quarter,
    EXTRACT(WEEK FROM generated_day) AS week_of_year,
    CASE 
        WHEN EXTRACT(DOW FROM generated_day) IN (0, 6) THEN 'Weekend' 
        ELSE 'Weekday' 
    END AS day_type,
    TO_CHAR(generated_day, 'Day') AS day_name
FROM generate_series(
    '2015-01-01'::date, 
    '2017-12-31'::date, 
    '1 day'::interval
) AS generated_day; 

SELECT * FROM dim_calendar LIMIT 5;

-- =============================================================================
-- END OF DATE DIMENSION TABLE FOR POWER BI IMPORT
-- =============================================================================

-- =============================================================================
-- COUNTRY DIMENSION TABLE FOR POWER BI IMPORT
-- =============================================================================

DROP TABLE IF EXISTS dim_countries;

CREATE TABLE dim_countries AS
SELECT DISTINCT 
    country AS country_code
FROM hotel_bookings
WHERE country IS NOT NULL;

SELECT * FROM dim_countries LIMIT 5;

-- =============================================================================
-- END OF COUNTRY DIMENSION TABLE FOR POWER BI IMPORT
-- =============================================================================

-- =============================================================================
-- HOTEL DIMENSION TABLE FOR POWER BI IMPORT
-- =============================================================================

DROP TABLE IF EXISTS dim_hotels;

CREATE TABLE dim_hotels AS
SELECT DISTINCT 
    hotel AS hotel_name
FROM hotel_bookings;

SELECT * FROM dim_hotels;

-- =============================================================================
-- END OF HOTEL DIMENSION TABLE FOR POWER BI IMPORT
-- =============================================================================

-- =============================================================================
-- MARKET SEGMENT DIMENSION TABLE
-- =============================================================================

DROP TABLE IF EXISTS dim_market_segments;

CREATE TABLE dim_market_segments AS
SELECT DISTINCT 
    market_segment
FROM hotel_bookings
WHERE market_segment IS NOT NULL;

SELECT * FROM dim_market_segments;

-- =============================================================================
-- END OF MARKET SEGMENT DIMENSION TABLE
-- =============================================================================
