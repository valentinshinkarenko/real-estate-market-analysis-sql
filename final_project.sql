/* Module 1 project: real estate agency data analysis
 * Part 2. Ad hoc analysis
 *
 * Author: Valentin Shinkarenko
 * Date: 2024-12-18
*/
-- Task 1: Listing activity duration
-- The query should answer the following questions:
-- 1. Which real estate market segments in Saint Petersburg and the towns of Leningrad Oblast
--    have the shortest or longest listing activity durations?
-- 2. Which property characteristics — total area, average price per square meter,
--    number of rooms and balconies, and other parameters — affect listing activity duration?
--    How do these relationships vary between regions?
-- 3. Are there differences between Saint Petersburg and Leningrad Oblast real estate based on the results?

-- 1. Filter out outliers
WITH limits AS (
    SELECT
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(total_area AS numeric)) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(rooms AS numeric)) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(balcony AS numeric)) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(ceiling_height AS numeric)) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY CAST(ceiling_height AS numeric)) AS ceiling_height_limit_l
    FROM real_estate.flats
),

filtered_data AS (
    SELECT
        c.city,
        CASE
            WHEN c.city = 'Санкт-Петербург' THEN 'Saint Petersburg'
            ELSE 'Leningrad Oblast'
        END AS region,
        CASE
            WHEN a.days_exposition IS NULL THEN 'Active listings'
            WHEN a.days_exposition BETWEEN 1 AND 30 THEN 'up to 1 month'
            WHEN a.days_exposition BETWEEN 31 AND 90 THEN 'up to 3 months'
            WHEN a.days_exposition BETWEEN 91 AND 180 THEN 'up to 6 months'
            ELSE 'more than 6 months'
        END AS activity_segment,
        ROUND(CAST(a.last_price AS numeric) / CAST(f.total_area AS numeric), 2) AS price_per_sqm,
        f.total_area,
        f.rooms,
        f.balcony,
        f.ceiling_height,
        f.floor
    FROM real_estate.flats AS f
    JOIN real_estate.advertisement AS a ON f.id = a.id
    JOIN real_estate.city AS c ON f.city_id = c.city_id
    JOIN real_estate.type AS t ON f.type_id = t.type_id
    WHERE
        t.type = 'город' -- Restrict to "city" type listings (raw category value from the source data)
        AND f.total_area < (SELECT total_area_limit FROM limits)
        AND (f.rooms < (SELECT rooms_limit FROM limits) OR f.rooms IS NULL)
        AND (f.balcony < (SELECT balcony_limit FROM limits) OR f.balcony IS NULL)
        AND (
            (f.ceiling_height BETWEEN (SELECT ceiling_height_limit_l FROM limits)
                                  AND (SELECT ceiling_height_limit_h FROM limits))
            OR f.ceiling_height IS NULL
        )
)

-- 2. Aggregate data into a summary table
SELECT
    region AS "Region",
    activity_segment AS "Activity segment",
    COUNT(*) AS "Listing count",
    ROUND(AVG(price_per_sqm), 2) AS "Avg price per sqm",
    ROUND(CAST(AVG(total_area) AS numeric), 2) AS "Avg total area",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS "Median rooms",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS "Median balconies",
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floor) AS "Median floor"
FROM filtered_data
GROUP BY region, activity_segment
ORDER BY region, activity_segment;




-- Task 2: Listing seasonality
-- The query should answer the following questions:
-- 1. In which months is listing publication activity highest? And listing removal?
--    This shows buyer activity dynamics.
-- 2. Do periods of high publication activity coincide with periods of increased sales
--    (based on listing removal months)?
-- 3. How do seasonal fluctuations affect average price per square meter and average apartment area?
--    What can be said about how these parameters depend on the month?

-- 1. Filter out outliers
WITH limits AS (
    SELECT
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(total_area AS numeric)) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(rooms AS numeric)) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(balcony AS numeric)) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY CAST(ceiling_height AS numeric)) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY CAST(ceiling_height AS numeric)) AS ceiling_height_limit_l
    FROM real_estate.flats
),

month_data AS (
    -- 2. Add publication and removal months
    SELECT
        TO_CHAR(a.first_day_exposition, 'Month') AS publication_month,
        CASE
            WHEN a.days_exposition IS NOT null -- Only consider closed listings
            THEN TO_CHAR(a.first_day_exposition + INTERVAL '1 day' * a.days_exposition, 'Month')
        END AS removal_month,
        ROUND(CAST(a.last_price AS numeric) / CAST(f.total_area AS numeric), 2) AS price_per_sqm,
        f.total_area
    FROM real_estate.advertisement AS a
    JOIN real_estate.flats AS f ON a.id = f.id
    JOIN real_estate.type AS t ON f.type_id = t.type_id
    WHERE
        t.type = 'город' -- Restrict to "city" type listings (raw category value from the source data)
        AND f.total_area < (SELECT total_area_limit FROM limits)
),

publication_stats AS (
    -- 3. Statistics by publication month
    SELECT
        publication_month AS month,
        COUNT(*) AS publication_count,
        ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm_publication,
        ROUND(CAST(AVG(total_area) AS numeric), 2) AS avg_total_area_publication
    FROM month_data
    GROUP BY publication_month
),

removal_stats AS (
    -- 4. Statistics by removal month
    SELECT
        removal_month AS month,
        COUNT(*) AS removal_count,
        ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm_removal,
        ROUND(CAST(AVG(total_area) AS numeric), 2) AS avg_total_area_removal
    FROM month_data
    WHERE removal_month IS NOT NULL
    GROUP BY removal_month
)

-- 5. Combine publication and removal data
SELECT
    COALESCE(p.month, r.month) AS month,
    COALESCE(p.publication_count, 0) AS publication_count,
    COALESCE(r.removal_count, 0) AS removal_count,
    p.avg_price_per_sqm_publication AS avg_price_per_sqm_publication,
    r.avg_price_per_sqm_removal AS avg_price_per_sqm_removal,
    p.avg_total_area_publication AS avg_total_area_publication,
    r.avg_total_area_removal AS avg_total_area_removal
FROM publication_stats AS p
FULL OUTER JOIN removal_stats AS r ON p.month = r.month
ORDER BY TO_DATE(COALESCE(p.month, r.month), 'Month');


-- Task 3: Leningrad Oblast market analysis
-- The query should answer the following questions:
-- 1. In which Leningrad Oblast settlements are property listings published most actively?
-- 2. In which Leningrad Oblast settlements is the share of removed listings highest?
--    This may indicate a high share of completed sales.
-- 3. What is the average price per square meter and average area of apartments for sale
--    across different settlements? Is there significant variation in these metrics?
-- 4. Among the selected settlements, which stand out by listing duration?
--    I.e., where does property sell faster, and where slower?

WITH lenobl_data AS (
    -- 1. Select data for Leningrad Oblast only
SELECT
    c.city AS settlement,
    a.id AS advertisement_id,
    a.days_exposition,
    ROUND(CAST(a.last_price AS numeric) / CAST(f.total_area AS numeric), 2) AS price_per_sqm,
    f.total_area,
    CASE
        WHEN a.days_exposition IS NOT NULL THEN 1
        ELSE 0
    END AS sold_flag
FROM real_estate.advertisement AS a
JOIN real_estate.flats AS f ON a.id = f.id
JOIN real_estate.city AS c ON f.city_id = c.city_id
WHERE c.city != 'Санкт-Петербург'
),

filtered_settlements AS (
    -- 2. Keep settlements with >= 50 listings
    SELECT
        settlement,
        COUNT(*) AS total_ads,
        SUM(sold_flag) AS sold_count,
        ROUND(AVG(price_per_sqm), 2) AS avg_price_per_sqm,
        ROUND(CAST(AVG(total_area) AS numeric), 2) AS avg_total_area,
        ROUND(CAST(AVG(days_exposition) AS numeric), 2) AS avg_days_exposition
    FROM lenobl_data
    GROUP BY settlement
    HAVING COUNT(*) >= 50
),

settlement_stats AS (
    -- 3. Calculate additional metrics
    SELECT
        settlement,
        total_ads,
        sold_count,
        ROUND(100.0 * sold_count / total_ads, 2) AS sold_ratio,
        avg_price_per_sqm,
        avg_total_area,
        avg_days_exposition
    FROM filtered_settlements
)

-- 4. Final query: settlement ranking
SELECT
    settlement AS "Settlement",
    total_ads AS "Total listings",
    sold_count AS "Removed listings",
    sold_ratio AS "Removed listings share (%)",
    avg_price_per_sqm AS "Avg price per sqm (RUB)",
    avg_total_area AS "Avg total area (sqm)",
    avg_days_exposition AS "Avg time on market (days)"
FROM settlement_stats
ORDER BY sold_ratio DESC, total_ads DESC
LIMIT 15;
