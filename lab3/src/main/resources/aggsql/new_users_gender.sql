-- New Users - кількість нових користувачей
WITH udid_min_event_date AS (
    SELECT
        e.device_udid,
        MIN(e.event_id) FILTER (WHERE fse.gender IS NOT NULL) AS min_fse_event_id,
        MIN(e.event_date) AS min_event_date
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    GROUP BY
        e.device_udid
), udid_min_event_date_with_gender AS (
    SELECT
        umed.device_udid,
        fse.gender,
        umed.min_event_date
    FROM
        udid_min_event_date umed
    LEFT JOIN
        first_start_event fse
        ON umed.min_fse_event_id = fse.event_id
)
SELECT
    CAST(DATE_TRUNC('day', umedwg.min_event_date) AS DATE) AS event_day,
    COUNT(umedwg.device_udid) FILTER (WHERE umedwg.gender = 'male') AS new_users_male,
    COUNT(umedwg.device_udid) FILTER (WHERE umedwg.gender = 'female') AS new_users_female,
    COUNT(umedwg.device_udid) FILTER (WHERE umedwg.gender IS NULL) AS new_users_gender_unknown
FROM
    udid_min_event_date_with_gender AS umedwg
GROUP BY
    event_day
ORDER BY
    event_day ASC;