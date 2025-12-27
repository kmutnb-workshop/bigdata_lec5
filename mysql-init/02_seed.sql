USE retail_db;

INSERT INTO transactions (txn_ts, customer_id, product_id, qty, amount_thb) VALUES
(NOW(), 101, 1001, 1, 299.00),
(NOW(), 101, 3001, 1, 690.00),
(NOW(), 202, 4001, 1, 2790.00),
(NOW(), 303, 2001, 2, 780.00);
