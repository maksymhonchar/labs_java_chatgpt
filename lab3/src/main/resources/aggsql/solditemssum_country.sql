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
), first_country AS (
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
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS game_event_day,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufg.country = 'Ukraine'), 5) AS sold_items_count_ukraine,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufg.country = 'United States of America'), 5) AS sold_items_count_usa,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufg.country IS NOT NULL AND dufg.country NOT IN ('Ukraine', 'United States of America')), 5) AS sold_items_count_other,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE dufg.country IS NULL), 5) AS sold_items_count_country_unknown
FROM
    event e
LEFT JOIN
    device_udid_first_country dufg
    ON e.device_udid = dufg.device_udid
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