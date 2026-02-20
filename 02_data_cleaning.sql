/*
* PROJECT:       Hotel Bookings Analysis
* SCRIPT:        02_data_cleaning.sql
* DESCRIPTION:  
* AUTHOR:        Kamila Třešničková
* DATE:          2026-02-19
*/

-- =============================================================================
-- 1. DATA PROFILING TEXT COLUMS - Checking unique values to identify missing categories or inconsistency
-- =============================================================================

-- 1. Checking "hotel" 
-- Finding: OK, only two distinct values 'Resort Hotel' and 'City Hotel'. No cleaning required.
SELECT DISTINCT hotel 
FROM hotel_bookings;


-- 2. Checking "arrival_date_month" 
-- Finding: OK, all 12 months are present. No missing categories. No cleaning required.
SELECT DISTINCT arrival_date_month 
FROM hotel_bookings;


-- 3. Checking "meal" 
-- Finding: Identified 'Undefined' values which do not match standard hotel industry codes.
SELECT DISTINCT meal 
FROM hotel_bookings;

-- Quantifying identified anomalies in "meal"
-- Total affected rows: 1,767.
-- Action: Further investigation needed to decide whether to remap to standard industry code or treat as NULL.
SELECT meal, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY meal;


-- 4. Checking "country" 
-- Finding: 178 unique rows indentified
SELECT DISTINCT country
FROM hotel_bookings;

-- Checking for inconsistent values in "country" column
-- Checking for inconsistent or invalid country code lengths (should be 3 characters)
-- Finding: Identified rows with invalid country codes (length not equal to 3) - "CN" and NULL values. 
-- Action: These may require correction or removal depending on the context of the analysis.
SELECT DISTINCT country, LENGTH(country) as code_length
FROM hotel_bookings
WHERE LENGTH(country) <> 3;

-- Quantifying identified anomalies in "country"
-- Finding: 488 rows with text 'NULL' and 1,279 rows with 'CN' (Alpha-2 code).
-- Total affected rows: 1,767.
SELECT country, COUNT(*) AS frequency
FROM hotel_bookings
WHERE country IN ('CN', 'NULL')
GROUP BY country;


-- 5. Checking "market_segment"
-- Finding: Identified 'Undefined' values. 
SELECT DISTINCT market_segment 
FROM hotel_bookings;

-- Quantifying identified anomalies in "market_segment"
-- Total affected rows: 2.
-- Conclusion: Statistically insignificant. 
-- Decision: Will be handled as NULL or removed in the cleaning phase.
SELECT market_segment, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY market_segment
ORDER BY frequency DESC;


-- 6. Checking "distribution_channel" 
-- Finding: Identified 'Undefined' values.
SELECT DISTINCT distribution_channel 
FROM hotel_bookings;

-- Quantifying identified anomalies in "distribution_channel"
-- Total affected rows: 5.
-- Conclusion: Statistically insignificant. 
-- Decision: Will be handled as NULL or removed in the cleaning phase.
SELECT distribution_channel, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY distribution_channel
ORDER BY frequency DESC;


-- 7. Checking "reserved_room_type" 
-- Finding: OK. Data is consistent, containing only 10 unique room codes (A, B, C, D, E, F, G, H, L, P). No cleaning required.
SELECT DISTINCT reserved_room_type 
FROM hotel_bookings;


-- 8. Checking "assigned_room_type" 
-- Finding: 12 unique codes found (compared to 10 in reserved_room_type).
-- Note: Rooms 'I' and 'K' appear in assigned types but not in reservations.
-- Conclusion: This is expected (likely complimentary upgrades or special assignments). No cleaning needed.
SELECT DISTINCT assigned_room_type 
FROM hotel_bookings;


-- 9. Checking "deposit_type" 
-- Finding: OK. 3 distinct values, consistent with hotel booking standards. No cleaning required.
SELECT DISTINCT deposit_type 
FROM hotel_bookings;   


-- 10. Checking "agent" 
-- Finding: Contains ID numbers as strings. Identified 'NULL' values.
SELECT DISTINCT agent 
FROM hotel_bookings 
ORDER BY agent DESC;

-- Quantifying identified anomalies in "agent"
-- Total affected rows: 16340.
-- ACTION: Replace the string 'NULL' with a real database NULL value during data cleaning.
-- RATIONALE: Rows with no agent ID are logically inferred as direct bookings.
SELECT agent, COUNT(*) AS frequency
FROM hotel_bookings
WHERE agent = 'NULL'
GROUP BY agent;


-- 11. Checking "company" 
-- Finding: Contains ID numbers as strings. Identified 'NULL' values.
SELECT DISTINCT company 
FROM hotel_bookings
ORDER BY company DESC;

-- Quantifying identified anomalies in "company"
-- Total affected rows: 112593.
-- ACTION: Replace the string 'NULL' with a real database NULL value.
-- RATIONALE: The 'NULL' string represents private bookings (not associated with a company).
SELECT company, COUNT(*) AS frequency
FROM hotel_bookings
WHERE company = 'NULL'
GROUP BY company;


-- 12. Checking "customer_type" 
-- Finding: OK. Data is consistent and follows the expected 4 categories. No cleaning required.
SELECT DISTINCT customer_type 
FROM hotel_bookings;


-- 13. Checking "reservation_status" 
-- Finding: OK. Data is consistent and follows the expected 4 categories. No cleaning required.
SELECT DISTINCT reservation_status 
FROM hotel_bookings;

-- =============================================================================
-- 1.2. NUMERICAL PROFILING - Checking for outliers and logical errors
-- =============================================================================

-- 14. Checking "is_canceled"
-- Finding: OK. Only binary values (0, 1) detected. No cleaning required.
-- Note: 0 = Not Canceled, 1 = Canceled.
SELECT DISTINCT is_canceled 
FROM hotel_bookings;


-- 15. Checking "lead_time"
-- Finding: OK. No negative values detected. No cleaning required.
-- Note: Values range from 0 up to 737 days (long-term bookings are present).
SELECT DISTINCT lead_time 
FROM hotel_bookings
ORDER BY lead_time;