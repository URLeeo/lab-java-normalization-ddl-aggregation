-- ============================================
-- LAB | SQL Normalization, DDL & Aggregation
-- Full Solution
-- ============================================

-- ============================================
-- CLEANUP
-- ============================================

DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS flights;
DROP TABLE IF EXISTS aircrafts;
DROP TABLE IF EXISTS customers;

DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS authors;

-- ============================================
-- EXERCISE 1: BLOG DATABASE (3NF)
-- ============================================

CREATE TABLE authors (
    author_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    author_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE posts (
    post_id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    title VARCHAR(200) NOT NULL UNIQUE,
    word_count INT NOT NULL CHECK (word_count >= 0),
    views INT NOT NULL CHECK (views >= 0),
    author_id INT NOT NULL,
    CONSTRAINT fk_posts_author
        FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

-- ============================================
-- SAMPLE DATA FOR BLOG DATABASE
-- ============================================

INSERT INTO authors (author_name) VALUES
('Maria Charlotte'),
('Juan Perez'),
('Gemma Alcocer');

INSERT INTO posts (title, word_count, views, author_id) VALUES
('Best Paint Colors', 814, 14, 1),
('Small Space Decorating Tips', 1146, 221, 2),
('Hot Accessories', 986, 105, 1),
('Mixing Textures', 765, 22, 1),
('Kitchen Refresh', 1242, 307, 2),
('Homemade Art Hacks', 1002, 193, 1),
('Refinishing Wood Floors', 1571, 7542, 3);

-- ============================================
-- EXERCISE 2: AIRLINE DATABASE (3NF)
-- ============================================

CREATE TABLE customers (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL UNIQUE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('None', 'Silver', 'Gold')),
    total_mileage INT NOT NULL CHECK (total_mileage >= 0)
);

CREATE TABLE aircrafts (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name VARCHAR(100) NOT NULL UNIQUE,
    total_seats INT NOT NULL CHECK (total_seats > 0)
);

CREATE TABLE flights (
    flight_number VARCHAR(10) PRIMARY KEY,
    aircraft_id INT NOT NULL,
    mileage INT NOT NULL CHECK (mileage >= 0),
    CONSTRAINT fk_flights_aircraft
        FOREIGN KEY (aircraft_id) REFERENCES aircrafts(id)
);

CREATE TABLE bookings (
    id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    customer_id INT NOT NULL,
    flight_number VARCHAR(10) NOT NULL,
    CONSTRAINT fk_bookings_customer
        FOREIGN KEY (customer_id) REFERENCES customers(id),
    CONSTRAINT fk_bookings_flight
        FOREIGN KEY (flight_number) REFERENCES flights(flight_number),
    CONSTRAINT uq_customer_flight UNIQUE (customer_id, flight_number)
);

-- ============================================
-- SAMPLE DATA FOR AIRLINE DATABASE
-- ============================================

-- Aircrafts
INSERT INTO aircrafts (name, total_seats) VALUES
('Boeing 747', 400),
('Airbus A330', 236),
('Boeing 777', 264),
('Boeing 747 (531 seats variant)', 531);

-- Customers
INSERT INTO customers (name, status, total_mileage) VALUES
('Agustine Riviera', 'Silver', 115235),
('Alaina Sepulvida', 'None', 6008),
('Tom Jones', 'Gold', 205767),
('Sam Rio', 'None', 2653),
('Jessica James', 'Silver', 127656),
('Ana Janco', 'Silver', 136773),
('Jennifer Cortez', 'Gold', 300582),
('Christian Janco', 'Silver', 14642);

-- Flights
INSERT INTO flights (flight_number, aircraft_id, mileage) VALUES
('DL143', 1, 135),
('DL122', 2, 4370),
('DL53', 3, 2078),
('DL222', 3, 1765),
('DL37', 4, 531);

-- Bookings
INSERT INTO bookings (customer_id, flight_number) VALUES
(1, 'DL143'),
(1, 'DL122'),
(2, 'DL122'),
(3, 'DL122'),
(3, 'DL53'),
(4, 'DL143'),
(3, 'DL222'),
(5, 'DL143'),
(6, 'DL222'),
(7, 'DL222'),
(5, 'DL122'),
(4, 'DL37'),
(8, 'DL222');

-- ============================================
-- EXTRA CHALLENGE: INDEXES
-- ============================================

CREATE INDEX idx_customers_status ON customers(status);
CREATE INDEX idx_flights_aircraft_id ON flights(aircraft_id);
CREATE INDEX idx_bookings_customer_id ON bookings(customer_id);
CREATE INDEX idx_bookings_flight_number ON bookings(flight_number);

-- ============================================
-- EXERCISE 3: SQL QUERIES ON AIRLINE DATABASE
-- ============================================

-- 1. Total number of flights
SELECT COUNT(DISTINCT flight_number) AS total_flights
FROM flights;

-- 2. Average flight distance
SELECT AVG(mileage) AS avg_flight_distance
FROM flights;

-- 3. Average number of seats per aircraft
SELECT AVG(total_seats) AS avg_seats_per_aircraft
FROM aircrafts;

-- 4. Average miles flown by customers, grouped by status
SELECT status, AVG(total_mileage) AS avg_customer_mileage
FROM customers
GROUP BY status;

-- 5. Max miles flown by customers, grouped by status
SELECT status, MAX(total_mileage) AS max_customer_mileage
FROM customers
GROUP BY status;

-- 6. Number of aircrafts with "Boeing" in their name
SELECT COUNT(*) AS boeing_aircraft_count
FROM aircrafts
WHERE name LIKE '%Boeing%';

-- 7. Flights with distance between 300 and 2000 miles
SELECT *
FROM flights
WHERE mileage BETWEEN 300 AND 2000;

-- 8. Average flight distance booked, grouped by customer status
SELECT c.status, AVG(f.mileage) AS avg_booked_distance
FROM bookings b
JOIN customers c ON b.customer_id = c.id
JOIN flights f ON b.flight_number = f.flight_number
GROUP BY c.status;

-- 9. Most booked aircraft among Gold status members
SELECT a.name, COUNT(*) AS total_bookings
FROM bookings b
JOIN customers c ON b.customer_id = c.id
JOIN flights f ON b.flight_number = f.flight_number
JOIN aircrafts a ON f.aircraft_id = a.id
WHERE c.status = 'Gold'
GROUP BY a.name
ORDER BY total_bookings DESC
LIMIT 1;