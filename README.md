🚗 Vehicle Rental System – Database Design & SQL Queries
📌 Project Overview

The Vehicle Rental System is a relational database project developed to manage vehicle rentals efficiently.
It demonstrates robust database schema design, entity relationships, and advanced SQL querying techniques using PostgreSQL.

This system models real-world rental operations such as:

Managing users (customers and admins)

Tracking vehicles and their availability

Handling bookings with statuses and rental periods

Extracting actionable insights through SQL queries

🎯 Project Objectives

Design a normalized relational database

Implement one-to-many and logical one-to-one relationships

Enforce data integrity using constraints

Write professional SQL queries using:

JOIN

WHERE

EXISTS

GROUP BY and HAVING

🗂️ Database Schema Overview
Tables

Users – Stores system users and their roles

Vehicles – Stores vehicle details, pricing, and availability

Bookings – Tracks rental transactions and relationships

Relationships

One User → Many Bookings

One Vehicle → Many Bookings

Logical One-to-One: Each Booking connects exactly one User and one Vehicle

🏗️ Database Schema (DDL)
1️⃣ Users Table

```
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Customer'))
);
```

Purpose:
Stores system users and defines access roles.

Sample Table Data:
| user_id | name | email | phone | role |
| ------- | ------- | ------------------------------------------- | ---------- | -------- |
| 1 | Alice | [alice@mail.com](mailto:alice@mail.com) | 1234567890 | Customer |
| 2 | Bob | [bob@mail.com](mailto:bob@mail.com) | 9876543210 | Admin |
| 3 | Charlie | [charlie@mail.com](mailto:charlie@mail.com) | 4567891230 | Customer |

2️⃣ Vehicles Table
CREATE TABLE vehicles (
vehicle_id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
type VARCHAR(20) NOT NULL CHECK (type IN ('car', 'bike', 'truck')),
model VARCHAR(20),
registration_number VARCHAR(50) NOT NULL UNIQUE,
rental_price NUMERIC(10,2) NOT NULL,
status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'rented', 'maintenance'))
);

Purpose:
Stores vehicle information, pricing, and availability.

Sample Table Data:

| vehicle_id | name           | type  | model | registration_number | rental_price | status      |
| ---------- | -------------- | ----- | ----- | ------------------- | ------------ | ----------- |
| 1          | Toyota Corolla | car   | 2022  | ABC-123             | 50.00        | available   |
| 2          | Honda Civic    | car   | 2023  | DEF-456             | 60.00        | rented      |
| 3          | Yamaha R15     | bike  | 2023  | GHI-789             | 30.00        | available   |
| 4          | Ford F-150     | truck | 2020  | JKL-012             | 100.00       | maintenance |

3️⃣ Bookings Table

CREATE TABLE bookings (
booking_id SERIAL PRIMARY KEY,
user_id INT NOT NULL,
vehicle_id INT NOT NULL,
start_date DATE NOT NULL,
end_date DATE NOT NULL,
status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
total_cost NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),

    CONSTRAINT fk_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)

);

Purpose:
Represents rental transactions and enforces relationships between users and vehicles.

| booking_id | user_id | vehicle_id | start_date | end_date   | status    | total_cost |
| ---------- | ------- | ---------- | ---------- | ---------- | --------- | ---------- |
| 1          | 1       | 2          | 2023-10-01 | 2023-10-05 | completed | 300.00     |
| 2          | 1       | 2          | 2023-11-01 | 2023-11-03 | completed | 180.00     |
| 3          | 3       | 2          | 2023-12-01 | 2023-12-02 | confirmed | 60.00      |
| 4          | 1       | 1          | 2023-12-10 | 2023-12-12 | pending   | 100.00     |

📊 SQL Queries, Purpose & Sample Output
🔹 Query 1: Booking Details with Customer and Vehicle Names (JOIN)

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

Purpose:

Combines data from multiple tables

Provides a complete booking overview

Useful for admin dashboards and reporting

Sample Output:

| booking_id | customer_name | vehicle_name   | start_date | end_date   | status    |
| ---------- | ------------- | -------------- | ---------- | ---------- | --------- |
| 1          | Alice         | Honda Civic    | 2023-10-01 | 2023-10-05 | completed |
| 2          | Alice         | Honda Civic    | 2023-11-01 | 2023-11-03 | completed |
| 3          | Charlie       | Honda Civic    | 2023-12-01 | 2023-12-02 | confirmed |
| 4          | Alice         | Toyota Corolla | 2023-12-10 | 2023-12-12 | pending   |

🔹 Query 2: Vehicles That Have Never Been Booked (EXISTS)

SELECT
v.vehicle_id,
v.name,
v.type,
v.model,
v.registration_number,
v.rental_price,
v.status
FROM vehicles v
WHERE NOT EXISTS (
SELECT 1
FROM bookings b
WHERE b.vehicle_id = v.vehicle_id
);

Purpose:

Identifies unused or idle vehicles

Helps in promotions or fleet optimization

Sample Output:

| vehicle_id | name       | type  | model | registration_number | rental_price | status      |
| ---------- | ---------- | ----- | ----- | ------------------- | ------------ | ----------- |
| 3          | Yamaha R15 | bike  | 2023  | GHI-789             | 30.00        | available   |
| 4          | Ford F-150 | truck | 2020  | JKL-012             | 100.00       | maintenance |

🔹 Query 3: Available Vehicles of a Specific Type (WHERE)

SELECT
vehicle_id,
name,
type,
model,
registration_number,
rental_price,
status
FROM vehicles
WHERE status = 'available'
AND type = 'car';

Purpose:

Helps customers find available vehicles

Filters results based on business requirements

Sample Output:

| vehicle_id | name           | type | model | registration_number | rental_price | status    |
| ---------- | -------------- | ---- | ----- | ------------------- | ------------ | --------- |
| 1          | Toyota Corolla | car  | 2022  | ABC-123             | 50.00        | available |

🔹 Query 4: Vehicles with More Than 2 Bookings (GROUP BY & HAVING)

SELECT
v.name AS vehicle_name,
COUNT(b.booking_id) AS total_bookings
FROM bookings b
INNER JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY v.name
HAVING COUNT(b.booking_id) > 2;

Purpose:

Identifies high-demand vehicles

Useful for pricing and demand analysis

Sample Output:

| vehicle_name | total_bookings |
| ------------ | -------------- |
| Honda Civic  | 3              |

🧠 Key Concepts Demonstrated

Relational database modeling

Primary & foreign key constraints

Logical one-to-one relationships

SQL joins and subqueries

Aggregate functions and filtering

✅ Conclusion

This project presents a complete, professional, and well-structured database solution for a Vehicle Rental System.
It satisfies functional, academic, and real-world requirements while demonstrating professional SQL usage.

📁 Project Files
File Description
schema.sql Table creation scripts
queries.sql SQL queries
README.md Project documentation

Author: Ahbab Tahmim
Frontend / MERN Stack Developer
