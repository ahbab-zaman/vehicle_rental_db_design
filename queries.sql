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
    v.rental_price AS rental_price,
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
    rental_price AS rental_price,
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
