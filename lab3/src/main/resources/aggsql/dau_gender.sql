-- DAU - кількість унікальних користувачів за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.gender = 'male') AS dau_male,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.gender = 'female') AS dau_female,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE fse.gender IS NULL) AS dau_gender_unknown
FROM
    event AS e
INNER JOIN
    first_start_event fse
    ON e.event_id = fse.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;
