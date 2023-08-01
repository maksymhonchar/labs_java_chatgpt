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
    COUNT(umed.device_udid) FILTER (WHERE aukc.cluster = 0) AS new_users_cluster_0,
    COUNT(umed.device_udid) FILTER (WHERE aukc.cluster = 1) AS new_users_cluster_1,
    COUNT(umed.device_udid) FILTER (WHERE aukc.cluster = 2) AS new_users_cluster_2,
    COUNT(umed.device_udid) FILTER (WHERE aukc.cluster = 3) AS new_users_cluster_3,
    COUNT(umed.device_udid) FILTER (WHERE aukc.cluster IS NULL) AS new_users_cluster_unknown
FROM
    udid_min_event_date AS umed
INNER JOIN
    all_users_kmeans_clusters aukc
    ON umed.device_udid = aukc.device_udid
GROUP BY
    event_day
ORDER BY
    event_day ASC;
