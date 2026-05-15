-- ============================================================
-- LifeLink Blood Management System - Database Seeder
-- Database: lifelink_database
-- MySQL 8.0
-- ============================================================

CREATE DATABASE IF NOT EXISTS lifelink_database
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE lifelink_database;

-- ------------------------------------------------------------
-- Drop existing table (WARNING: deletes all data)
-- ------------------------------------------------------------
DROP TABLE IF EXISTS users;

-- ------------------------------------------------------------
-- Create users table
-- ------------------------------------------------------------
CREATE TABLE users (
                       id              BIGINT AUTO_INCREMENT PRIMARY KEY,
                       first_name      VARCHAR(50)  NOT NULL,
                       last_name       VARCHAR(50)  NOT NULL,
                       email           VARCHAR(100) NOT NULL UNIQUE,
                       phone           VARCHAR(20)  NULL,
                       blood_group     VARCHAR(5)   NULL,
                       password_hash   VARCHAR(255) NOT NULL,
                       role            ENUM('ADMIN','DONOR','HOSPITAL','RECIPIENT') NOT NULL,
                       status          ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- Seed data
-- Password legend (all seeded users share the same hash for convenience):
--   Admin@123   -> BCrypt hash below
--   User@123    -> BCrypt hash below
-- ------------------------------------------------------------

INSERT INTO users (first_name, last_name, email, phone, blood_group, password_hash, role, status) VALUES
-- Admin
('System', 'Admin', 'admin1@lifelink.org', '9800000000', NULL,
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'ADMIN', 'ACTIVE'),

-- Donors
('Sarah', 'Johnson', 'sarah.j@email.com', '9801111111', 'A+',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'DONOR', 'ACTIVE'),

('Aisha', 'Patel', 'aisha.p@email.com', '9803333333', 'B+',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'DONOR', 'ACTIVE'),

('James', 'Osei', 'james.o@email.com', '9804444444', 'AB+',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'RECIPIENT', 'SUSPENDED'),

('Priya', 'Nair', 'priya.n@email.com', '9805555555', 'O+',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'DONOR', 'ACTIVE'),

('Linda', 'Torres', 'l.torres@email.com', '9807777777', 'B+',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'DONOR', 'INACTIVE'),

('Ekta', 'Rai', 'ektarai23@gmail.com', '9805463211', 'A+',
 '$2a$12$7K966lAZ07WNveA1FU/rH.h4tk0x4j979c32CPMNRRkPXj7p2a5kK',
 'DONOR', 'ACTIVE'),

-- Recipients
('Michael', 'Chen', 'm.chen@email.com', '9802222222', 'O-',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'RECIPIENT', 'ACTIVE'),

('Rajesh', 'Kumar', 'rajesh.k@email.com', '9808888888', 'A-',
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'RECIPIENT', 'ACTIVE'),

('Prativa', 'Rai', 'prativa23@gmail.com', '9805463213', 'B+',
 '$2a$12$q8U4/g0CeCGEO5xdazh5BeeWi/sIG38A18Vr8q1nrOEDs7s/WL/cO',
 'RECIPIENT', 'ACTIVE'),

-- Hospitals
('David', 'Mensah', 'd.mensah@hospital.org', '9806666666', NULL,
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'HOSPITAL', 'ACTIVE'),

('City', 'General Hospital', 'info@citygeneral.org', '9809999999', NULL,
 '$2a$12$34q9Y0flQqZC62KLVhIWSOfrbsHsCHKdM8K8rXSHtHTnmnUV7FXQW',
 'HOSPITAL', 'ACTIVE');

-- ------------------------------------------------------------
-- Verify counts
-- ------------------------------------------------------------
SELECT
    COUNT(*) AS total_users,
    SUM(role = 'ADMIN')    AS admins,
    SUM(role = 'DONOR')    AS donors,
    SUM(role = 'RECIPIENT') AS recipients,
    SUM(role = 'HOSPITAL') AS hospitals
FROM users;
