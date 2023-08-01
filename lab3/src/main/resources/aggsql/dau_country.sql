-- DAU - кількість унікальних користувачів за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.country = 'Ukraine') AS dau_ukraine,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.country = 'United States of America') AS dau_usa,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.country IS NOT NULL AND fse.country NOT IN ('Ukraine', 'United States of America')) AS dau_other,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.country IS NULL) AS dau_country_unknown
FROM
    event AS e
INNER JOIN
    first_start_event fse
    ON e.event_id = fse.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;
