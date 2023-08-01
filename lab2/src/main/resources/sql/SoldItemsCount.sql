-- Попредметна + щоденна статистика: кількість куплених речей
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
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS game_event_day,
    COUNT(ipe.item) AS sold_items_count
FROM
    event e
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
GROUP BY
    game_event_day
ORDER BY
    game_event_day ASC;
