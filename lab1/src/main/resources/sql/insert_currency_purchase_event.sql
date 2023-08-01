WITH event_data AS (
    INSERT INTO event (game_event_id, device_udid, event_date)
    VALUES (6, ?, ?)
    RETURNING event_id
)
INSERT INTO currency_purchase_event (event_id, name, price, income)
SELECT event_data.event_id, ?, ?, ?
FROM event_data;
