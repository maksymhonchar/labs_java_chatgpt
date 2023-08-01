-- Попредметна + щоденна статистика: на яку суму USD
WITH daily_currency_rate AS (
    SELECT
        CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
        SUM(cpe.price) / SUM(cpe.income) AS rate
    FROM
        event AS e
    INNER JOIN
        currency_purchase_event cpe
        ON e.event_id = cpe.event_id
    GROUP BY
        event_day
), first_age AS (
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
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS game_event_day,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufa.age < 25), 5) AS sold_items_sum_usd_lt_25,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufa.age >= 25 AND dufa.age <= 40), 5) AS sold_items_sum_usd_gte_25_lte_40,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufa.age > 40), 5) AS sold_items_sum_usd_gt_40,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufa.age IS NULL), 5) AS sold_items_sum_usd_age_unknown
FROM
    event e
LEFT JOIN
    device_udid_first_age dufa
    ON e.device_udid = dufa.device_udid
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
LEFT JOIN
    daily_currency_rate dcr
    ON e.event_date = dcr.event_day
GROUP BY
    game_event_day
ORDER BY
    game_event_day ASC;