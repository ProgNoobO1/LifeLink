-- =========================================================================
-- LifeLink Blood Donation Management System - Unified Database Schema
-- Aligning perfectly with the actual live MySQL database (`lifelink_db`)
-- =========================================================================

CREATE DATABASE IF NOT EXISTS lifelink_db;
USE lifelink_db;

-- ═════════════════════════════════════════════════════════════════════════
-- 1. LOOKUP & REFERENCE TABLES
-- ═════════════════════════════════════════════════════════════════════════

-- Blood Groups Lookup
CREATE TABLE IF NOT EXISTS blood_groups (
    id   TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(5) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Districts Lookup
CREATE TABLE IF NOT EXISTS districts (
    id        SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(100) NOT NULL,
    province  VARCHAR(100),
    latitude  DECIMAL(10, 7),
    longitude DECIMAL(10, 7)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═════════════════════════════════════════════════════════════════════════
-- 2. USERS & PROFILES
-- ═════════════════════════════════════════════════════════════════════════

-- Core Users Table
CREATE TABLE IF NOT EXISTS users (
    id                    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name             VARCHAR(150) NOT NULL,
    email                 VARCHAR(200) NOT NULL UNIQUE,
    password_hash         VARCHAR(255) NOT NULL,
    confirm_password_hash VARCHAR(255) NOT NULL,
    phone                 VARCHAR(20),
    role                  ENUM('donor', 'recipient', 'hospital', 'admin') NOT NULL,
    blood_group_id        TINYINT UNSIGNED,
    is_active             TINYINT(1) NOT NULL DEFAULT 0,
    is_approved           TINYINT(1) NOT NULL DEFAULT 0,
    created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id) ON DELETE SET NULL,
    INDEX idx_user_role (role),
    INDEX idx_user_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Donors Profile Extension
CREATE TABLE IF NOT EXISTS donors (
    user_id          INT UNSIGNED PRIMARY KEY,
    blood_group_id   TINYINT UNSIGNED NOT NULL,
    district_id      SMALLINT UNSIGNED,
    address          VARCHAR(255),
    date_of_birth    DATE,
    gender           ENUM('male', 'female', 'other'),
    weight_kg        DECIMAL(5, 2),
    is_available     TINYINT(1) NOT NULL DEFAULT 1,
    last_donated_at  DATE,
    total_donations  INT UNSIGNED NOT NULL DEFAULT 0,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id),
    FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE SET NULL,
    INDEX idx_donor_available (is_available),
    INDEX idx_donor_blood (blood_group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Recipients Profile Extension
CREATE TABLE IF NOT EXISTS recipients (
    user_id          INT UNSIGNED PRIMARY KEY,
    blood_group_id   TINYINT UNSIGNED NOT NULL,
    district_id      SMALLINT UNSIGNED,
    address          VARCHAR(255),
    date_of_birth    DATE,
    gender           ENUM('male', 'female', 'other'),
    medical_notes    TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id),
    FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE SET NULL,
    INDEX idx_recipient_blood (blood_group_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Hospitals Profile Extension
CREATE TABLE IF NOT EXISTS hospitals (
    user_id         INT UNSIGNED PRIMARY KEY,
    hospital_name   VARCHAR(150) NOT NULL,
    license_no      VARCHAR(100),
    district_id     SMALLINT UNSIGNED,
    address         TEXT,
    latitude        DECIMAL(10, 8),
    longitude       DECIMAL(11, 8),
    contact_person  VARCHAR(100),
    website         VARCHAR(150),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (district_id) REFERENCES districts(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═════════════════════════════════════════════════════════════════════════
-- 3. STOCK & LOGISTICS
-- ═════════════════════════════════════════════════════════════════════════

-- Blood Stock Inventory Table
CREATE TABLE IF NOT EXISTS blood_stock (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hospital_id         INT UNSIGNED NOT NULL,
    blood_group_id      TINYINT UNSIGNED NOT NULL,
    units_available     INT UNSIGNED NOT NULL DEFAULT 0,
    low_stock_threshold INT UNSIGNED NOT NULL DEFAULT 15,
    last_updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_hospital_blood_group (hospital_id, blood_group_id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(user_id) ON DELETE CASCADE,
    FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Blood Requests Table
CREATE TABLE IF NOT EXISTS blood_requests (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    requester_id    INT UNSIGNED NOT NULL,
    hospital_id     INT UNSIGNED,
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    units_needed    INT UNSIGNED NOT NULL DEFAULT 1,
    urgency         ENUM('normal', 'urgent', 'critical') NOT NULL DEFAULT 'normal',
    status          ENUM('pending', 'accepted', 'rejected', 'completed', 'cancelled') NOT NULL DEFAULT 'pending',
    notes           TEXT,
    requested_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    completed_at    DATETIME,
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(user_id) ON DELETE SET NULL,
    FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id),
    INDEX idx_request_status (status),
    INDEX idx_request_urgency (urgency)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Usage History Table
CREATE TABLE IF NOT EXISTS usage_history (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hospital_id     INT UNSIGNED NOT NULL,
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    units_used      INT UNSIGNED NOT NULL DEFAULT 1,
    request_id      INT UNSIGNED,
    reason          VARCHAR(255),
    used_at         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(user_id) ON DELETE CASCADE,
    FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id),
    FOREIGN KEY (request_id) REFERENCES blood_requests(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ═════════════════════════════════════════════════════════════════════════
-- 4. SEED & REFERENCE DATA
-- ═════════════════════════════════════════════════════════════════════════

-- Populate Blood Groups
INSERT INTO blood_groups (id, name) VALUES
(1, 'A+'),
(2, 'A-'),
(3, 'B+'),
(4, 'B-'),
(5, 'AB+'),
(6, 'AB-'),
(7, 'O+'),
(8, 'O-')
ON DUPLICATE KEY UPDATE name = VALUES(name);
