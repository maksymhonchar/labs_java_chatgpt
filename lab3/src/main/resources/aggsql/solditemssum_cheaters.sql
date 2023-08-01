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
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS game_event_day,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE iec.is_cheater = true), 5) AS new_users_is_cheater_true,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE iec.is_cheater = false), 5) AS new_users_is_cheater_false,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE iec.is_cheater IS NULL), 5) AS new_users_is_cheater_unknown
FROM
    event e
INNER JOIN
    income_expenses_cheaters iec
    ON e.device_udid = iec.device_udid
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