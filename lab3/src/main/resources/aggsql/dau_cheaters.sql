-- DAU - кількість унікальних користувачів за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE iec.is_cheater = true) AS dau_is_cheater_true,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE iec.is_cheater = false) AS dau_is_cheater_false,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE iec.is_cheater IS NULL) AS dau_is_cheater_unknown
FROM
    event AS e
INNER JOIN
    income_expenses_cheaters iec
    ON e.device_udid = iec.device_udid
GROUP BY
    event_day
ORDER BY
    event_day ASC;
