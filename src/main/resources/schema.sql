-- Database Creation
CREATE DATABASE IF NOT EXISTS lifelink;
USE lifelink;

-- Users table (Base table for Auth)
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('Donor', 'Recipient', 'Hospital', 'Admin') NOT NULL
);

-- Donors table
CREATE TABLE IF NOT EXISTS donors (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    blood_group VARCHAR(5),
    location VARCHAR(100),
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Hospitals table
CREATE TABLE IF NOT EXISTS hospitals (
    hospital_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    phone VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Blood Requests table
CREATE TABLE IF NOT EXISTS blood_requests (
    request_id INT PRIMARY KEY AUTO_INCREMENT,
    hospital_id INT,
    donor_id INT,
    blood_group VARCHAR(5),
    location VARCHAR(100),
    status ENUM('Pending', 'Accepted', 'Rejected', 'Completed') DEFAULT 'Pending',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id) ON DELETE CASCADE,
    FOREIGN KEY (donor_id) REFERENCES donors(user_id) ON DELETE CASCADE
);

-- Sample Data for Testing
INSERT INTO users (email, password, role) VALUES ('donor@lifelink.com', 'pass123', 'Donor');
INSERT INTO donors (user_id, name, email, phone, blood_group, location, is_available) 
VALUES (1, 'Alex Morgan', 'donor@lifelink.com', '+1 (555) 234-7890', 'O+', 'Downtown, New York', TRUE);

INSERT INTO users (email, password, role) VALUES ('hospital@lifelink.com', 'pass123', 'Hospital');
INSERT INTO hospitals (hospital_id, user_id, name, location, phone) 
VALUES (1, 2, 'City General Hospital', 'Central District', '+1 (555) 012-3456');

INSERT INTO blood_requests (hospital_id, donor_id, blood_group, location, status)
VALUES (1, 1, 'O+', 'Central District', 'Pending');
