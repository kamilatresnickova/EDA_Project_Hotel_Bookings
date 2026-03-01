# EDA_Project_Hotel_Bookings
WORK IN PROGRESS - A data-driven SQL and PowerBI project focused on auditing, cleaning, and analyzing over 119k hotel booking records to uncover customer behavior patterns and optimize revenue insights.

---

## Business Case
The primary goal of this project is to perform a comprehensive Exploratory Data Analysis (EDA) on a dataset containing booking records from two distinct hotel types. 

By analyzing this data, I aim to uncover business performance and seasonality insights, customer behavioral patterns, identify key drivers behind booking cancellations, and analyze operational insights.

### Key Questions

1. Business Performance & Seasonality

*Which months experience the highest demand and generate the most revenue?*

*How do total revenue and occupancy rates fluctuate between the two hotel types over the years?*

*Which days of the week are most frequent for guest arrivals?*

2. Customer Segmentation & Behavior

*How do guest demographics (families vs. individuals) impact the Average Daily Rate (ADR) and length of stay?*

*Which countries represent the top 10 most valuable markets in terms of guest volume and total revenue?*

*How often do guests receive room upgrades (reserved vs. assigned room types)?*

3. Cancellation Analysis

*What is the cancellation rate across different hotel types?*

*Does a longer lead time (time between booking and arrival) correlate with a higher cancellation probability?*

*How effective are different deposit types (No Deposit vs. Non-Refundable) in securing bookings?*

4. Operational Insights

*Do special requests or the need for parking spaces correlate with lower cancellation rates?*

*How does the behavior of repeated guests differ from first-time visitors in terms of loyalty and revenue?*





### Dataset Overview
The data is sourced from Kaggle ([Hotel Booking Demand Dataset](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand?resource=download)). It contains 119,390 records spanning from July 2015 to August 2017.
The dataset focuses on:  
*City Hotel:* An urban hotel setting.  
*Resort Hotel:* A holiday resort setting.

## Technical Implementation  
*Database Environment:* Set up a local PostgreSQL 18 database on macOS.  
*Schema Design:* Created the hotel_bookings table using optimized data types (TEXT, INT, DECIMAL, and DATE).  

## Data Profiling 
Performed a deep dive into the dataset’s 32 columns to assess data quality and logical consistency.

*Anomalies Detected:* Identified 180 "Ghost Bookings" (0 total guests), inconsistent country codes (ISO-2 vs ISO-3), and extreme ADR outliers (e.g., negative values and a single entry of 5,400).

*Null Value Analysis:* Quantified missing data in agent, company, and children columns to prepare for systematic cleaning.

## Data Cleaning & Transformation 
Developed a robust SQL cleaning script to ensure the dataset is "analysis-ready."

*Data Sanitization:* Replaced text-based 'NULL' strings with actual database NULL values and standardized categorical data (e.g., remapping Undefined meals to SC).

*Integrity Enforcement:* Removed logically invalid records (0 guests) and corrected pricing errors to prevent skewed averages.

*Feature Engineering:* Transformed separate year, month, and day columns into a unified arrival_date (DATE type) using a custom mapping and casting logic to enable time-series analysis.
