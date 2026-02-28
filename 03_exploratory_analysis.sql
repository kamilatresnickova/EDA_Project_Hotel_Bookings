/*
* PROJECT:       Hotel Bookings Analysis
* SCRIPT:        03_exploratory_analysis.sql
* DESCRIPTION: 
* AUTHOR:        Kamila Třešničková
* DATE:          2026-02-28
*/

-- =============================================================================
-- 1. BUSINESS PERFORMANCE AND SEASONALITY ANALYSIS
-- =============================================================================

-- 1.1. General Overview of Bookings and Cancellations
SELECT hotel, 
       COUNT(*) AS total_bookings, 
       SUM(is_canceled) AS total_cancelled,
       ROUND(AVG(is_canceled) * 100, 2) AS cancellation_rate_pct
FROM hotel_bookings
GROUP BY hotel;

-- 1.2. Monthly Arrival Trends per Hotel
-- Total bookings per month (only non-cancelled)
SELECT hotel, 
       TO_CHAR(arrival_date, 'YYYY-MM') AS month_year, 
       COUNT(*) AS booking_count
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, month_year
ORDER BY hotel, month_year;

-- Identifying Average Monthly Bookings per Hotel
WITH MonthlyStats AS (
    SELECT hotel, 
           TO_CHAR(arrival_date, 'YYYY-MM') AS month_year, 
           COUNT(*) AS booking_count
    FROM hotel_bookings
    WHERE is_canceled = 0
    GROUP BY hotel, month_year)
SELECT hotel, ROUND(AVG(booking_count), 2) AS avg_monthly_bookings
FROM MonthlyStats
GROUP BY hotel;

-- Identifying Best and Worst Months per Hotel
WITH MonthlyStats AS (
    SELECT hotel, 
           TO_CHAR(arrival_date, 'YYYY-MM') AS month_year, 
           COUNT(*) AS booking_count
    FROM hotel_bookings
    WHERE is_canceled = 0
    GROUP BY hotel, month_year)
SELECT * FROM (
    SELECT *,
          RANK() OVER(PARTITION BY hotel ORDER BY booking_count DESC) as rank_max,
          RANK() OVER(PARTITION BY hotel ORDER BY booking_count ASC) as rank_min
    FROM MonthlyStats) sub
WHERE rank_max = 1 OR rank_min = 1
ORDER BY hotel, booking_count DESC;

-- Seasonal Baseline per Hotel (Aggregated months across all years)
SELECT hotel,
       arrival_date_month, 
       COUNT(*) AS total_arrivals, 
       ROUND(AVG(adr), 2) AS avg_adr
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, arrival_date_month
ORDER BY hotel, total_arrivals DESC;

-- 1.3. Arrivals by Day of the Week (total arrivals per weekday over the entire period)
SELECT hotel, 
    TO_CHAR(arrival_date, 'Day') AS day_of_week, 
    EXTRACT(DOW FROM arrival_date) AS day_num, 
    COUNT(*) AS total_arrivals
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, day_of_week, day_num
ORDER BY hotel, day_num;

-- 1.4. Financial Insights
-- Total Revenue and Average Daily Rate (ADR)
SELECT hotel,
    ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 0) AS total_revenue,
    ROUND(AVG(adr), 2) AS avg_adr,
    ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)) / COUNT(*), 2) AS avg_revenue_per_booking
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel;

--Monthly Revenue Stream per Hotel
SELECT hotel, 
       arrival_date_month,
       ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 0) AS monthly_revenue
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, arrival_date_month
ORDER BY hotel, monthly_revenue DESC;

-- 1.5. Length of Stay Analysis
SELECT hotel, 
       ROUND(AVG(stays_in_weekend_nights + stays_in_week_nights), 2) AS avg_length_of_stay
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel;

/* FINDINGS: 
- Data covers 26 months (July 2015 - Aug 2017).
- CITY HOTEL:
   - 79,162 total bookings, 41.79% cancellation rate.
   - Average: 1172 bookings/month.
   - Peak: May 2017 (2,331 arrivals).
   - Low: July 2015 (457 arrivals). 
   - Demand (seasonality): Peak in August (5,367 arrivals) and July. Relatively stable volume from March to October. Low demand in winter months (Nov-Feb).
   - Pricing (seasonality): Most expensive in May (120.67 €), not in the peak month of August. Significant price drop in winter months (Nov-Feb) with ADR around 80-90 €.  
   - Strongest days of week: Friday (7776 arrivals) and Monday (7243 arrivals). Lowest on Tuesday (5649 arrivals).   
   - Total revenue: 14,385,342 €
   - Average average daily rate (ADR): 106.04 €
   - Average revenue per booking: 312.15 €
   - Revenue: Peak in August (1.98M €) and July (1.69M €). Stability from March to October Revenue stays above 1M €. Low in January (0.53M €) – about 4x less than the August peak.
   - Average length of stay: 2.92 nights.
- RESORT HOTEL:
   - 40,046 total bookings, 27.77% cancellation rate.
   - Average: 1112 bookings/month.
   - Peak: October 2016 (1,417 arrivals).
   - Low: January 2016 (765 arrivals).
   - Demand (seasonality): Clear summer peak in August (3,257) and July. Significant drop in winter (Jan/Nov).
   - Pricing (seasonality): Extreme seasonal pricing. Significant difference in pricing between peak season (eg. August: 181.21 €) and off-season (eg. November: 48.71 €). 
   - Strongest days of week: Saturday (4730 arrivals) and Monday (4720 arrivals). Lowest on Sunday (3539 arrivals).
   - Total revenue: 11,601,634 €
   - Average average daily rate (ADR): 90.83 €
   - Average revenue per booking: 401.08 €
   - Revenue: Peak in August (2.94M €) and July (2.41M €). Extreme Seasonality: August revenue is 12x higher than January (0.25M €).
   - Average length of stay: 4.14 nights.
   */

-- =============================================================================
-- END OF BUSINESS PERFORMANCE AND SEASONALITY ANALYSIS
-- =============================================================================

-- =============================================================================
-- 2. CUSTOMER SEGMENTATION & BEHAVIOR ANALYSIS
-- =============================================================================

-- 2.1. Geographic segmentation
