-- Revenue - кількість USD, що зароблено за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    SUM(cpe.price) FILTER (WHERE iec.is_cheater = true) AS dau_is_cheater_true,
    SUM(cpe.price) FILTER (WHERE iec.is_cheater = false) AS dau_is_cheater_false,
    SUM(cpe.price) FILTER (WHERE iec.is_cheater IS NULL) AS dau_is_cheater_unknown
FROM
    event AS e
INNER JOIN
    income_expenses_cheaters iec
    ON e.device_udid = iec.device_udid
LEFT JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;