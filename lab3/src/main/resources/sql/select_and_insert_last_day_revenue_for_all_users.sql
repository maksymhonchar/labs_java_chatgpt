DELETE FROM last_day_revenue_for_all_users;

CREATE TABLE IF NOT EXISTS last_day_revenue_for_all_users (
    device_udid VARCHAR(255) PRIMARY KEY,
    sum_cpe_price DECIMAL(10, 2) NOT NULL
);

INSERT INTO last_day_revenue_for_all_users (device_udid, sum_cpe_price)
SELECT
    e.device_udid,
    sum(coalesce(cpe.price, 0)) as sum_cpe_price
FROM
    event e
LEFT JOIN
    currency_purchase_event cpe ON e.event_id = cpe.event_id
WHERE
    e.event_date = (SELECT max(event_date) FROM event)
GROUP BY
    e.device_udid;
