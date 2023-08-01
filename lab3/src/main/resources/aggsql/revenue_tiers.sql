-- Revenue - кількість USD, що зароблено за добу
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    SUM(cpe.price) FILTER (WHERE aukc.cluster = 0) AS revenue_cluster_0,
    SUM(cpe.price) FILTER (WHERE aukc.cluster = 1) AS revenue_cluster_1,
    SUM(cpe.price) FILTER (WHERE aukc.cluster = 2) AS revenue_cluster_2,
    SUM(cpe.price) FILTER (WHERE aukc.cluster = 3) AS revenue_cluster_3,
    SUM(cpe.price) FILTER (WHERE aukc.cluster IS NULL) AS revenue_cluster_unknown
FROM
    event AS e
INNER JOIN
    all_users_kmeans_clusters aukc
    ON e.device_udid = aukc.device_udid
LEFT JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;