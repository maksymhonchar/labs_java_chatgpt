-- New Users - кількість нових користувачей
WITH udid_min_event_date AS (
    SELECT
        e.device_udid,
        MIN(e.event_id) FILTER (WHERE fse.country IS NOT NULL) AS min_fse_event_id,
        MIN(e.event_date) AS min_event_date
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    GROUP BY
        e.device_udid
), udid_min_event_date_with_country AS (
    SELECT
        umed.device_udid,
        fse.country,
        umed.min_event_date
    FROM
        udid_min_event_date umed
    LEFT JOIN
        first_start_event fse
        ON umed.min_fse_event_id = fse.event_id
)
SELECT
    CAST(DATE_TRUNC('day', umedwc.min_event_date) AS DATE) AS event_day,
    COUNT(umedwc.device_udid) FILTER (WHERE umedwc.country = 'Ukraine') AS new_users_ukraine,
    COUNT(umedwc.device_udid) FILTER (WHERE umedwc.country = 'United States of America') AS new_users_usa,
    COUNT(umedwc.device_udid) FILTER (WHERE umedwc.country IS NOT NULL AND umedwc.country NOT IN ('Ukraine', 'United States of America')) AS new_users_other,
    COUNT(umedwc.device_udid) FILTER (WHERE umedwc.country IS NULL) AS new_users_country_unknown
FROM
    udid_min_event_date_with_country AS umedwc
GROUP BY
    event_day
ORDER BY
    event_day ASC;