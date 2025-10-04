# Real-Time-Advertisers-Auction-Reserve-Price-Optimization-using-PostgreSQL
Real-Time Advertisers Auction: Reserve Price Optimization using PostgreSQL

#Project Overview

This project analyzes digital advertising auction data to determine optimal reserve prices for publishers in first-price auctions.
Using PostgreSQL (via pgAdmin4) for data modeling and analytics, the goal was to help a digital media company maximize ad revenue while maintaining advertiser participation across its portfolio of websites.

#Objective

To design a data-driven reserve price strategy for July auctions using June performance data — balancing: 
1. Higher eCPM (effective Cost per Mille) for the publisher
2. Stable win rate for advertisers
3. Controlled inventory fill rate

#Dataset Description

Source: Kaggle - Real-Time Advertisers Auction Dataset
Records: ~200,000 aggregated auction-level entries (June 2019)
Key Columns:
1. site_id: Publisher website identifier
2. ad_type_id: Ad format (display, video, text, etc.)
3. geo_id: Country of user impression
4. device_category_id: Device type (desktop, mobile, tablet)
5. advertiser_id: Unique bidder ID
6. total_impressions, total_revenue: Core performance metrics
7. revenue_share_percent: Share of revenue retained by publisher
Derived metrics like CPM, effective CPM, and fill rate were used to simulate pricing scenarios.

#Tools & Techniques
Database: PostgreSQL (via pgAdmin4)
1. Data Analysis: SQL (CTEs, window functions, percentiles, joins)
2. Metrics Computed: CPM, eCPM, Reserve Price Range, Fill Rate, Revenue Lift
3. Visualization: pgAdmin query results + Power BI (optional dashboard)
Methodology: Statistical analysis, quantile-based pricing simulation, and elasticity modeling

#Process

1. Data Ingestion & Cleaning
Imported raw CSV data into PostgreSQL; verified data types and integrity.
2. Metric Computation
Created derived columns for CPM and effective CPM (post revenue share).
3. Aggregation
Grouped data by site_id and ad_type_id to identify valuation patterns.
4. Reserve Price Simulation
Estimated reserve price bands at 70–90% of median CPM to test trade-offs between fill rate and revenue lift.
5. Scenario Analysis
Simulated multiple reserve strategies to find balance between yield improvement and bidder participation.

#Key Insights

 Median eCPM varied significantly by geo and device, showing that premium geos (e.g., US/UK) can sustain 15–20% higher reserve prices.
 Setting reserve prices at 0.8× median CPM yielded a 10–12% average revenue uplift with minimal impression loss (<8%).
 Sites with high CPM volatility (large standard deviation) required more cautious reserve adjustments.
 Mobile inventory had higher impression volumes but lower CPM consistency compared to desktop.

#Business Impact
1. Helped quantify the elasticity between reserve price and fill rate.
2. Created a dynamic reserve price band for July auctions, improving monetization strategy.
3. Enabled data-driven pricing governance across 350+ ad units and multiple channels.
4. Potential revenue uplift of 10–15% with controlled bidder drop-off.

#Challenges & Learnings
1. Data lacked bid-level granularity, requiring CPM-based inference modeling.
2. Variability across ad types and integration channels demanded multi-level grouping.
3. Learned to simulate economic trade-offs of pricing in real-time markets using only aggregated data.
4. Reinforced understanding of auction theory, bid shading, and first-price dynamics in digital advertising.
