WITH event_data AS (
    INSERT INTO event (game_event_id, device_udid, event_date)
    VALUES (4, ?, ?)
    RETURNING event_id
)
INSERT INTO stage_end_event (event_id, stage, win, time, income)
SELECT event_data.event_id, ?, ?, ?, ?
FROM event_data;
