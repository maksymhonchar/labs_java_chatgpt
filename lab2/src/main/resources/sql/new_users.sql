-- New Users - кількість нових користувачей
WITH udid_min_event_date AS (
    SELECT
        e.device_udid,
        MIN(e.event_date) AS min_event_date
    FROM
        event e
    GROUP BY
        e.device_udid
)
SELECT
    CAST(DATE_TRUNC('day', umed.min_event_date) AS DATE) AS event_day,
    COUNT(umed.device_udid) AS "New Users"
FROM
    udid_min_event_date AS umed
GROUP BY
    event_day
ORDER BY
    event_day ASC;
