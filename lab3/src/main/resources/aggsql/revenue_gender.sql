-- Revenue - кількість USD, що зароблено за добу
WITH first_gender AS (
    SELECT
        e.device_udid,
        fse.gender,
        RANK() OVER (PARTITION BY e.device_udid ORDER BY e.event_date) AS gender_rank
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    WHERE
        fse.gender IS NOT NULL
), device_udid_first_gender AS (
    SELECT
        device_udid,
        gender
    FROM
        first_gender
    WHERE
        gender_rank = 1
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    SUM(cpe.price) FILTER (WHERE dufg.gender = 'male') AS revenue_male,
    SUM(cpe.price) FILTER (WHERE dufg.gender = 'female') AS revenue_female,
    SUM(cpe.price) FILTER (WHERE dufg.gender IS NULL) AS revenue_gender_unknown
FROM
    event AS e
LEFT JOIN
    device_udid_first_gender dufg
    ON e.device_udid = dufg.device_udid
LEFT JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;