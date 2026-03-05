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

-- 2.1. Geographic segmentation - Top 5 countries by revenue share per hotel

-- STEP 1: Revenue calculation per country and hotel
WITH HotelRevenue AS (
    SELECT 
        hotel,
        country,
        ROUND(SUM(adr * (stays_in_weekend_nights + stays_in_week_nights)), 0) AS total_revenue,
        COUNT(*) AS booking_count
    FROM hotel_bookings
    WHERE is_canceled = 0
    GROUP BY hotel, country
)
-- STEP 2: Calculate revenue share and rank countries
SELECT * FROM (
    SELECT 
        hotel,
        country,
        total_revenue,
        booking_count,
        ROUND(total_revenue::numeric / SUM(total_revenue) OVER(PARTITION BY hotel) * 100, 2) AS revenue_share_pct,
        RANK() OVER(PARTITION BY hotel ORDER BY total_revenue DESC) as revenue_rank
    FROM HotelRevenue
) sub
WHERE revenue_rank <= 5
ORDER BY hotel, revenue_rank;

--2.2. Customer Segmentation - Families vs. Guests without Children

SELECT 
    hotel,
    CASE 
        WHEN children > 0 OR babies > 0 THEN 'Family'
        ELSE 'No Children'
    END AS guest_segment,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr), 2) AS avg_daily_rate,
    ROUND(AVG(stays_in_weekend_nights + stays_in_week_nights), 2) AS avg_length_of_stay
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, guest_segment
ORDER BY hotel, guest_segment;


-- 2.3. Room Upgrades Analysis - percentage of guests receiving a different room type than reserved (assigned vs. reserved)
SELECT 
    hotel,
    CASE 
        WHEN reserved_room_type = assigned_room_type THEN 'Match'
        ELSE 'Upgrade/Change'
    END AS room_assignment,
    COUNT(*) AS total_bookings,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER(PARTITION BY hotel) * 100, 2) AS share_pct
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, room_assignment
ORDER BY hotel, share_pct DESC;

-- 2.4. Revenue and ADR by Market Segment 
SELECT 
    hotel,
    market_segment,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr), 2) AS avg_adr,
    ROUND(AVG(lead_time), 0) AS avg_lead_time_days
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, market_segment
ORDER BY hotel, total_bookings DESC

-- 2.5. Revenue and ADR by Repeated Guests
SELECT 
    hotel,
    is_repeated_guest,
    COUNT(*) AS total_bookings,
    ROUND(AVG(adr), 2) AS avg_adr,
    ROUND(AVG(previous_cancellations), 2) AS avg_prev_cancellations
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, is_repeated_guest;

-- 2.6. Meal Plan Preferences 
SELECT 
    hotel,
    meal,
    COUNT(*) AS count_bookings,
    ROUND(COUNT(*)::numeric / SUM(COUNT(*)) OVER(PARTITION BY hotel) * 100, 2) AS share_pct
FROM hotel_bookings
WHERE is_canceled = 0
GROUP BY hotel, meal
ORDER BY hotel, share_pct DESC;


/* FINDINGS: 
- CITY HOTEL:
   - Revenue share: Financial Leader FRA with 17.57% revenue share, surpassing PRT despite having fewer bookings (7,069 vs 10,793).
   - Top 5 countries by revenue share: FRA, PRT, DEU, GBR, and ESP.
   - Guest demographics: Families pay significantly more (146.76) than guests without children (102.65). That is a 43% price premium.
   - Stay Duration: Families stay slightly longer (3.10 nights vs 2.90 nights).
   - Room Upgrades: 85.55% of guests received the exact room type they booked, 14.45% of guests experienced a change.
   - Market Segment: Volume Leader: Online TA (24,192 bookings), Profitability Leader: Direct (119.83 ADR), Planning Leader: Groups & Offline TA (122 days),Planning Loser: Aviation (4 days),Lowest Yield: Corporate (82.07 ADR).
   - Repeated Guests: Small minority of the business (1,538 bookings, approx. 3.3% of the total).
   - Pricing strategy: Repeated guests pay a much lower ADR (63.79 €) compared to new guests (107.49 €), a decrease of 40%.
   - Cancellation Behavior: Repeated guests have quite high history of previous cancellations, averaging 0.63 per guest.
   - Meal Plan Preferences: BB (Bed & Breakfast) is the primary choice at 77.19%, secondary choice is SC (Self Catering) with 14.17% share, FB (Full Board) is practically non-existent (0.02%).
- RESORT HOTEL:
   - Revenue share: financial Leader PRT with 28.57% revenue share, but GBR is a very close second with 24.24% share.
   - Efficiency Gap: GBR generates nearly the same revenue as PRT but with only 5,921 bookings compared to PRT's 10,184. 
   - Top 5 countries by revenue share: PRT, GBR, ESP, IRL, and FRA.
   - Guest demographics: Families have significantly higher ADR of 151.90, while guests without children pay only 84.97. 
     Families pay nearly DOUBLE (+78%).
   - Stay Duration: Families represent the longest stays in the entire dataset (4.41 nights on average, comapred to 4.12 nights for guests without children).
   - Room Upgrades: 74.65% of guests received the exact room type they booked, 25.35% of guests experienced a change. 
   - Market Segment: Volume Leader: Online TA (11,481 bookings), Profitability Leader: Direct (108.99 ADR), Planning Leader: Groups (162 days), Planning Loser: Corporate (16 days), Lowest Yield: Corporate (49.61 ADR)
   - Repeated Guests: Slightly higher loyalty rate with 1,666 bookings of repeated guests (approx. 5.8% of the total).
   - Pricing Strategy: Repeated guests pay a lower ADR (64.02 €) compared to first-time visitors (92.46 €).
   - Cancellation Behavior: Much cleaner cancelation history (0.07) compared to their counterparts in the City Hotel.
   - Meal Plan Preferences: BB is the primary choice at 76.61%. Resort Specifics: HB (Half Board) is significantly higher here (19.01%) compared to the City Hotel. While still a niche, FB is much more relevant (1.08%).
   
   */