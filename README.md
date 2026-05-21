# LifeLink – Blood Donation Management System

A web-based blood donation management platform built with **Java Servlets**, **JDBC/HikariCP**, **MySQL**, and **JSP/JSTL**. LifeLink connects donors, recipients, and hospitals to streamline the entire blood donation lifecycle — from donor registration and blood stock management to recipient requests and hospital coordination.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java 11, Jakarta EE Servlets 6.0 |
| Database Access | JDBC with HikariCP 6.2.1 connection pool |
| Database | MySQL 8.0 |
| Frontend | JSP 3.0, JSTL 3.0, vanilla CSS/JS |
| Build | Maven |
| Server | Apache Tomcat 11 |
| Security | BCrypt password hashing (jBCrypt 0.4) |
| Email | Jakarta Mail 2.0 |
| PDF Export | OpenPDF 2.0 |
| JSON | Gson 2.10.1 |
| Testing | JUnit 4.13.2, Mockito 4.11.0 |

---

## Prerequisites

- JDK 11 or higher
- Maven 3.8+
- MySQL 8.0
- Apache Tomcat 11 (or IntelliJ bundled Tomcat)

---

## Database Setup

### 1. Create the database

```sql
CREATE DATABASE lifelink_database
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
```

### 2. Run the seeder

The project includes a **SQL seeder** that creates all tables and inserts test data with pre-hashed passwords.

```bash
mysql -u root -p < src/main/resources/db/seeder.sql
```

> **Passwords for test accounts:**
> - `admin1@lifelink.org` → `Admin@123`
> - All other users → `User@123`

### 3. Update DB credentials (if needed)

Edit `src/main/resources/db.properties` (or `DBConnection.java` in utils):

```
db.url=jdbc:mysql://localhost:3306/lifelink_database?useSSL=false&serverTimezone=UTC
db.username=root
db.password=your_password
```

---

## Build & Run

### With Maven

```bash
mvn clean package
```

The WAR file is generated at:
```
target/BloodManagementSystem.war
```

Deploy to Tomcat's `webapps/` directory, or use the Jetty plugin for quick local testing:

```bash
mvn jetty:run
```

### With IntelliJ IDEA

1. Open the project in IntelliJ
2. Go to **Run → Edit Configurations**
3. Select **Tomcat 11** (or add a new Local Tomcat Server)
4. Set deployment artifact to `BloodManagementSystem:war exploded`
5. Set context path to `/BloodManagementSystem`
6. Click the **Run** button (▶)

### Access the app

| Page | URL |
|---|---|
| Home | `http://localhost:8081/BloodManagementSystem/` |
| Login | `http://localhost:8081/BloodManagementSystem/login` |
| Register | `http://localhost:8081/BloodManagementSystem/register` |
| Admin Dashboard | `http://localhost:8081/BloodManagementSystem/admin/dashboard` |
| Donor Dashboard | `http://localhost:8081/BloodManagementSystem/donor/dashboard` |
| Recipient Dashboard | `http://localhost:8081/BloodManagementSystem/recipient/dashboard` |
| Hospital Dashboard | `http://localhost:8081/BloodManagementSystem/hospital/dashboard` |

**Admin credentials:**
- Email: `admin1@lifelink.org`
- Password: `Admin@123`

---

## Project Structure

```
LifeLink/
├── src/main/java/com/lifelink/
│   ├── dao/                        # Data Access Objects (JDBC queries)
│   │   ├── AdminActivityLogDAO.java
│   │   ├── BloodRequestDAO.java
│   │   ├── BloodShortageAlertDAO.java
│   │   ├── BloodStockDAO.java
│   │   ├── DistrictDAO.java
│   │   ├── DonationHistoryDAO.java
│   │   ├── DonorDAO.java
│   │   ├── EmailNotificationDAO.java
│   │   ├── HospitalDAO.java
│   │   ├── HospitalDashboardDAO.java
│   │   ├── HospitalRequestDAO.java
│   │   ├── NotificationDAO.java
│   │   ├── RecipientDAO.java
│   │   ├── RecipientDashboardDAO.java
│   │   ├── RecipientProfileDAO.java
│   │   ├── ReportDAO.java
│   │   ├── RequestDAO.java
│   │   ├── RequestDetailDAO.java
│   │   ├── RequestResponseDAO.java
│   │   ├── SearchDAO.java
│   │   ├── UsageHistoryDAO.java
│   │   ├── UserDAO.java
│   │   └── UserSessionDAO.java
│   ├── filter/
│   │   └── AdminFilter.java        # Session/auth protection for admin routes
│   ├── listener/
│   │   └── AppContextListener.java # HikariCP pool lifecycle management
│   ├── model/                      # Plain Java model classes
│   │   ├── AdminActivityLog.java
│   │   ├── BloodRequest.java
│   │   ├── BloodShortageAlert.java
│   │   ├── BloodStock.java
│   │   ├── District.java
│   │   ├── DonationHistory.java
│   │   ├── Donor.java
│   │   ├── EmailNotification.java
│   │   ├── Hospital.java
│   │   ├── Notification.java
│   │   ├── Recipient.java
│   │   ├── RequestResponse.java
│   │   ├── User.java
│   │   └── UserSession.java
│   ├── service/                    # Business logic layer
│   │   ├── AuthService.java
│   │   ├── AuthException.java
│   │   ├── EmailService.java
│   │   ├── NotificationService.java
│   │   └── UserService.java
│   ├── servlet/                    # Controllers (one per feature)
│   └── utils/
│       ├── DBConnection.java       # HikariCP connection pool setup
│       └── PasswordUtil.java       # BCrypt helpers
├── src/main/resources/
│   ├── db/
│   │   └── seeder.sql              # Full schema + test data
│   └── hibernate.cfg.xml
├── src/main/webapp/
│   ├── views/
│   │   ├── Admin/                  # Admin JSP views
│   │   ├── recipient/              # Recipient JSP views
│   │   ├── donor_*.jsp             # Donor views
│   │   ├── Home.jsp
│   │   ├── login.jsp
│   │   ├── Register.jsp
│   │   ├── contact.jsp
│   │   └── aboutus.jsp
│   ├── hospital/                   # Hospital JSP views
│   ├── includes/                   # Reusable partials (navbar, sidebar, footer)
│   ├── WEB-INF/web.xml
│   └── index.jsp
└── pom.xml
```

---

## Features

### Authentication & Authorization
- User registration with role selection (Donor / Recipient / Hospital)
- BCrypt password hashing
- Session-based authentication with 30-minute timeout
- Role-based route protection via `AdminFilter`

### Admin Panel
- **Dashboard** – live stats (donors, recipients, hospitals, total users), blood group distribution chart, recent activity feed
- **Manage Users** – paginated list with search, add/edit/view/delete modals, approve/reject pending accounts
- **Blood Requests** – view and manage all incoming blood requests across roles
- **Reports** – generate and export PDF/CSV reports via `ReportsExportServlet`
- **Activity Logs** – audit trail of admin actions

### Donor Module
- Donor profile management
- View donation history
- Respond to blood requests from recipients/hospitals
- Dashboard with pending and past donation activity

### Recipient Module
- Create blood requests with blood type, urgency, and location details
- Search for available donors by blood group and district
- Track request status (pending → approved → fulfilled)
- View and manage all submitted requests
- Edit profile details

### Hospital Module
- Hospital profile and registration management
- Blood stock management (add stock, track usage history)
- Create blood requests and manage request lifecycle
- Blood shortage alerts
- Usage history tracking
- Email notifications for critical stock levels

### Notifications & Email
- In-app notification system for all user roles
- Email notifications via Jakarta Mail for key events (request updates, stock alerts)

---

## Available Servlets

### Auth
| URL Pattern | Servlet | Description |
|---|---|---|
| `/login` | `LoginServlet` | Authenticates users, creates session |
| `/logout` | `LogoutServlet` | Invalidates session |
| `/register` | `RegisterServlet` | Creates new accounts (donor/recipient/hospital) |

### Admin
| URL Pattern | Servlet | Description |
|---|---|---|
| `/admin/dashboard` | `AdminDashboardServlet` | Dashboard with live stats |
| `/admin/users` | `UserListServlet` | Paginated user list |
| `/admin/users/add` | `AddUserServlet` | Add new user |
| `/admin/users/edit` | `EditUserServlet` | Edit user details |
| `/admin/users/delete` | `DeleteUserServlet` | Delete user |
| `/admin/users/view` | `ViewUserServlet` | Returns user JSON for AJAX modal |
| `/admin/users/approve` | `ApproveUserServlet` | Approve pending accounts |
| `/admin/users/reject` | `RejectUserServlet` | Reject pending accounts |
| `/admin/requests` | `AdminRequestServlet` | View/manage all blood requests |
| `/admin/reports` | `AdminReportsServlet` | Generate reports |
| `/admin/reports/export` | `ReportsExportServlet` | Export reports as PDF/CSV |

### Donor
| URL Pattern | Servlet | Description |
|---|---|---|
| `/donor/*` | `DonorServlet` | Donor dashboard, profile, history, requests |

### Recipient
| URL Pattern | Servlet | Description |
|---|---|---|
| `/recipient/dashboard` | `RecipientDashboardServlet` | Recipient dashboard |
| `/recipient/profile` | `RecipientProfileServlet` | Edit profile |
| `/recipient/requests` | `RequestServlet` | View/create blood requests |
| `/recipient/requests/action` | `RequestActionServlet` | Accept/cancel request responses |
| `/recipient/requests/export` | `RequestExportServlet` | Export request details |
| `/recipient/search` | `SearchServlet` | Search donors by blood group/district |

### Hospital
| URL Pattern | Servlet | Description |
|---|---|---|
| `/hospital/dashboard` | `HospitalDashboardServlet` | Hospital dashboard |
| `/hospital/profile` | `HospitalProfileServlet` | Manage hospital profile |
| `/hospital/requests` | `HospitalRequestServlet` | Manage blood requests |
| `/hospital/stock` | `BloodStockServlet` | Blood stock management |
| `/hospital/usage` | `UsageHistoryServlet` | Blood usage history |

### Shared
| URL Pattern | Servlet | Description |
|---|---|---|
| `/notifications` | `NotificationServlet` | View notifications |
| `/api/notifications` | `NotificationApiServlet` | Notification count API (AJAX) |

---

## Database Schema Overview

Key tables managed via `seeder.sql`:

| Table | Description |
|---|---|
| `users` | All user accounts with roles (admin, donor, recipient, hospital) |
| `donors` | Donor-specific profile data |
| `recipients` | Recipient-specific profile data |
| `hospitals` | Hospital profile and location data |
| `blood_requests` | Requests raised by recipients or hospitals |
| `blood_stock` | Per-hospital blood inventory by blood group |
| `donation_history` | Completed donation records |
| `usage_history` | Hospital blood usage records |
| `notifications` | In-app notification records |
| `email_notifications` | Email notification log |
| `blood_shortage_alerts` | Triggered when stock falls below threshold |
| `admin_activity_log` | Audit log for admin actions |
| `districts` | District reference table for location filtering |
| `user_sessions` | Active session tracking |

---

## Seeder Reference

**File:** `src/main/resources/db/seeder.sql`

Run to reset the database with fresh test data:

```bash
mysql -u root -p < src/main/resources/db/seeder.sql
```

What it does:
1. Creates `lifelink_database` if it doesn't exist
2. Drops and recreates all tables with proper foreign key constraints
3. Seeds reference data (districts, blood groups)
4. Inserts test users across all roles with BCrypt-hashed passwords

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "Add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request against `main`

---

## License

MIT
