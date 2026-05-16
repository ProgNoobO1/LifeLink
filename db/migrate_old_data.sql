-- ============================================================
-- Migration: lifelink_database (old) → lifelink_db (new schema)
-- ============================================================

USE lifelink_db;
SET FOREIGN_KEY_CHECKS = 0;

-- 1. CLEAR EXISTING SEED DATA
TRUNCATE TABLE donation_history;
TRUNCATE TABLE request_responses;
TRUNCATE TABLE blood_requests;
TRUNCATE TABLE blood_stock;
TRUNCATE TABLE blood_shortage_alerts;
TRUNCATE TABLE donors;
TRUNCATE TABLE recipients;
TRUNCATE TABLE hospitals;
TRUNCATE TABLE email_notifications;
TRUNCATE TABLE admin_activity_log;
TRUNCATE TABLE user_sessions;
TRUNCATE TABLE backup_log;
TRUNCATE TABLE users;

-- 2. MIGRATE USERS
-- Map first+last → full_name, upper role → lower, status → is_active, copy password_hash
INSERT INTO users (id, full_name, email, password_hash, confirm_password_hash, phone, role, blood_group_id, is_active, is_approved)
SELECT 
    u.id,
    CONCAT(u.first_name, ' ', u.last_name),
    u.email,
    u.password_hash,
    u.password_hash,
    u.phone,
    LOWER(u.role),
    (SELECT bg.id FROM blood_groups bg WHERE bg.name = u.blood_group),
    CASE u.status WHEN 'ACTIVE' THEN 1 ELSE 0 END,
    1
FROM lifelink_database.users u;

ALTER TABLE users AUTO_INCREMENT = 100;

-- 3. CREATE ROLE-SPECIFIC PROFILES

-- Donor profiles
INSERT INTO donors (user_id, blood_group_id, district_id, address, date_of_birth, gender, weight_kg, is_available, last_donated_at, total_donations)
SELECT 
    u.id,
    u.blood_group_id,
    NULL, NULL, NULL, NULL, NULL,
    1,
    NULL,
    (SELECT COUNT(*) FROM lifelink_database.donations d WHERE d.donor_email = u.email)
FROM users u
WHERE u.role = 'donor';

-- Recipient profiles
INSERT INTO recipients (user_id, blood_group_id, district_id, address, date_of_birth, gender, medical_notes)
SELECT 
    u.id,
    u.blood_group_id,
    NULL, NULL, NULL, NULL, NULL
FROM users u
WHERE u.role = 'recipient';

-- Hospital profiles
INSERT INTO hospitals (user_id, hospital_name, license_no, district_id, address, latitude, longitude, contact_person, website)
SELECT 
    u.id,
    u.full_name,
    CONCAT('HOSP-', LPAD(u.id, 3, '0')),
    NULL, NULL, NULL, NULL, NULL, NULL
FROM users u
WHERE u.role = 'hospital';

-- 4. MIGRATE BLOOD REQUESTS
-- Map old status: PENDING→pending, APPROVED→completed, REJECTED→rejected
INSERT INTO blood_requests (id, requester_id, blood_group_id, units_needed, urgency, status, notes, requested_at, updated_at, completed_at)
SELECT 
    br.id,
    (SELECT u.id FROM users u WHERE u.email = br.requester_email),
    (SELECT bg.id FROM blood_groups bg WHERE bg.name = br.blood_group),
    br.units,
    'normal',
    CASE br.status 
        WHEN 'PENDING' THEN 'pending'
        WHEN 'APPROVED' THEN 'completed'
        WHEN 'REJECTED' THEN 'rejected'
    END,
    NULL,
    br.created_at,
    br.created_at,
    CASE WHEN br.status = 'APPROVED' THEN br.created_at ELSE NULL END
FROM lifelink_database.blood_requests br;

ALTER TABLE blood_requests AUTO_INCREMENT = 100;

-- 5. MIGRATE DONATIONS → donation_history
-- Only migrate donations where the donor email matches a user with a donor profile
INSERT INTO donation_history (donor_id, hospital_id, request_id, blood_group_id, units_donated, donated_at, verified)
SELECT 
    d.user_id,
    NULL,
    NULL,
    (SELECT bg.id FROM blood_groups bg WHERE bg.name = old_d.blood_group),
    old_d.units,
    old_d.donation_date,
    1
FROM lifelink_database.donations old_d
JOIN users u ON u.email = old_d.donor_email
JOIN donors d ON d.user_id = u.id;

-- 6. INIT BLOOD STOCK FOR HOSPITALS (default 0 for all blood groups)
INSERT INTO blood_stock (hospital_id, blood_group_id, units_available, low_stock_threshold)
SELECT h.user_id, bg.id, 0, 5
FROM hospitals h
CROSS JOIN blood_groups bg
WHERE NOT EXISTS (
    SELECT 1 FROM blood_stock s 
    WHERE s.hospital_id = h.user_id AND s.blood_group_id = bg.id
);

SET FOREIGN_KEY_CHECKS = 1;
