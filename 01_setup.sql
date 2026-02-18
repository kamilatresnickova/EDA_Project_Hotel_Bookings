/*
* PROJECT:       Hotel Bookings analysis
* SCRIPT:        01_db_init.sql
* DESCRIPTION:   Initializes the schema and performs raw data ingestion. 
* Includes data integrity checks to verify successful import.
* AUTHOR:        Kamila Třešničková
* DATE:          2026-02-18
* DEPENDENCIES:  1. Raw dataset from Kaggle: https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand
* 2. Save the file as 'hotel_bookings.csv' in /Users/Shared/ (macOS) or your local postgres-accessible directory.
*/

-- =============================================================================
-- 1. ENVIRONMENT CLEANUP
-- =============================================================================
DROP TABLE IF EXISTS hotel_bookings;

-- =============================================================================
-- 2. SCHEMA DEFINITION
-- =============================================================================
CREATE TABLE hotel_bookings (
    hotel                          TEXT,
    is_canceled                    INT,
    lead_time                      INT,
    arrival_date_year              INT,
    arrival_date_month             TEXT,
    arrival_date_week_number       INT,
    arrival_date_day_of_month      INT,
    stays_in_weekend_nights        INT,
    stays_in_week_nights           INT,
    adults                         INT,
    children                       INT,
    babies                         INT,
    meal                           TEXT,
    country                        TEXT,
    market_segment                 TEXT,
    distribution_channel           TEXT,
    is_repeated_guest              INT,
    previous_cancellations         INT,
    previous_bookings_not_canceled INT,
    reserved_room_type             TEXT,
    assigned_room_type             TEXT,
    booking_changes                INT,
    deposit_type                   TEXT,
    agent                          TEXT,
    company                        TEXT,
    days_in_waiting_list           INT,
    customer_type                  TEXT,
    adr                            DECIMAL(10, 2),
    required_car_parking_spaces    INT,
    total_of_special_requests      INT,
    reservation_status             TEXT,
    reservation_status_date        DATE
);

-- =============================================================================
-- 3. DATA INGESTION
-- =============================================================================
-- Loading raw data from CSV. Handling 'NA' strings as NULL for numeric columns.
\copy hotel_bookings FROM '/Users/Shared/hotel_bookings.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', NULL 'NA');

-- =============================================================================
-- 4. DATA INTEGRITY CHECKS (INITIAL VERIFICATION)
-- =============================================================================
-- Verify total row count and hotel distribution
SELECT 
    COUNT(*) AS total_rows,
    COUNT(*) = 119390 AS is_count_correct,
    COUNT(CASE WHEN hotel = 'City Hotel' THEN 1 END) AS city_hotel_rows,
    COUNT(CASE WHEN hotel = 'Resort Hotel' THEN 1 END) AS resort_hotel_rows
FROM hotel_bookings;