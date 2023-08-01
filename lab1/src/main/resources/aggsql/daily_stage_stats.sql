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
), aggregated_stats AS (
    SELECT
        start_stats.event_day,
        start_stats.stage,
        start_stats.stage_start_count,
        end_stats.stage_end_count,
        end_stats.win_count,
        end_stats.income_sum
    FROM
        stage_start_event_stats start_stats
    LEFT JOIN
        stage_end_event_stats end_stats
        ON start_stats.stage = end_stats.stage
        AND start_stats.event_day = end_stats.event_day
)
SELECT
    aggregated_stats.*,
    ROUND(aggregated_stats.income_sum * dcr.rate, 5) AS income_sum_usd
FROM
    aggregated_stats
LEFT JOIN
    daily_currency_rate dcr
    ON aggregated_stats.event_day = dcr.event_day
-- WHERE
--     aggregated_stats.event_day = '2018-01-02'::date -- comment to get less data
ORDER BY
    aggregated_stats.event_day ASC,
    aggregated_stats.stage ASC;