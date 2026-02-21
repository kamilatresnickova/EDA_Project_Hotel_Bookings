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

-- 1.1 Checking "hotel" 
-- Finding: OK, only two distinct values 'Resort Hotel' and 'City Hotel'. No cleaning required.
SELECT DISTINCT hotel 
FROM hotel_bookings;


-- 1.2 Checking "arrival_date_month" 
-- Finding: OK, all 12 months are present. No missing categories. No cleaning required.
SELECT DISTINCT arrival_date_month 
FROM hotel_bookings;


-- 1.3 Checking "meal" 
-- Finding: Identified 'Undefined' values which do not match standard hotel industry codes.
SELECT DISTINCT meal 
FROM hotel_bookings;

-- Quantifying identified anomalies in "meal"
-- Total affected rows: 1,767.
-- Action: Further investigation needed to decide whether to remap to standard industry code or treat as NULL.
SELECT meal, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY meal;


-- 1.4 Checking "country" 
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


-- 1.5 Checking "market_segment"
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


-- 1.6 Checking "distribution_channel" 
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


-- 1.7 Checking "reserved_room_type" 
-- Finding: OK. Data is consistent, containing only 10 unique room codes (A, B, C, D, E, F, G, H, L, P). No cleaning required.
SELECT DISTINCT reserved_room_type 
FROM hotel_bookings;


-- 1.8 Checking "assigned_room_type" 
-- Finding: 12 unique codes found (compared to 10 in reserved_room_type).
-- Note: Rooms 'I' and 'K' appear in assigned types but not in reservations.
-- Conclusion: This is expected (likely complimentary upgrades or special assignments). No cleaning needed.
SELECT DISTINCT assigned_room_type 
FROM hotel_bookings;


-- 1.9 Checking "deposit_type" 
-- Finding: OK. 3 distinct values, consistent with hotel booking standards. No cleaning required.
SELECT DISTINCT deposit_type 
FROM hotel_bookings;   


-- 1.10 Checking "agent" 
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


-- 1.11 Checking "company" 
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


-- 1.12 Checking "customer_type" 
-- Finding: OK. Data is consistent and follows the expected 4 categories. No cleaning required.
SELECT DISTINCT customer_type 
FROM hotel_bookings;


-- 1.13 Checking "reservation_status" 
-- Finding: OK. Data is consistent and follows the expected 4 categories. No cleaning required.
SELECT DISTINCT reservation_status 
FROM hotel_bookings;

-- =============================================================================
-- NUMERICAL PROFILING - Checking for outliers and logical errors
-- =============================================================================

-- 1.14 Checking "is_canceled"
-- Finding: OK. Only binary values (0, 1) detected. No cleaning required.
-- Note: 0 = Not Canceled, 1 = Canceled.
SELECT DISTINCT is_canceled 
FROM hotel_bookings;


-- 1.15 Checking "lead_time"
-- Finding: OK. No negative values detected. No non-numerical values detected. No cleaning required.
-- Note: Values range from 0 up to 737 days (long-term bookings are present).
SELECT DISTINCT lead_time 
FROM hotel_bookings
ORDER BY lead_time;


-- 1.16 Checking "arrival_date_year"
-- Finding: OK. Only years 2015, 2016, and 2017 are present. No cleaning required.
SELECT DISTINCT arrival_date_year 
FROM hotel_bookings;


-- 1.17 Checking "arrival_date_week_number"
-- Finding: OK. Values range from 1 to 53. No cleaning required.
SELECT DISTINCT arrival_date_week_number 
FROM hotel_bookings
ORDER BY arrival_date_week_number;


-- 1.18 Checking "arrival_date_day_of_month"
-- Finding: OK. Values range from 1 to 31. No cleaning required.
SELECT DISTINCT arrival_date_day_of_month 
FROM hotel_bookings
ORDER BY arrival_date_day_of_month;


-- 1.19 Checking "stays_in_weekend_nights"
-- Finding: OK. Values range from 0 to 19. No cleaning required.
SELECT DISTINCT stays_in_weekend_nights 
FROM hotel_bookings
ORDER BY stays_in_weekend_nights;


-- 1.20 Checking "stays_in_week_nights"
-- Finding: OK. Values range from 0 to 50. No cleaning required.
SELECT DISTINCT stays_in_week_nights 
FROM hotel_bookings
ORDER BY stays_in_week_nights;


-- 1.21 Checking "adults"
-- Finding: Identified 0 adults and also extreme outliers (e.g., values up to 55).
-- Note: High values likely represent group bookings recorded as a single entity.
-- ACTION: Further investigation needed to determine whether to treat 0 adults as invalid (potentially remove) and how to handle extreme outliers (e.g., cap at a reasonable threshold or analyze separately).
SELECT DISTINCT adults 
FROM hotel_bookings
ORDER BY adults;

-- Quantifying 0 adults
-- Finding: Identified 403 rows with 0 adults. 
-- Action: Investigate if these rows contain children/babies. If total guests = 0, remove.
SELECT COUNT(*) AS frequency
FROM hotel_bookings 
WHERE adults = 0
GROUP BY adults;

-- Checking if "0 adults" rows have at least some children or babies
-- Finding: Out of 403 rows with 0 adults, 223 rows contain children or babies.
-- The remaining 180 rows have 0 total guests (adults + children + babies = 0).
-- ACTION: Rows with 0 total guests will be DELETED in the cleaning phase as they are logically invalid.
-- Rows with 0 adults but > 0 children will be kept for further business investigation.
SELECT adults, children, babies
FROM hotel_bookings
WHERE adults = 0 AND (children > 0 OR babies > 0);

-- Verification of "Ghost Bookings" (The ones to be deleted)
-- Finding: 180 rows with 0 total guests (adults + children + babies = 0) identified. These are logically invalid and will be removed in the cleaning phase.
SELECT COUNT(*) 
FROM hotel_bookings 
WHERE adults = 0 AND children = 0 AND babies = 0;

-- Quantifing extreme outliers
-- Finding: Identified 12 rows with extreme guest counts (ranging from 20 to 55 adults).
-- Specifics: Single instances of 40, 50, and 55 adults; small clusters for 20, 26, and 27.
-- Action: These represent massive group bookings. Will be kept for now, but noted as potential skew factors for average guest calculations.
SELECT adults, COUNT(*) AS frequency
FROM hotel_bookings
WHERE adults > 10
GROUP BY adults
ORDER BY adults DESC;


-- 1.22 Checking "children"
-- Finding: Identified 4 rows with NULL values (actual database NULLs). Other values range from 0 to 10. No negative values detected.
-- Action: NULL values will be replaced with 0 during the cleaning phase, assuming no children were present.
-- Note: 10 children is an outlier but theoretically possible for a group; no action needed.
SELECT children, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY children
ORDER BY children;


-- 1.23 Checking "babies"
-- Finding: OK. Values range from 0 to 10. 
-- Note: 10 babies is an outlier but theoretically possible for a group; no action needed.
SELECT babies, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY babies
ORDER BY babies;


-- 1.24 Checking "is_repeated_guest"
-- Finding: OK. Binary values (0, 1). No cleaning required.
-- Note: 0 = New guest, 1 = Returned guest.
SELECT DISTINCT is_repeated_guest 
FROM hotel_bookings;


-- 1.25 Checking "previous_cancellations"
-- Finding: OK. Numeric count of prior cancellations. Values range from 0 to 26. No negative values detected. No cleaning required.
-- Note: High values identify "problematic" customers. 
SELECT DISTINCT previous_cancellations 
FROM hotel_bookings 
ORDER BY previous_cancellations;

-- Quantifying distribution of previous cancellations
-- Finding: Majority of guests have 0 previous cancellations. 
-- High values (like 26) are rare but exist, indicating specific guest history.
SELECT previous_cancellations, COUNT(*) AS frequency
FROM hotel_bookings
WHERE previous_cancellations > 0
GROUP BY previous_cancellations
ORDER BY previous_cancellations DESC;

-- 1.26 Checking "previous_bookings_not_canceled"
-- Finding: OK. Numeric count of successful prior stays. Values range from 0 to 72. No negative values detected. No cleaning required.
-- Note: High values indicate very loyal repeat guests.
SELECT DISTINCT previous_bookings_not_canceled 
FROM hotel_bookings 
ORDER BY previous_bookings_not_canceled;


-- 1.27 Checking "booking_changes"
-- Finding: OK. Values represent number of modifications made. Values range from 0 to 21. No negative values detected. No cleaning required.
SELECT DISTINCT booking_changes
FROM hotel_bookings 
ORDER BY booking_changes DESC;

-- Quantifying frequency of changes
-- Finding: High values (up to 21) are rare but possible.
SELECT booking_changes, COUNT(*) AS frequency
FROM hotel_bookings
WHERE booking_changes > 0
GROUP BY booking_changes
ORDER BY booking_changes DESC;


-- 1.28 Checking "days_in_waiting_list"
-- Finding: OK. Values range from 0 to 391 days. No negative values detected. No cleaning required.
-- Note: High values represent peak seasons or overbooking management.
SELECT DISTINCT days_in_waiting_list 
FROM hotel_bookings 
ORDER BY days_in_waiting_list DESC;

-- Quantifying wait times
-- Finding: Majority of bookings have 0 days in waiting list.
SELECT days_in_waiting_list, COUNT(*) AS frequency
FROM hotel_bookings
WHERE days_in_waiting_list > 0
GROUP BY days_in_waiting_list
ORDER BY days_in_waiting_list DESC;


-- 1.29 Checking "required_car_parking_spaces"
-- Finding: OK. Values range from 0 to 8. No negative values detected. No cleaning required.
SELECT DISTINCT required_car_parking_spaces 
FROM hotel_bookings;

-- Quantifying parking space requirements
-- Finding: Majority of bookings require 0 parking spaces. High values (up to 8) are plausible for groups.
SELECT required_car_parking_spaces, COUNT(*) AS frequency
FROM hotel_bookings
GROUP BY required_car_parking_spaces
ORDER BY required_car_parking_spaces DESC;


-- 1.30 Checking "total_of_special_requests"
-- Finding: OK. Values range from 0 to 5. No negative values detected. No cleaning required.
SELECT DISTINCT total_of_special_requests 
FROM hotel_bookings 
ORDER BY total_of_special_requests DESC;


-- 1.31 Checking "adr" (Average Daily Rate)
-- Finding: Identified significant outliers and logical errors.
-- Low end: One negative value (-6.38) and zero values (potential complimentary stays).
-- High end: One extreme outlier of 5400.00, which is unrealistic for this dataset.
-- Action: Negative and extreme outlier values will be handled in the cleaning phase.
SELECT DISTINCT adr
FROM hotel_bookings
ORDER BY adr;

SELECT DISTINCT adr
FROM hotel_bookings
ORDER BY adr DESC;


-- Quantifying ADR issues
-- Finding: 1 row with negative ADR (-6.38).
-- Finding: 1959 rows with 0.00 ADR.
-- Finding: 1 row with extreme outlier (5400.00).
SELECT 
    CASE 
        WHEN adr < 0 THEN 'Negative ADR'
        WHEN adr = 0 THEN 'Zero ADR'
        WHEN adr > 1000 THEN 'Extreme Outlier (>1000)'
        ELSE 'Normal ADR'
    END AS adr_category,
    COUNT(*) AS frequency
FROM hotel_bookings
WHERE adr < 0 OR adr = 0 OR adr > 1000
GROUP BY adr_category;

-- 1.32 Checking "reservation_status_date"
-- Finding: OK. Dates range from 2014-10-17 to 2017-09-14. No cleaning required. 
-- Note: No future dates or invalid years detected.
SELECT DISTINCT reservation_status_date
FROM hotel_bookings
ORDER BY reservation_status_date;

-- =============================================================================
-- END OF DATA PROFILING
-- =============================================================================


-- =============================================================================
-- 2. DATA CLEANING - Applying fixes based on profiling findings
-- =============================================================================

-- 2.1. Cleaning "meal" 
-- Note: 'Undefined' values (1,767 rows) are being remapped to 'SC' (Self Catering).
-- RATIONALE: Based on dataset documentation and common hotel industry practices, 
-- 'Undefined' and 'SC' are often used interchangeably for bookings without pre-booked meals.
-- In a real-world scenario, this would be verified with the Hotel Management.

UPDATE hotel_bookings
SET meal = 'SC'
WHERE meal = 'Undefined';

-- Verification:
-- Returns 0 rows for 'Undefined'.
SELECT meal, COUNT(*) 
FROM hotel_bookings 
WHERE meal = 'Undefined'
GROUP BY meal;


-- 2.2. Cleaning "country" column
-- Note: Replacing text string 'NULL' (488 rows) with actual database NULL values.
-- Note: Standardizing 2-letter code 'CN' (1,279 rows) to 3-letter ISO code 'CHN'.
-- RATIONALE: To ensure data consistency and prevent 'NULL' from being treated as a valid country name.
-- In a real-world scenario, the 'CN' to 'CHN' mapping and the missing country data 
-- would be verified with the system administrator or management.

-- Fixing the 'NULL' string to real NULL
UPDATE hotel_bookings
SET country = NULL
WHERE country = 'NULL';

-- Standardizing China's country code
UPDATE hotel_bookings
SET country = 'CHN'
WHERE country = 'CN';

-- Verification:
SELECT country, COUNT(*) 
FROM hotel_bookings 
WHERE country IS NULL OR country = 'CN' OR country = 'NULL'
GROUP BY country;


-- 2.3. Cleaning "market_segment" and "distribution_channel"
-- Note: Replacing 'Undefined' values with actual NULLs.
-- RATIONALE: Only a tiny fraction of rows (2 for market_segment, 5 for distribution_channel) are affected. 
-- In practice, these would be flagged to management, but for analysis, NULL is the safest representation of missing data.

-- Fixing market_segment
UPDATE hotel_bookings
SET market_segment = NULL
WHERE market_segment = 'Undefined';

-- Fixing distribution_channel
UPDATE hotel_bookings
SET distribution_channel = NULL
WHERE distribution_channel = 'Undefined';

-- Verification:
SELECT market_segment, distribution_channel
FROM hotel_bookings
WHERE market_segment IS NULL OR distribution_channel IS NULL


-- 2.4. Cleaning "agent" and "company" columns
-- Note: Replacing text string 'NULL' with actual database NULL values.
-- RATIONALE: These columns contain IDs. String 'NULL' prevents numeric calculations 
-- and distorts counts of direct bookings (bookings without an agent/company).

UPDATE hotel_bookings
SET agent = NULL
WHERE agent = 'NULL';

UPDATE hotel_bookings
SET company = NULL
WHERE company = 'NULL';

-- Verification (should see a lot of real NULLs now):
SELECT COUNT(*) 
FROM hotel_bookings 
WHERE agent IS NULL OR company IS NULL;

-- Verification (should see no string 'NULL' values now):
SELECT COUNT(*) 
FROM hotel_bookings 
WHERE agent = 'NULL' OR company = 'NULL';

-- 2.5. Cleaning "adults", "children", and "babies" (Guest counts)
-- RATIONALE: 
-- 1. Ghost Bookings: 180 rows with 0 total guests are logically invalid and will be removed.
-- 2. NULLs in Children: 4 rows identified with actual NULL values will be set to 0.
-- 3. 0 Adults with Children: Kept as is, as they represent valid occupied rooms (likely connected bookings).
-- 4. Extreme Outliers: Kept as they represent group bookings.

-- Delete Ghost Bookings (the 180 'ghosts')
-- Confirmed during profiling: adults = 0, children = 0, babies = 0.
DELETE FROM hotel_bookings
WHERE adults = 0 
  AND (children = 0 OR children IS NULL) 
  AND (babies = 0 OR babies IS NULL);

-- Fix NULLs in children
UPDATE hotel_bookings
SET children = 0
WHERE children IS NULL;

-- Verification:
-- Should return 0.
SELECT COUNT(*) 
FROM hotel_bookings 
WHERE (COALESCE(adults,0) + COALESCE(children,0) + COALESCE(babies,0)) = 0;


-- 2.6. Cleaning "adr" (Average Daily Rate)
-- RATIONALE: 
-- 1. Negative ADR (-6.38): Logically impossible. Removing 1 row as it is a clear system error.
-- 2. Extreme Outlier (5400.00): A single value far beyond the normal range (avg ~100). 
-- Removing this 1 row to prevent distortion of revenue and average price analysis.
-- 3. Zero ADR: 1,959 rows are kept. These represent 'Complimentary' stays (promotions, guests of the house). 
-- Removing them would distort occupancy rates.

DELETE FROM hotel_bookings
WHERE adr < 0 OR adr > 5000;

-- Verification:
-- Should return 0.
SELECT COUNT(*) 
FROM hotel_bookings 
WHERE adr < 0 OR adr > 5000;

-- =============================================================================
-- END OF DATA CLEANING
-- =============================================================================


-- =============================================================================
-- DATA TRANSFORMATION
-- =============================================================================
-- 2.7. Creating a unified arrival_date column
-- RATIONALE: To enable time-series analysis, we need a proper DATE type column instead of three separate parts (year, month, day).
-- Note: Using a CASE statement to map text months to their numeric equivalents.

-- Adding the new column
ALTER TABLE hotel_bookings ADD COLUMN arrival_date DATE;

-- B) Populating the new column with formatted data
UPDATE hotel_bookings
SET arrival_date = CAST(
    arrival_date_year || '-' || 
    CASE 
        WHEN arrival_date_month = 'January'   THEN '01'
        WHEN arrival_date_month = 'February'  THEN '02'
        WHEN arrival_date_month = 'March'     THEN '03'
        WHEN arrival_date_month = 'April'     THEN '04'
        WHEN arrival_date_month = 'May'       THEN '05'
        WHEN arrival_date_month = 'June'      THEN '06'
        WHEN arrival_date_month = 'July'      THEN '07'
        WHEN arrival_date_month = 'August'    THEN '08'
        WHEN arrival_date_month = 'September' THEN '09'
        WHEN arrival_date_month = 'October'   THEN '10'
        WHEN arrival_date_month = 'November'  THEN '11'
        WHEN arrival_date_month = 'December'  THEN '12'
    END || '-' || 
    LPAD(arrival_date_day_of_month::text, 2, '0') AS DATE
);

-- Verification:
-- Checking if the new column is correctly populated (first 10 rows).
SELECT arrival_date_year, arrival_date_month, arrival_date_day_of_month, arrival_date
FROM hotel_bookings
LIMIT 10;

-- =============================================================================
-- END OF DATA TRANSFORMATION
-- =============================================================================