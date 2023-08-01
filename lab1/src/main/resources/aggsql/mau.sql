-- MAU - кількість унікальних користувачів за останні 30 діб
SELECT
    CAST(DATE_TRUNC('month', e.event_date) AS DATE) AS event_month,
    COUNT(DISTINCT e.device_udid) AS MAU
FROM
    event e
WHERE
    e.event_date >= (SELECT MAX(e2.event_date) - INTERVAL '30 days' FROM event e2)
GROUP BY
    event_month
ORDER BY
    event_month;
