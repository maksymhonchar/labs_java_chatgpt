WITH event_data AS (
    INSERT INTO event (game_event_id, device_udid, event_date)
    VALUES (5, ?, ?)
    RETURNING event_id, game_event_id
)
INSERT INTO item_purchase_event (event_id, item, price)
SELECT event_data.event_id, ?, ?
FROM event_data;
