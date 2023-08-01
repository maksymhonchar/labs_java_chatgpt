-- DAU - кількість унікальних користувачів за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE aukc.cluster = 0) AS dau_cluster_0,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE aukc.cluster = 1) AS dau_cluster_1,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE aukc.cluster = 2) AS dau_cluster_2,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE aukc.cluster = 3) AS dau_cluster_3,
    COUNT(DISTINCT e.device_udid) FILTER (WHERE aukc.cluster IS NULL) AS dau_cluster_unknown
FROM
    event AS e
INNER JOIN
    all_users_kmeans_clusters aukc
    ON e.device_udid = aukc.device_udid
GROUP BY
    event_day
ORDER BY
    event_day ASC;
