-- ======================================
-- DROP TABLES (for safe re-run)
-- ======================================

DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS users;

-- ======================================
-- USERS TABLE
-- ======================================

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Customer'))
);

-- ======================================
-- VEHICLES TABLE
-- ======================================

CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('car', 'bike', 'truck')),
    model VARCHAR(20),
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    rental_price NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL 
        CHECK (status IN ('available', 'rented', 'maintenance'))
);

-- ======================================
-- BOOKINGS TABLE
-- ======================================

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL 
        CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    total_cost NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),

    CONSTRAINT fk_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);

-- ======================================
-- QUERY 1: JOIN
-- Retrieve booking info with customer & vehicle names
-- ======================================

SELECT
    b.booking_id,
    u.name AS customer_name,
    v.name AS vehicle_name,
    b.start_date,
    b.end_date,
    b.status
FROM bookings b
INNER JOIN users u ON b.user_id = u.user_id
INNER JOIN vehicles v ON b.vehicle_id = v.vehicle_id
ORDER BY b.booking_id;

-- ======================================
-- QUERY 2: EXISTS
-- Vehicles that have never been booked
-- ======================================

SELECT
    v.vehicle_id,
    v.name,
    v.type,
    v.model,
    v.registration_number,
    v.price_per_day AS rental_price,
    v.status
FROM vehicles v
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings b
    WHERE b.vehicle_id = v.vehicle_id
);

-- ======================================
-- QUERY 3: WHERE
-- Available vehicles of a specific type (example: car)
-- ======================================

SELECT
    vehicle_id,
    name,
    type,
    model,
    registration_number,
    price_per_day AS rental_price,
    status
FROM vehicles
WHERE status = 'available'
  AND type = 'car';

-- ======================================
-- QUERY 4: GROUP BY & HAVING
-- Vehicles with more than 2 bookings
-- ======================================

SELECT
    v.name AS vehicle_name,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
INNER JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY v.name
HAVING COUNT(b.booking_id) > 2;
