-- Попредметна + щоденна статистика: кількість куплених речей
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    COUNT(ipe.item) FILTER (WHERE aukc.cluster = 0) AS sold_items_count_cluster_0,
    COUNT(ipe.item) FILTER (WHERE aukc.cluster = 1) AS sold_items_count_cluster_1,
    COUNT(ipe.item) FILTER (WHERE aukc.cluster = 2) AS sold_items_count_cluster_2,
    COUNT(ipe.item) FILTER (WHERE aukc.cluster = 3) AS sold_items_count_cluster_3,
    COUNT(ipe.item) FILTER (WHERE aukc.cluster IS NULL) AS sold_items_count_cluster_unknown
FROM
    event e
INNER JOIN
    all_users_kmeans_clusters aukc
    ON e.device_udid = aukc.device_udid
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;