-- Попредметна + щоденна статистика: кількість куплених речей
WITH first_country AS (
    SELECT
        e.device_udid,
        fse.country,
        RANK() OVER (PARTITION BY e.device_udid ORDER BY e.event_date) AS country_rank
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    WHERE
        fse.country IS NOT NULL
), device_udid_first_country AS (
    SELECT
        device_udid,
        country
    FROM
        first_country
    WHERE
        country_rank = 1
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(ipe.item) FILTER (WHERE dufg.country = 'Ukraine') AS sold_items_count_ukraine,
    COUNT(ipe.item) FILTER (WHERE dufg.country = 'United States of America') AS sold_items_count_usa,
    COUNT(ipe.item) FILTER (WHERE dufg.country IS NOT NULL AND dufg.country NOT IN ('Ukraine', 'United States of America')) AS sold_items_count_other,
    COUNT(ipe.item) FILTER (WHERE dufg.country IS NULL) AS sold_items_count_country_unknown
FROM
    event e
LEFT JOIN
    device_udid_first_country dufg
    ON e.device_udid = dufg.device_udid
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;