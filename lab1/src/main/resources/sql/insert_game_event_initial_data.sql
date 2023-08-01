INSERT INTO game_event (game_event_id, description_ua)
VALUES 
    (1, 'Запуск гри'),
    (2, 'Перший запуск гри'),
    (3, 'Початок етапу'),
    (4, 'Завершення етапу'),
    (5, 'Покупка внутрішньо-ігрового предмета'),
    (6, 'Покупка валюти')
ON CONFLICT (game_event_id) DO NOTHING;
