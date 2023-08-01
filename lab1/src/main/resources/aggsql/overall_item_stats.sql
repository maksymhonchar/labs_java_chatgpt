-- Попредметну статистику - кількість куплених речей, на яку суму внутрішньоігрової валюти, на яку суму USD
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
    ipe.item,
    SUM(ipe.price) AS price_sum,
    ROUND(SUM(ipe.price * dcr.rate), 5) AS price_sum_usd
FROM
    event e
INNER JOIN
    item_purchase_event ipe
    ON e.event_id = ipe.event_id
LEFT JOIN
    daily_currency_rate dcr
    ON e.event_date = dcr.event_day
GROUP BY
    ipe.item
ORDER BY
    ipe.item;
