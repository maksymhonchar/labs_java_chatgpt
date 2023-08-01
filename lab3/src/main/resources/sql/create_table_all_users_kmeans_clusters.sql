-- Create the table without the foreign key constraint
CREATE TABLE IF NOT EXISTS all_users_kmeans_clusters (
    device_udid VARCHAR(255) PRIMARY KEY,
    sum_cpe_price DECIMAL(10, 2) NOT NULL
    cluster INT NOT NULL
);