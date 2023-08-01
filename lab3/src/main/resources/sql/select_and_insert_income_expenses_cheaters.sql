DELETE FROM income_expenses_cheaters;

CREATE TABLE IF NOT EXISTS income_expenses_cheaters (
    device_udid VARCHAR(255) PRIMARY KEY,
    total_income NUMERIC,
    total_expenses NUMERIC,
    is_cheater BOOLEAN
);

INSERT INTO income_expenses_cheaters (device_udid, total_income, total_expenses, is_cheater)
SELECT
    e.device_udid,
    COALESCE(SUM(see.income), 0.0) + COALESCE(SUM(cpe.income), 0.0) AS total_income,
    COALESCE(SUM(ipe.price), 0.0) AS total_expenses,
    COALESCE(SUM(see.income), 0.0) + COALESCE(SUM(cpe.income), 0.0) < COALESCE(SUM(ipe.price), 0.0) AS is_cheater
FROM
    event e
LEFT JOIN
    stage_end_event see ON e.event_id = see.event_id
LEFT JOIN
    currency_purchase_event cpe ON e.event_id = cpe.event_id
LEFT JOIN
    item_purchase_event ipe ON e.event_id = ipe.event_id
-- WHERE
--     e.event_date >= (SELECT MIN(event_date) FROM event)
--     AND e.event_date < (SELECT MIN(event_date) + INTERVAL '7 days' FROM event)
GROUP BY
    e.device_udid;
