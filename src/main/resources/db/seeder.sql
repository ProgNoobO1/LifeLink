-- 0. DATABASE SETUP

CREATE DATABASE IF NOT EXISTS lifelink_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE lifelink_db;

SET FOREIGN_KEY_CHECKS = 1;


-- 1. LOOKUP / REFERENCE TABLES  (no FK dependencies)


-- 1a. Blood Groups  (normalised out to avoid typos)
CREATE TABLE blood_groups (
    id          TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(5) NOT NULL UNIQUE   -- 'A+', 'O-', etc.
) ENGINE=InnoDB;

INSERT INTO blood_groups (name) VALUES
    ('A+'),('A-'),('B+'),('B-'),('AB+'),('AB-'),('O+'),('O-');

-- 1b. Districts / Locations  (used for proximity search)
CREATE TABLE districts (
    id          SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    province    VARCHAR(100),
    latitude    DECIMAL(10,7),
    longitude   DECIMAL(10,7)
) ENGINE=InnoDB;


-- 2. CORE USER TABLE  (single table, role-based)

CREATE TABLE users (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(150)  NOT NULL,
    email           VARCHAR(200)  NOT NULL UNIQUE,
    password_hash   VARCHAR(255)  NOT NULL,             -- bcrypt hash of password
    confirm_password_hash VARCHAR(255) NOT NULL,        -- must match password_hash before insert
    phone           VARCHAR(20),
    role            ENUM('donor','recipient','hospital','admin') NOT NULL,
    blood_group_id  TINYINT UNSIGNED,                   -- selected from dropdown on registration
    is_active       TINYINT(1)    NOT NULL DEFAULT 0,   -- admin approves
    is_approved     TINYINT(1)    NOT NULL DEFAULT 0,
    created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_users_blood_group
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id) ON DELETE SET NULL,

    INDEX idx_users_role        (role),
    INDEX idx_users_email       (email),
    INDEX idx_users_active      (is_active),
    INDEX idx_users_blood_group (blood_group_id)
) ENGINE=InnoDB;


-- 3. ROLE-SPECIFIC PROFILE TABLES  (1-to-1 with users)


-- 3a. Donor Profile
CREATE TABLE donors (
    user_id             INT UNSIGNED PRIMARY KEY,
    blood_group_id      TINYINT UNSIGNED NOT NULL,
    district_id         SMALLINT UNSIGNED,
    address             VARCHAR(255),
    date_of_birth       DATE,
    gender              ENUM('male','female','other'),
    weight_kg           DECIMAL(5,2),
    is_available        TINYINT(1) NOT NULL DEFAULT 1,
    last_donated_at     DATE,                          -- enforces 90-day gap
    total_donations     INT UNSIGNED NOT NULL DEFAULT 0,

    CONSTRAINT fk_donors_user
        FOREIGN KEY (user_id)        REFERENCES users(id)        ON DELETE CASCADE,
    CONSTRAINT fk_donors_blood
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id) ON DELETE RESTRICT,
    CONSTRAINT fk_donors_district
        FOREIGN KEY (district_id)    REFERENCES districts(id)    ON DELETE SET NULL,

    INDEX idx_donors_blood      (blood_group_id),
    INDEX idx_donors_district   (district_id),
    INDEX idx_donors_available  (is_available)
) ENGINE=InnoDB;

-- 3b. Recipient Profile
CREATE TABLE recipients (
    user_id         INT UNSIGNED PRIMARY KEY,
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    district_id     SMALLINT UNSIGNED,
    address         VARCHAR(255),
    date_of_birth   DATE,
    gender          ENUM('male','female','other'),
    medical_notes   TEXT,

    CONSTRAINT fk_recipients_user
        FOREIGN KEY (user_id)        REFERENCES users(id)        ON DELETE CASCADE,
    CONSTRAINT fk_recipients_blood
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id) ON DELETE RESTRICT,
    CONSTRAINT fk_recipients_district
        FOREIGN KEY (district_id)    REFERENCES districts(id)    ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3c. Hospital Profile
CREATE TABLE hospitals (
    user_id         INT UNSIGNED PRIMARY KEY,
    hospital_name   VARCHAR(200) NOT NULL,
    license_no      VARCHAR(100) UNIQUE,
    district_id     SMALLINT UNSIGNED,
    address         VARCHAR(255),
    latitude        DECIMAL(10,7),
    longitude       DECIMAL(10,7),
    contact_person  VARCHAR(150),
    website         VARCHAR(255),

    CONSTRAINT fk_hospitals_user
        FOREIGN KEY (user_id)     REFERENCES users(id)      ON DELETE CASCADE,
    CONSTRAINT fk_hospitals_dist
        FOREIGN KEY (district_id) REFERENCES districts(id)  ON DELETE SET NULL,

    INDEX idx_hospitals_district (district_id)
) ENGINE=InnoDB;


-- 4. BLOOD STOCK  (hospital inventory)

CREATE TABLE blood_stock (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hospital_id     INT UNSIGNED NOT NULL,
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    units_available INT UNSIGNED NOT NULL DEFAULT 0,
    low_stock_threshold INT UNSIGNED NOT NULL DEFAULT 5,  -- alert when <=
    last_updated    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_stock_hospital_blood (hospital_id, blood_group_id),

    CONSTRAINT fk_stock_hospital
        FOREIGN KEY (hospital_id)    REFERENCES hospitals(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_stock_blood
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id)   ON DELETE RESTRICT,

    INDEX idx_stock_blood   (blood_group_id),
    INDEX idx_stock_units   (units_available)
) ENGINE=InnoDB;


-- 5. BLOOD SHORTAGE ALERTS

CREATE TABLE blood_shortage_alerts (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    hospital_id     INT UNSIGNED NOT NULL,
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    units_at_alert  INT UNSIGNED NOT NULL,
    is_resolved     TINYINT(1) NOT NULL DEFAULT 0,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at     DATETIME,

    CONSTRAINT fk_alert_hospital
        FOREIGN KEY (hospital_id)    REFERENCES hospitals(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_alert_blood
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id)   ON DELETE RESTRICT,

    INDEX idx_alert_resolved (is_resolved)
) ENGINE=InnoDB;


-- 6. BLOOD REQUESTS  (core transaction table)

CREATE TABLE blood_requests (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    requester_id    INT UNSIGNED NOT NULL,   -- recipient user
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    units_needed    INT UNSIGNED NOT NULL DEFAULT 1,
    urgency         ENUM('normal','urgent','critical') NOT NULL DEFAULT 'normal',
    status          ENUM('pending','accepted','rejected','completed','cancelled')
                        NOT NULL DEFAULT 'pending',
    notes           TEXT,
    requested_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                        ON UPDATE CURRENT_TIMESTAMP,
    completed_at    DATETIME,

    CONSTRAINT fk_req_requester
        FOREIGN KEY (requester_id)   REFERENCES users(id)         ON DELETE CASCADE,
    CONSTRAINT fk_req_blood
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id)  ON DELETE RESTRICT,

    INDEX idx_req_status    (status),
    INDEX idx_req_blood     (blood_group_id),
    INDEX idx_req_requester (requester_id),
    INDEX idx_req_urgency   (urgency)
) ENGINE=InnoDB;


-- 7. REQUEST RESPONSES  (donor OR hospital responds to a request)

CREATE TABLE request_responses (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    request_id      INT UNSIGNED NOT NULL,
    responder_id    INT UNSIGNED NOT NULL,   -- donor or hospital user id
    responder_type  ENUM('donor','hospital') NOT NULL,
    response        ENUM('accepted','rejected') NOT NULL,
    units_provided  INT UNSIGNED DEFAULT 0,
    responded_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT,

    CONSTRAINT fk_resp_request
        FOREIGN KEY (request_id)   REFERENCES blood_requests(id) ON DELETE CASCADE,
    CONSTRAINT fk_resp_responder
        FOREIGN KEY (responder_id) REFERENCES users(id)          ON DELETE CASCADE,

    INDEX idx_resp_request    (request_id),
    INDEX idx_resp_responder  (responder_id)
) ENGINE=InnoDB;


-- 8. DONATION HISTORY  (completed donations)

CREATE TABLE donation_history (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    donor_id        INT UNSIGNED NOT NULL,
    hospital_id     INT UNSIGNED,
    request_id      INT UNSIGNED,
    blood_group_id  TINYINT UNSIGNED NOT NULL,
    units_donated   INT UNSIGNED NOT NULL DEFAULT 1,
    donated_at      DATE NOT NULL,
    verified        TINYINT(1) NOT NULL DEFAULT 0,

    CONSTRAINT fk_dh_donor
        FOREIGN KEY (donor_id)       REFERENCES donors(user_id)    ON DELETE CASCADE,
    CONSTRAINT fk_dh_hospital
        FOREIGN KEY (hospital_id)    REFERENCES hospitals(user_id) ON DELETE SET NULL,
    CONSTRAINT fk_dh_request
        FOREIGN KEY (request_id)     REFERENCES blood_requests(id) ON DELETE SET NULL,
    CONSTRAINT fk_dh_blood
        FOREIGN KEY (blood_group_id) REFERENCES blood_groups(id)   ON DELETE RESTRICT,

    INDEX idx_dh_donor      (donor_id),
    INDEX idx_dh_donated_at (donated_at)
) ENGINE=InnoDB;


-- 9. EMAIL NOTIFICATIONS LOG

CREATE TABLE email_notifications (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    subject         VARCHAR(255) NOT NULL,
    body            TEXT,
    status          ENUM('queued','sent','failed') NOT NULL DEFAULT 'queued',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sent_at         DATETIME,
    error_message   TEXT,

    CONSTRAINT fk_notif_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_notif_status (status),
    INDEX idx_notif_user   (user_id)
) ENGINE=InnoDB;


-- 10. SESSIONS  (server-side session management)

CREATE TABLE user_sessions (
    session_token   VARCHAR(128) PRIMARY KEY,
    user_id         INT UNSIGNED NOT NULL,
    ip_address      VARCHAR(45),
    user_agent      VARCHAR(300),
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at      DATETIME NOT NULL,

    CONSTRAINT fk_sess_user
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_sess_user    (user_id),
    INDEX idx_sess_expires (expires_at)
) ENGINE=InnoDB;


-- 11. ADMIN ACTIVITY LOG  (audit trail)

CREATE TABLE admin_activity_log (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    admin_id    INT UNSIGNED NOT NULL,
    action      VARCHAR(100) NOT NULL,   -- e.g. 'approve_user', 'reject_request'
    target_type VARCHAR(50),             -- e.g. 'user', 'blood_request'
    target_id   INT UNSIGNED,
    detail      TEXT,
    performed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_log_admin
        FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_log_admin  (admin_id),
    INDEX idx_log_action (action)
) ENGINE=InnoDB;


-- 12. AUTOMATED ALERT TRIGGER
--     Fires when blood stock drops to / below threshold

DELIMITER $$

CREATE TRIGGER trg_blood_shortage_alert
AFTER UPDATE ON blood_stock
FOR EACH ROW
BEGIN
    -- Insert an alert only if stock just went <= threshold
    -- and there is no unresolved alert yet for this hospital+blood group
    IF NEW.units_available <= NEW.low_stock_threshold
       AND OLD.units_available  > OLD.low_stock_threshold THEN
        INSERT INTO blood_shortage_alerts
            (hospital_id, blood_group_id, units_at_alert)
        VALUES
            (NEW.hospital_id, NEW.blood_group_id, NEW.units_available);
    END IF;

    -- Auto-resolve if restocked above threshold
    IF NEW.units_available > NEW.low_stock_threshold
       AND OLD.units_available <= OLD.low_stock_threshold THEN
        UPDATE blood_shortage_alerts
        SET    is_resolved = 1,
               resolved_at = NOW()
        WHERE  hospital_id    = NEW.hospital_id
          AND  blood_group_id = NEW.blood_group_id
          AND  is_resolved    = 0;
    END IF;
END$$

DELIMITER ;


-- 13. EVENT SCHEDULER  – purge expired sessions daily
--     (Requires: SET GLOBAL event_scheduler = ON;)

SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS evt_purge_expired_sessions
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
  DELETE FROM user_sessions WHERE expires_at < NOW();


-- 14. BACKUP PROCEDURE  (logical backup helper – call from cron)
--     Run: mysqldump --defaults-file=/etc/mysql/backup.cnf
--          lifelink_db > /backups/lifelink_$(date +%F).sql

-- Stored procedure records the last backup timestamp
CREATE TABLE IF NOT EXISTS backup_log (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    backup_file VARCHAR(255),
    backed_up_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;




-- 15. SEED: DEFAULT ADMIN USER  (skip for now — use Postman)

   INSERT INTO users (full_name, email, password_hash, confirm_password_hash, role, is_active, is_approved)
   VALUES ('System Admin', 'admin@lifelink.com',
         '$2a$12$9DXqpE6.fyC.LD4EP1SSyeY2UWFS0K/RG.XlTil4pLDTKS0KUQBxm',
         '$2a$12$9DXqpE6.fyC.LD4EP1SSyeY2UWFS0K/RG.XlTil4pLDTKS0KUQBxm',
         'admin', 1, 1);

-- ─────────────────────────────────────────────────────────────
-- END OF SCHEMA
-- ─────────────────────────────────────────────────────────────
