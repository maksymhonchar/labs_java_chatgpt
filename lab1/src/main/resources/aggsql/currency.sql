-- Курс внутрішньоігрової валюти за добу (прибуток за добу / кількість купленої валюти за добу)
SELECT
    CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
    ROUND(SUM(cpe.price) / SUM(cpe.income), 5) AS currency_rate
FROM
    event AS e
INNER JOIN
    currency_purchase_event cpe
    ON e.event_id = cpe.event_id
GROUP BY
    event_day
ORDER BY
    event_day ASC;