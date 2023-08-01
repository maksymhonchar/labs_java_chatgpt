-- DAU - кількість унікальних користувачів за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.age < 25) AS dau_lt_25,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.age >= 25 AND fse.age <= 40) AS dau_gte_25_lte_40,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.age > 40) AS dau_gt_40,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.age IS NULL) AS dau_age_unknown
FROM
    event AS e
INNER JOIN
    first_start_event fse
    ON e.event_id = fse.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;
