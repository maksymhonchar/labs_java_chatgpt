-- Попредметна + щоденна статистика: на яку суму USD
WITH daily_currency_rate AS (
    SELECT
        CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
        SUM(cpe.price) / SUM(cpe.income) AS rate
    FROM
        event AS e
    INNER JOIN
        currency_purchase_event cpe
        ON e.event_id = cpe.event_id
    GROUP BY
        event_day
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS game_event_day,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE aukc.cluster = 0), 5) AS dau_cluster_0,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE aukc.cluster = 1), 5) AS dau_cluster_1,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE aukc.cluster = 2), 5) AS dau_cluster_2,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE aukc.cluster = 3), 5) AS dau_cluster_3,
    ROUND(SUM(ipe.price * dcr.rate) FILTER (WHERE aukc.cluster IS NULL), 5) AS dau_cluster_unknown
FROM
    event e
INNER JOIN
    all_users_kmeans_clusters aukc
    ON e.device_udid = aukc.device_udid
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
LEFT JOIN
    daily_currency_rate dcr
    ON e.event_date = dcr.event_day
GROUP BY
    game_event_day
ORDER BY
    game_event_day ASC;