-- New Users - кількість нових користувачей
WITH udid_min_event_date AS (
    SELECT
        e.device_udid,
        MIN(e.event_id) FILTER (WHERE fse.age IS NOT NULL) AS min_fse_event_id,
        MIN(e.event_date) AS min_event_date
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    GROUP BY
        e.device_udid
), udid_min_event_date_with_age AS (
    SELECT
        umed.device_udid,
        fse.age,
        umed.min_event_date
    FROM
        udid_min_event_date umed
    LEFT JOIN
        first_start_event fse
        ON umed.min_fse_event_id = fse.event_id
)
SELECT
    CAST(DATE_TRUNC('day', umedwa.min_event_date) AS DATE) AS event_day,
    COUNT(umedwa.device_udid) FILTER (WHERE umedwa.age < 25) AS new_users_lt_25,
    COUNT(umedwa.device_udid) FILTER (WHERE umedwa.age >= 25 AND umedwa.age <= 40) AS new_users_gte_25_lte_40,
    COUNT(umedwa.device_udid) FILTER (WHERE umedwa.age > 40) AS new_users_gt_40,
    COUNT(umedwa.device_udid) FILTER (WHERE umedwa.age IS NULL) AS new_users_age_unknown
FROM
    udid_min_event_date_with_age AS umedwa
GROUP BY
    event_day
ORDER BY
    event_day ASC;