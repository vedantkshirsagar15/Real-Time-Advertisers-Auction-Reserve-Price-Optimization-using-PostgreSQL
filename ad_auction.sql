CREATE DATABASE ad_auction;
DROP TABLE IF EXISTS auction_data;
CREATE TABLE auction_data (
    date TIMESTAMP,
    site_id INT,
    ad_type_id INT,
    geo_id INT,
    device_category_id INT,
    advertiser_id INT,
    order_id INT,
    line_item_type_id INT,
    os_id INT,
    integration_type_id INT,
    monetization_channel_id INT,
    ad_unit_id INT,
    total_impressions INT,
    total_revenue NUMERIC(12,4),
    viewable_impressions INT,
    measurable_impressions INT,
    revenue_share_percent NUMERIC(5,2)
);

-- Check row count
SELECT COUNT(*) FROM auction_data;

-- Check missing values
SELECT 
    COUNT(*) FILTER (WHERE total_impressions IS NULL) AS missing_impressions,
    COUNT(*) FILTER (WHERE total_revenue IS NULL) AS missing_revenue
FROM auction_data;

-- Check unique dimensions
SELECT COUNT(DISTINCT site_id) AS sites, COUNT(DISTINCT ad_type_id) AS ad_types,
       COUNT(DISTINCT geo_id) AS geos, COUNT(DISTINCT advertiser_id) AS advertisers
FROM auction_data;

ALTER TABLE auction_data
ADD COLUMN cpm NUMERIC(12,4),
ADD COLUMN effective_cpm NUMERIC(12,4);

UPDATE auction_data
SET 
    cpm = (total_revenue / total_impressions) * 1000,
    effective_cpm = ((total_revenue * revenue_share_percent/100) / total_impressions) * 1000
WHERE total_impressions > 0;

CREATE VIEW site_summary AS
SELECT 
    site_id,
	ROUND(AVG(effective_cpm), 4) AS avg_cpm,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY effective_cpm)::numeric, 4) AS p25_cpm,
    ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY effective_cpm)::numeric, 4) AS median_cpm,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY effective_cpm)::numeric, 4) AS p75_cpm,
    ROUND(STDDEV(effective_cpm)::numeric, 4) AS stddev_cpm,

    SUM(total_impressions) AS total_impressions,
    SUM(total_revenue) AS total_revenue
FROM auction_data
GROUP BY site_id;

SELECT * FROM site_summary ORDER BY avg_cpm DESC;

CREATE VIEW reserve_price_recommendation AS
SELECT
    site_id,
    median_cpm AS current_value,
    ROUND(median_cpm * 0.7, 4) AS reserve_lower,
    ROUND(median_cpm * 0.9, 4) AS reserve_upper,
    ROUND(median_cpm * 1.2, 4) AS potential_bidder_value
FROM site_summary;

-- Revenue impact if reserve set to 0.8 * median CPM
SELECT 
    site_id,
    COUNT(*) FILTER (WHERE effective_cpm >= 0.8 * median_cpm) * 100.0 / COUNT(*) AS fill_rate_percent,
    AVG(effective_cpm) FILTER (WHERE effective_cpm >= 0.8 * median_cpm) AS new_avg_cpm,
    AVG(effective_cpm) AS old_avg_cpm,
    (AVG(effective_cpm) FILTER (WHERE effective_cpm >= 0.8 * median_cpm) / AVG(effective_cpm) - 1) * 100 AS revenue_lift_percent
FROM auction_data a
JOIN site_summary s USING (site_id)
GROUP BY site_id, median_cpm;

SELECT 
    r.site_id,
    r.reserve_lower,
    r.reserve_upper,
    i.revenue_lift_percent,
    i.fill_rate_percent
FROM reserve_price_recommendation r
JOIN (
    SELECT 
        site_id,
        COUNT(*) FILTER (WHERE effective_cpm >= 0.8 * median_cpm) * 100.0 / COUNT(*) AS fill_rate_percent,
        (AVG(effective_cpm) FILTER (WHERE effective_cpm >= 0.8 * median_cpm) / AVG(effective_cpm) - 1) * 100 AS revenue_lift_percent
    FROM auction_data a
    JOIN site_summary s USING (site_id)
    GROUP BY site_id, median_cpm
) i USING (site_id)
ORDER BY i.revenue_lift_percent DESC;

