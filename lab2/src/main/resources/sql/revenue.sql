-- Revenue - кількість USD, що зароблено за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    SUM(cpe.price) AS Revenue
FROM
    event AS e
INNER JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;
