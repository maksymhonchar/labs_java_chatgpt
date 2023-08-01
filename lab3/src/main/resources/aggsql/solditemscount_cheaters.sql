-- Попредметна + щоденна статистика: кількість куплених речей
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(ipe.item) FILTER (WHERE iec.is_cheater = true) AS sold_items_count_is_cheater_true,
    COUNT(ipe.item) FILTER (WHERE iec.is_cheater = false) AS sold_items_count_is_cheater_false,
    COUNT(ipe.item) FILTER (WHERE iec.is_cheater IS NULL) AS sold_items_count_is_cheater_unknown
FROM
    event e
INNER JOIN
    income_expenses_cheaters iec
    ON e.device_udid = iec.device_udid
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;