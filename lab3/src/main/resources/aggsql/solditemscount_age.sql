-- Попредметна + щоденна статистика: кількість куплених речей
WITH first_age AS (
    SELECT
        e.device_udid,
        fse.age,
        RANK() OVER (PARTITION BY e.device_udid ORDER BY e.event_date) AS age_rank
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    WHERE
        fse.age IS NOT NULL
), device_udid_first_age AS (
    SELECT
        device_udid,
        age
    FROM
        first_age
    WHERE
        age_rank = 1
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(ipe.item) FILTER (WHERE dufa.age < 25) AS sold_items_count_lt_25,
    COUNT(ipe.item) FILTER (WHERE dufa.age >= 25 AND dufa.age <= 40) AS sold_items_count_gte_25_lte_40,
    COUNT(ipe.item) FILTER (WHERE dufa.age > 40) AS sold_items_count_gt_40,
    COUNT(ipe.item) FILTER (WHERE dufa.age IS NULL) AS sold_items_count_age_unknown
FROM
    event e
LEFT JOIN
    device_udid_first_age dufa
    ON e.device_udid = dufa.device_udid
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;