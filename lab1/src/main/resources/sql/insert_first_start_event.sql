WITH event_data AS (
    INSERT INTO event (game_event_id, device_udid, event_date)
    VALUES (2, ?, ?)
    RETURNING event_id
)
INSERT INTO first_start_event (event_id, gender, age, country)
SELECT event_data.event_id, ?, ?, ?
FROM event_data;
