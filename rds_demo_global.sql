
-- Amazon RDS Demo SQL — Global Version
-- Creates schema, tables, and seeds diverse global data

-- 0) Create schema
CREATE SCHEMA IF NOT EXISTS mlh_demo;
SET search_path TO mlh_demo, public;

-- 1) Clean slate
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 2) Tables
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  first_name  VARCHAR(50) NOT NULL,
  last_name   VARCHAR(50) NOT NULL,
  email       VARCHAR(120) UNIQUE NOT NULL,
  city        VARCHAR(80),
  country     VARCHAR(80),
  created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE orders (
  order_id     SERIAL PRIMARY KEY,
  customer_id  INT NOT NULL REFERENCES customers(customer_id),
  order_date   DATE NOT NULL,
  amount_usd   NUMERIC(10,2) NOT NULL CHECK (amount_usd >= 0),
  status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  item         VARCHAR(100)
);

-- 3) Seed global customers
INSERT INTO customers (first_name, last_name, email, city, country) VALUES
  ('Maria',   'Gonzalez', 'maria.g@example.com',    'Madrid',        'Spain'),
  ('John',    'Smith',    'john.smith@example.com', 'New York',      'USA'),
  ('Aisha',   'Bello',    'aisha.bello@example.com','Lagos',         'Nigeria'),
  ('Kenji',   'Tanaka',   'kenji.t@example.com',    'Tokyo',         'Japan'),
  ('Amira',   'Hassan',   'amira.h@example.com',    'Cairo',         'Egypt'),
  ('Priya',   'Sharma',   'priya.s@example.com',    'Delhi',         'India'),
  ('Luca',    'Rossi',    'luca.r@example.com',     'Milan',         'Italy'),
  ('Mei',     'Chen',     'mei.chen@example.com',   'Beijing',       'China'),
  ('Fatima',  'Khan',     'fatima.khan@example.com','Karachi',       'Pakistan'),
  ('Carlos',  'Silva',    'carlos.s@example.com',   'São Paulo',     'Brazil');

-- 4) Seed orders with fun items
INSERT INTO orders (customer_id, order_date, amount_usd, status, item) VALUES
  (1, '2025-08-01', 120.00, 'PAID',      'Laptop'),
  (2, '2025-08-02', 300.50, 'PAID',      'Sneakers'),
  (3, '2025-08-03', 45.00,  'REFUNDED',  'Headphones'),
  (4, '2025-08-04', 99.90,  'PAID',      'Manga Set'),
  (5, '2025-08-05', 10.00,  'PENDING',   'Shawarma Wrap'),
  (6, '2025-08-06', 75.75,  'PAID',      'Cricket Bat'),
  (7, '2025-08-07', 60.00,  'PENDING',   'Espresso Machine'),
  (8, '2025-08-08', 150.00, 'PAID',      'Smartphone'),
  (9, '2025-08-09', 20.00,  'CANCELLED', 'Soccer Ball'),
  (10,'2025-08-10', 15.00,  'PAID',      'Guitar Strings');

-- 5) SELECT basics
SELECT * FROM customers;
SELECT first_name, city, country FROM customers WHERE country = 'Nigeria';
SELECT * FROM orders WHERE status = 'PAID';

-- 6) Aggregations
SELECT SUM(amount_usd) AS total_revenue FROM orders WHERE status = 'PAID';

SELECT c.country, ROUND(SUM(o.amount_usd),2) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'PAID'
GROUP BY c.country
ORDER BY revenue DESC;

-- 7) Updates & deletes
UPDATE orders SET status = 'CANCELLED'
WHERE status = 'PENDING' AND amount_usd < 50;

DELETE FROM customers WHERE email = 'test@example.com';

-- 8) View: Global sales leaderboard
CREATE OR REPLACE VIEW country_sales AS
SELECT c.country, COUNT(*) AS orders_count, ROUND(SUM(o.amount_usd),2) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.status = 'PAID'
GROUP BY c.country;

SELECT * FROM country_sales ORDER BY revenue DESC;
