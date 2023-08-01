--  Поетапну статистику - кількість розпочатих етапів, кількість завершених етапів, кількість перемог, кількість отриманої внутрішньоігрової валюти (також перевести у USD)
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
), stage_start_event_stats AS (
    SELECT
        CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
        sse.stage AS stage,
        COUNT(sse.event_id) AS stage_start_count
    FROM
        event e
    INNER JOIN
        stage_start_event sse
        ON e.event_id = sse.event_id
    GROUP BY
        event_day,
        sse.stage
), stage_end_event_stats AS (
    SELECT
        CAST(DATE_TRUNC('day', e.event_date) AS DATE) AS event_day,
        see.stage AS stage,
        COUNT(see.event_id) AS stage_end_count,
        COUNT(see.event_id) FILTER (WHERE see.win = true) AS win_count,
        SUM(see.income) AS income_sum
    FROM
        event e
    INNER JOIN
        stage_end_event see
        ON e.event_id = see.event_id
    GROUP BY
        event_day,
        see.stage
)
SELECT
    start_stats.stage,
    SUM(start_stats.stage_start_count) AS stage_start_count_sum,
    SUM(end_stats.stage_end_count) AS stage_end_count_sum,
    SUM(end_stats.win_count) AS win_count_sum,
    SUM(end_stats.income_sum) AS income_sum,
    ROUND(SUM(end_stats.income_sum * dcr.rate), 5) AS income_sum_usd
FROM
    stage_start_event_stats start_stats
LEFT JOIN
    stage_end_event_stats end_stats
    ON start_stats.stage = end_stats.stage
    AND start_stats.event_day = end_stats.event_day
LEFT JOIN
    daily_currency_rate dcr
    ON start_stats.event_day = dcr.event_day
GROUP BY
    start_stats.stage
ORDER BY
    start_stats.stage ASC;