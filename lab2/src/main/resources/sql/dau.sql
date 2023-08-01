-- DAU - кількість унікальних користувачів за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(DISTINCT e.device_udid) AS DAU
FROM
    event AS e
GROUP BY
    event_day
ORDER BY
    event_day ASC;
