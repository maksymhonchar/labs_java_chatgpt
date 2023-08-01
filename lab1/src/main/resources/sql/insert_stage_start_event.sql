WITH event_data AS (
    INSERT INTO event (game_event_id, device_udid, event_date)
    VALUES (3, ?, ?)
    RETURNING event_id
)
INSERT INTO stage_start_event (event_id, stage)
SELECT event_data.event_id, ?
FROM event_data;
