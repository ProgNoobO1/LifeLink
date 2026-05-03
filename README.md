# LifeLink – Blood Management System

A web-based blood donation management platform built with **Java Servlets**, **Hibernate ORM**, **MySQL**, and **JSP/JSTL**.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend | Java 11, Jakarta EE Servlets |
| ORM | Hibernate 7.3.2.Final |
| Database | MySQL 8.0 |
| Frontend | JSP 3.0, JSTL 3.0, vanilla CSS/JS |
| Build | Maven |
| Server | Apache Tomcat 11 |

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
CREATE DATABASE blood_management_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
```

### 2. Run the seeder

The project includes a **SQL seeder** that creates the `users` table and inserts test data with pre-hashed passwords.

```bash
mysql -u root -p < src/main/resources/db/seeder.sql
```

> **Passwords for test accounts:**
> - `admin1@lifelink.org` → `Admin@123`
> - All other users → `User@123`

### 3. Update DB credentials (if needed)

Edit `src/main/resources/hibernate.cfg.xml`:

```xml
<property name="hibernate.connection.url">
    jdbc:mysql://localhost:3306/blood_management_db?useSSL=false&amp;serverTimezone=UTC
</property>
<property name="hibernate.connection.username">root</property>
<property name="hibernate.connection.password">your_new_password</property>
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

### With IntelliJ IDEA

1. Open the project in IntelliJ
2. Go to **Run → Edit Configurations**
3. Select **Tomcat 11.0.181** (or add a new Local Tomcat Server)
4. Set deployment artifact to `BloodManagementSystem:war exploded`
5. Set context path to `/BloodManagementSystem`
6. Click the **Run** button (▶)

### Access the app

| Page | URL |
|---|---|
| Home/Login | `http://localhost:8080/BloodManagementSystem/` |
| Register | `http://localhost:8080/BloodManagementSystem/register` |
| Admin Dashboard | `http://localhost:8080/BloodManagementSystem/admin/dashboard` |
| Manage Users | `http://localhost:8080/BloodManagementSystem/admin/users` |

**Admin credentials:**
- Email: `admin@lifelink.org`
- Password: `Admin@123`

---

## Project Structure

```
BloodManagementSystem/
├── src/main/java/backend/
│   ├── dao/           # Data Access Objects (UserDAO)
│   ├── filter/        # AdminFilter (session/auth protection)
│   ├── listener/      # AppContextListener (Hibernate lifecycle)
│   ├── model/         # Hibernate entities (User)
│   ├── service/       # Business logic (AuthService, UserService)
│   ├── servlet/       # Controllers (Login, Register, Admin, CRUD)
│   └── utils/         # Helpers (HibernateUtil, PasswordUtil, Seeder)
├── src/main/resources/
│   ├── db/
│   │   └── seeder.sql     # Database seeder
│   └── hibernate.cfg.xml  # Hibernate configuration
├── src/main/webapp/
│   ├── WEB-INF/web.xml
│   ├── includes/          # Reusable components (navbar, sidebar, topbar, footer)
│   ├── views/
│   │   ├── login.jsp
│   │   ├── Register.jsp
│   │   └── Admin/
│   │       ├── adminDashboard.jsp
│   │       └── adminManageUsers.jsp
│   └── index.jsp
└── pom.xml
```

---

## Features

### Authentication
- User login with BCrypt password hashing
- Session-based authentication (30-min timeout)
- Admin-only route protection via `AdminFilter`

### Admin Panel
- **Dashboard** – live stats (donors, recipients, hospitals, total users), blood group distribution chart, recent activity feed
- **Manage Users** – paginated user list with search, add/edit/view/delete modals
- **Dynamic sidebar** – active page highlighting
- **Dynamic top bar** – page title changes based on current view

### User CRUD
- Add new user (with auto-generated password option)
- View user details (AJAX modal with JSON)
- Edit user (pre-filled modal, self-edit protection, last-admin protection)
- Delete user (confirmation modal, self-delete protection, last-admin protection)

### Public Pages
- Landing page (forwards to login)
- Login page
- Registration page

---

## Available Servlets

| URL Pattern | Servlet | Description |
|---|---|---|
| `/login` | `LoginServlet` | Authenticates users, creates session |
| `/logout` | `LogoutServlet` | Invalidates session, clears cookie |
| `/register` | `RegisterServlet` | Creates new donor/recipient/hospital accounts |
| `/admin/dashboard` | `AdminDashboardServlet` | Serves dashboard with real stats |
| `/admin/users` | `UserListServlet` | Paginated user list (7 per page) |
| `/admin/users/add` | `AddUserServlet` | Handles new user form submission |
| `/admin/users/edit` | `EditUserServlet` | Handles user update form |
| `/admin/users/delete` | `DeleteUserServlet` | Handles user deletion |
| `/admin/users/view` | `ViewUserServlet` | Returns user JSON for AJAX modal |

---

## Seeder Reference

### SQL Seeder

**File:** `src/main/resources/db/seeder.sql`

Run to reset the database with fresh test data:

```bash
mysql -u root -p < src/main/resources/db/seeder.sql
```

What it does:
1. Creates `blood_management_db` if it doesn't exist
2. Drops and recreates the `users` table
3. Inserts 12 test users with BCrypt-hashed passwords

### Java Seeder

**File:** `src/main/java/backend/utils/Seeder.java`

Programmatic alternative that uses Hibernate to seed the database. Useful for integration testing or when you want to seed without dropping existing tables.

---

## License

MIT
