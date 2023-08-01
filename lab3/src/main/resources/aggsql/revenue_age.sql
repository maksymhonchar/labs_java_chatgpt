-- Revenue - кількість USD, що зароблено за добу
WITH first_age AS (
    SELECT
        e.device_udid,
        fse.age,
        RANK() OVER (PARTITION BY e.device_udid ORDER BY e.event_date) AS age_rank
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    WHERE
        fse.age IS NOT NULL
), device_udid_first_age AS (
    SELECT
        device_udid,
        age
    FROM
        first_age
    WHERE
        age_rank = 1
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    SUM(cpe.price) FILTER (WHERE dufa.age < 25) AS revenue_lt_25,
    SUM(cpe.price) FILTER (WHERE dufa.age >= 25 AND dufa.age <= 40) AS revenue_gte_25_lte_40,
    SUM(cpe.price) FILTER (WHERE dufa.age > 40) AS revenue_gt_40,
    SUM(cpe.price) FILTER (WHERE dufa.age IS NULL) AS revenue_age_unknown
FROM
    event AS e
LEFT JOIN
    device_udid_first_age dufa
    ON e.device_udid = dufa.device_udid
LEFT JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;