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
)
SELECT
    CAST(DATE_TRUNC('day', umed.min_event_date) AS DATE) AS event_day,
    COUNT(umed.device_udid) FILTER (WHERE iec.is_cheater = true) AS new_users_is_cheater_true,
    COUNT(umed.device_udid) FILTER (WHERE iec.is_cheater = false) AS new_users_is_cheater_false,
    COUNT(umed.device_udid) FILTER (WHERE iec.is_cheater IS NULL) AS new_users_is_cheater_unknown
FROM
    udid_min_event_date AS umed
INNER JOIN
    income_expenses_cheaters iec
    ON umed.device_udid = iec.device_udid
GROUP BY
    event_day
ORDER BY
    event_day ASC;
