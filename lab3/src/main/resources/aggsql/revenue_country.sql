-- Revenue - кількість USD, що зароблено за добу
WITH first_country AS (
    SELECT
        e.device_udid,
        fse.country,
        RANK() OVER (PARTITION BY e.device_udid ORDER BY e.event_date) AS country_rank
    FROM
        event e
    LEFT JOIN
        first_start_event fse
        ON e.event_id = fse.event_id
    WHERE
        fse.country IS NOT NULL
), device_udid_first_country AS (
    SELECT
        device_udid,
        country
    FROM
        first_country
    WHERE
        country_rank = 1
)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    SUM(cpe.price) FILTER (WHERE dufc.country = 'Ukraine') AS revenue_ukraine,
    SUM(cpe.price) FILTER (WHERE dufc.country = 'United States of America') AS revenue_usa,
    SUM(cpe.price) FILTER (WHERE dufc.country IS NOT NULL AND dufc.country NOT IN ('Ukraine', 'United States of America')) AS revenue_other,
    SUM(cpe.price) FILTER (WHERE dufc.country IS NULL) AS revenue_country_unknown
FROM
    event AS e
LEFT JOIN
    device_udid_first_country dufc
    ON e.device_udid = dufc.device_udid
LEFT JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;