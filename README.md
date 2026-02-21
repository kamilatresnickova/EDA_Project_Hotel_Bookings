# EDA_Project_Hotel_Bookings
WORK IN PROGRESS - Portfolio Project focused on hotel bookings analysis using SQL and PowerBI. 

---

## Business Case
The primary goal of this project is to perform a comprehensive Exploratory Data Analysis (EDA) on a dataset containing booking records from two distinct hotel types. By analyzing this data, I aim to uncover customer behavioral patterns, identify key drivers behind booking cancellations, and analyze pricing strategies.

### Key Questions
*What is the cancellation rate across different hotel types?*  
*Which months experience the highest demand and generate the most revenue?*  
*How do guest demographics (families vs. individuals) impact the Average Daily Rate (ADR)?*  
*Does a longer lead time (time between booking and arrival) correlate with a higher cancellation probability?*  

### Dataset Overview
The data is sourced from Kaggle ([Hotel Booking Demand Dataset](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand?resource=download)). It contains 119,390 records spanning from July 2015 to August 2017.
The dataset focuses on:  
*City Hotel:* An urban hotel setting.  
*Resort Hotel:* A holiday resort setting.

## Technical Implementation  
*Database Environment:* Set up a local PostgreSQL 18 database on macOS.  
*Schema Design:* Created the hotel_bookings table using optimized data types (TEXT, INT, DECIMAL, and DATE).  

### Data Profiling 
Performed a deep dive into the dataset’s 32 columns to assess data quality and logical consistency.

*Anomalies Detected:* Identified 180 "Ghost Bookings" (0 total guests), inconsistent country codes (ISO-2 vs ISO-3), and extreme ADR outliers (e.g., negative values and a single entry of 5,400).

*Null Value Analysis:* Quantified missing data in agent, company, and children columns to prepare for systematic cleaning.

## Data Cleaning & Transformation 
Developed a robust SQL cleaning script to ensure the dataset is "analysis-ready."

*Data Sanitization:* Replaced text-based 'NULL' strings with actual database NULL values and standardized categorical data (e.g., remapping Undefined meals to SC).

*Integrity Enforcement:* Removed logically invalid records (0 guests) and corrected pricing errors to prevent skewed averages.

*Feature Engineering:* Transformed separate year, month, and day columns into a unified arrival_date (DATE type) using a custom mapping and casting logic to enable time-series analysis.
