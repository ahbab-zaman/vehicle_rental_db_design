# 🚗 Vehicle Rental System – Relational Database Design

## 📌 Project Overview

The **Vehicle Rental System** is a robust relational database project built using **PostgreSQL**. It demonstrates professional database schema design, entity-relationship modeling, data integrity enforcement, and advanced SQL querying techniques.

This system effectively models real-world vehicle rental operations, including:

- User management (customers and administrators)
- Vehicle inventory tracking with availability status
- Booking management with rental periods and transaction statuses
- Actionable business insights through sophisticated queries

## 🎯 Project Objectives

- Design a fully normalized relational database
- Implement one-to-many relationships with proper referential integrity
- Enforce logical one-to-one associations between bookings, users, and vehicles
- Ensure data consistency using constraints (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK)
- Demonstrate professional SQL techniques including JOINs, subqueries (EXISTS), filtering, grouping, and aggregation

## 🗂️ Database Schema

### Entity-Relationship Summary

- **One User** → **Many Bookings**
- **One Vehicle** → **Many Bookings**
- **Logical One-to-One**: Each booking is associated with exactly one user and one vehicle

### 1️⃣ Users Table

```sql
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('Admin', 'Customer'))
);
```

**Purpose** : Stores authenticated system users with role-based access control.

#### Sample Data :

| user_id | name    | email                                       | phone      | role     |
| ------- | ------- | ------------------------------------------- | ---------- | -------- |
| 1       | Alice   | [alice@mail.com](mailto:alice@mail.com)     | 1234567890 | Customer |
| 2       | Bob     | [bob@mail.com](mailto:bob@mail.com)         | 9876543210 | Admin    |
| 3       | Charlie | [charlie@mail.com](mailto:charlie@mail.com) | 4567891230 | Customer |

### 2️⃣ Vehicles Table

```sql
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('car', 'bike', 'truck')),
    model VARCHAR(20),
    registration_number VARCHAR(50) NOT NULL UNIQUE,
    rental_price NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('available', 'rented', 'maintenance'))
);
```

**Purpose** : Manages vehicle inventory, pricing, and current availability status.

#### Sample Data :

| vehicle_id | name           | type  | model | registration_number | rental_price | status      |
| ---------- | -------------- | ----- | ----- | ------------------- | ------------ | ----------- |
| 1          | Toyota Corolla | car   | 2022  | ABC-123             | 50.00        | available   |
| 2          | Honda Civic    | car   | 2023  | DEF-456             | 60.00        | rented      |
| 3          | Yamaha R15     | bike  | 2023  | GHI-789             | 30.00        | available   |
| 4          | Ford F-150     | truck | 2020  | JKL-012             | 100.00       | maintenance |

### 3️⃣ Bookings Table

```sql
CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    vehicle_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
    total_cost NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
);
```

**Purpose** : Records rental transactions and enforces relationships between users and vehicles.

#### Sample Data :

| booking_id | user_id | vehicle_id | start_date | end_date   | status    | total_cost |
| ---------- | ------- | ---------- | ---------- | ---------- | --------- | ---------- |
| 1          | 1       | 2          | 2023-10-01 | 2023-10-05 | completed | 300.00     |
| 2          | 1       | 2          | 2023-11-01 | 2023-11-03 | completed | 180.00     |
| 3          | 3       | 2          | 2023-12-01 | 2023-12-02 | confirmed | 60.00      |
| 4          | 1       | 1          | 2023-12-10 | 2023-12-12 | pending   | 100.00     |

### 📊 Key SQL Queries

#### Query 1: Full Booking Details with Customer and Vehicle Information (JOIN)

```sql
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
```

**Purpose** : Provides a comprehensive view of all bookings for administrative dashboards and reporting.

#### Sample Data :

| booking_id | customer_name | vehicle_name   | start_date | end_date   | status    |
| ---------- | ------------- | -------------- | ---------- | ---------- | --------- |
| 1          | Alice         | Honda Civic    | 2023-10-01 | 2023-10-05 | completed |
| 2          | Alice         | Honda Civic    | 2023-11-01 | 2023-11-03 | completed |
| 3          | Charlie       | Honda Civic    | 2023-12-01 | 2023-12-02 | confirmed |
| 4          | Alice         | Toyota Corolla | 2023-12-10 | 2023-12-12 | pending   |

#### 🔹 Query 2: Vehicles That Have Never Been Booked (EXISTS)

```sql
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
```

**Purpose** :

- Identifies unused or idle vehicles

- Helps in promotions or fleet optimization

#### Sample Data :

| vehicle_id | name       | type  | model | registration_number | rental_price | status      |
| ---------- | ---------- | ----- | ----- | ------------------- | ------------ | ----------- |
| 3          | Yamaha R15 | bike  | 2023  | GHI-789             | 30.00        | available   |
| 4          | Ford F-150 | truck | 2020  | JKL-012             | 100.00       | maintenance |

#### 🔹 Query 3: Available Vehicles of a Specific Type (WHERE)

```sql
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
```

**Purpose** :

- Helps customers find available vehicles

- Filters results based on business requirements

#### Sample Data :

| vehicle_id | name           | type | model | registration_number | rental_price | status    |
| ---------- | -------------- | ---- | ----- | ------------------- | ------------ | --------- |
| 1          | Toyota Corolla | car  | 2022  | ABC-123             | 50.00        | available |

#### 🔹 Query 4: Vehicles with More Than 2 Bookings (GROUP BY & HAVING)

```sql
SELECT
    v.name AS vehicle_name,
    COUNT(b.booking_id) AS total_bookings
FROM bookings b
INNER JOIN vehicles v ON b.vehicle_id = v.vehicle_id
GROUP BY v.name
HAVING COUNT(b.booking_id) > 2;
```

**Purpose** :

- Identifies high-demand vehicles

- Useful for pricing and demand analysis

#### Sample Data :

| vehicle_name | total_bookings |
| ------------ | -------------- |
| Honda Civic  | 3              |

### 🧠 Key Concepts Demonstrated

- Relational database normalization
- Primary and foreign key constraints
- Data integrity through CHECK and UNIQUE constraints
- Multi-table JOIN operations
- Correlated subqueries with EXISTS/NOT EXISTS
- Aggregation with GROUP BY and conditional filtering using HAVING

### ✅ Conclusion

This project delivers a professional, scalable, and well-documented database solution for a vehicle rental platform. It meets both academic standards and real-world operational requirements while showcasing clean, efficient SQL practices.

### 📁 Project Structure

- [queries.sql](./queries.sql) – All demonstrated SQL queries
- [README.md](./README.md) – Project documentation (this file)


