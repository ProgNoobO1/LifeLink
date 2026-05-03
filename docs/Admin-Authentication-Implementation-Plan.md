# Admin User Authentication — Implementation Plan

**Project:** BloodManagementSystem (LifeLink)  
**Tech Stack:** Java Servlets + JSP + Hibernate ORM + MySQL  
**Branch:** `feature/new-feature`  
**Target Role:** Admin  
**Status:** Draft / Ready for Development

---

## 1. Goal

Implement secure user authentication for the **Admin** role so that:
- Only authenticated admins can access `/views/Admin/*` pages.
- Unauthenticated or non-admin users are redirected to the login page.
- Passwords are stored securely (hashed, not plain text).
- Sessions are managed safely with timeout and invalidation on logout.

---

## 2. Database Schema

### 2.1 `users` table (existing concept extended)

| Column        | Type           | Constraints                     | Notes                                |
|---------------|----------------|---------------------------------|--------------------------------------|
| `id`          | BIGINT         | PK, AUTO_INCREMENT              |                                      |
| `first_name`  | VARCHAR(50)    | NOT NULL                        |                                      |
| `last_name`   | VARCHAR(50)    | NOT NULL                        |                                      |
| `email`       | VARCHAR(100)   | NOT NULL, UNIQUE                | Used as login username               |
| `phone`       | VARCHAR(20)    |                                 |                                      |
| `blood_group` | VARCHAR(5)     |                                 | Nullable for admin                   |
| `password_hash`| VARCHAR(255)  | NOT NULL                        | BCrypt hash                          |
| `role`        | ENUM/VARCHAR   | NOT NULL                        | `ADMIN`, `DONOR`, `RECIPIENT`, `HOSPITAL` |
| `status`      | ENUM/VARCHAR   | NOT NULL, DEFAULT `ACTIVE`      | `ACTIVE`, `INACTIVE`, `SUSPENDED`    |
| `created_at`  | TIMESTAMP      | DEFAULT CURRENT_TIMESTAMP       |                                      |
| `updated_at`  | TIMESTAMP      | ON UPDATE CURRENT_TIMESTAMP     |                                      |

### 2.2 Admin-specific notes
- Admins may not need `blood_group`; keep it nullable.
- The first admin can be seeded manually via SQL or a setup servlet.
- No public registration for admins — only an existing admin can promote/create other admins.

```sql
-- Example: Seed first admin (password = 'admin123', must be changed immediately)
INSERT INTO users (full_name, email, phone, password_hash, role, status)
VALUES ('System', 'Admin', 'admin@lifelink.org', '9800000000', '$2a$10$...', 'ADMIN', 'ACTIVE');
```

---

## 3. Project Structure (New Files)

```
src/main/java/
├── backend/
│   ├── model/              # Hibernate entities
│   │   └── User.java
│   ├── dao/                # Data Access Objects
│   │   └── UserDAO.java
│   ├── service/            # Business logic
│   │   └── AuthService.java
│   ├── servlet/            # Controllers
│   │   ├── LoginServlet.java
│   │   ├── LogoutServlet.java
│   │   └── AdminSetupServlet.java   (optional seed)
│   ├── filter/             # Security filters
│   │   ├── AuthFilter.java
│   │   └── AdminFilter.java
│   └── utils/
│       └── PasswordUtil.java
src/main/resources/
├── hibernate.cfg.xml       (ensure mapping)
src/main/webapp/
├── views/
│   ├── login.jsp           (update: wire form to LoginServlet)
│   ├── Register.jsp        (keep as-is for donors/recipients)
│   └── Admin/
│       ├── adminDashboard.jsp
│       └── adminManageUsers.jsp
├── WEB-INF/
│   └── web.xml             (update: servlet mappings + filter mappings)
```

---

## 4. Layer-by-Layer Implementation

### 4.1 Entity Layer — `User.java`

- Annotate with JPA/Hibernate annotations (`@Entity`, `@Table`, `@Id`, `@GeneratedValue`).
- Map `role` as `@Enumerated(EnumType.STRING)` or plain `String`.
- Do **not** store plain passwords.

```java
@Entity
@Table(name = "users")
public class User {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String firstName;
    private String lastName;

    @Column(unique = true, nullable = false)
    private String email;

    private String phone;
    private String bloodGroup;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Status status = Status.ACTIVE;

    // enums
    public enum Role { ADMIN, DONOR, RECIPIENT, HOSPITAL }
    public enum Status { ACTIVE, INACTIVE, SUSPENDED }

    // getters / setters / constructors
}
```

### 4.2 DAO Layer — `UserDAO.java`

Responsibilities:
- `findByEmail(String email)` — for login.
- `findById(Long id)` — for session refresh.
- `save(User user)` — for registration / admin creation.
- `update(User user)` — for status changes.

Use Hibernate `SessionFactory` or `Session` obtained via `DBConnection` utility (refactor DBConnection to provide `SessionFactory` if not already available).

### 4.3 Utility — `PasswordUtil.java`

Use **BCrypt** for hashing and verification.

```java
import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    public static String hash(String plain) {
        return BCrypt.hashpw(plain, BCrypt.gensalt(12));
    }
    public static boolean verify(String plain, String hash) {
        return BCrypt.checkpw(plain, hash);
    }
}
```

> **Maven dependency to add:**
> ```xml
> <dependency>
>     <groupId>org.mindrot</groupId>
>     <artifactId>jbcrypt</artifactId>
>     <version>0.4</version>
> </dependency>
> ```

### 4.4 Service Layer — `AuthService.java`

Business rules:
1. Login: accept `email` + `password`.
2. Find user by email via DAO.
3. If not found → return "Invalid credentials".
4. If status != ACTIVE → return "Account is inactive or suspended".
5. Verify password with `PasswordUtil`.
6. On success, return `User` object; on failure, return null or throw `AuthException`.

```java
public class AuthService {
    private UserDAO userDAO = new UserDAO();

    public User login(String email, String password) throws AuthException {
        User user = userDAO.findByEmail(email);
        if (user == null) throw new AuthException("Invalid credentials");
        if (user.getStatus() != User.Status.ACTIVE) throw new AuthException("Account not active");
        if (!PasswordUtil.verify(password, user.getPasswordHash())) throw new AuthException("Invalid credentials");
        return user;
    }
}
```

### 4.5 Servlet Layer

#### `LoginServlet.java`
- URL: `/login`
- Method: `POST`
- Params: `email`, `password`
- Flow:
  1. Get params, trim.
  2. Call `AuthService.login()`.
  3. On success:
     - `HttpSession session = request.getSession();`
     - `session.setAttribute("currentUser", user);`
     - Redirect based on role:
       - `ADMIN` → `/views/Admin/adminDashboard.jsp`
       - Others → `/index.jsp` (or donor/recipient dashboard)
  4. On failure:
     - `request.setAttribute("error", message);`
     - Forward back to `login.jsp`.

#### `LogoutServlet.java`
- URL: `/logout`
- Method: `GET`
- Flow:
  1. `request.getSession(false)` — get existing session, don't create.
  2. If exists: `session.invalidate();`
  3. Redirect to `/views/login.jsp` (or `/index.jsp`).

### 4.6 Filter Layer

#### `AuthFilter.java` (Optional Global Filter)
- Protect private resources.
- Check `session.getAttribute("currentUser") != null`.
- If missing → redirect to login.
- Skip for login, register, CSS, JS, images.

#### `AdminFilter.java` (Admin-Only Resources)
- Mapped to `/views/Admin/*`
- Check:
  1. Session exists and has `currentUser`.
  2. `user.getRole() == Role.ADMIN`.
- If either fails → redirect to `/views/login.jsp?error=Unauthorized`.

```java
@WebFilter("/views/Admin/*")
public class AdminFilter implements Filter {
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("currentUser") == null) {
            ((HttpServletResponse) res).sendRedirect(request.getContextPath() + "/views/login.jsp");
            return;
        }
        
        User user = (User) session.getAttribute("currentUser");
        if (user.getRole() != User.Role.ADMIN) {
            ((HttpServletResponse) res).sendRedirect(request.getContextPath() + "/index.jsp?error=AccessDenied");
            return;
        }
        
        chain.doFilter(req, res);
    }
}
```

---

## 5. Web Configuration (`web.xml`)

Add the following inside `<web-app>`:

```xml
<!-- Servlets -->
<servlet>
    <servlet-name>LoginServlet</servlet-name>
    <servlet-class>backend.servlet.LoginServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>LoginServlet</servlet-name>
    <url-pattern>/login</url-pattern>
</servlet-mapping>

<servlet>
    <servlet-name>LogoutServlet</servlet-name>
    <servlet-class>backend.servlet.LogoutServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>LogoutServlet</servlet-name>
    <url-pattern>/logout</url-pattern>
</servlet-mapping>

<!-- Filters -->
<filter>
    <filter-name>AdminFilter</filter-name>
    <filter-class>backend.filter.AdminFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>AdminFilter</filter-name>
    <url-pattern>/views/Admin/*</url-pattern>
</filter-mapping>

<!-- Session timeout: 30 minutes -->
<session-config>
    <session-timeout>30</session-timeout>
</session-config>

<!-- Welcome file -->
<welcome-file-list>
    <welcome-file>index.jsp</welcome-file>
</welcome-file-list>
```

---

## 6. UI Updates

### 6.1 `login.jsp` Changes
1. Add `action="${pageContext.request.contextPath}/login" method="post"` to the `<form>`.
2. Remove `e.preventDefault()` from the JS so the form submits normally.
3. Server-side error display block:
   ```jsp
   <% if (request.getAttribute("error") != null) { %>
       <div class="alert alert-error"><%= request.getAttribute("error") %></div>
   <% } %>
   ```
4. Ensure `name="email"` and `name="password"` attributes are present (already there).

### 6.2 `adminDashboard.jsp` Changes
1. At the top of the body (before sidebar), add a session guard or rely on `AdminFilter`:
   ```jsp
   <%-- AdminFilter handles redirect; optional extra guard --%>
   ```
2. Display admin info in the topbar:
   ```jsp
   <% User admin = (User) session.getAttribute("currentUser"); %>
   <span>Welcome, <%= admin.getFirstName() + " " + admin.getLastName() %></span>
   ```
3. Add a **Logout** link/button in `admintopbar.jsp` pointing to `/logout`.

### 6.3 `Register.jsp`
- Keep for public donor/recipient/hospital registration.
- On submit, hash password before saving via `RegisterServlet`.
- Do **not** allow `role=ADMIN` from public registration.

---

## 7. Security Checklist

| # | Check | Implementation |
|---|-------|----------------|
| 1 | Passwords hashed | BCrypt with salt rounds ≥ 12 |
| 2 | SQL Injection safe | Use Hibernate ORM (parameterized) |
| 3 | Session fixation protection | Call `request.getSession(true)` only after login; consider `session.invalidate()` + new session on login |
| 4 | Session timeout | 30 min in `web.xml` |
| 5 | Role-based access | `AdminFilter` on `/views/Admin/*` |
| 6 | No sensitive data in URL | POST for login; session attributes for user state |
| 7 | HTTPS (production) | Configure Tomcat / reverse proxy for SSL |
| 8 | Password validation | Minimum 8 chars, 1 uppercase, 1 number, 1 special char |
| 9 | Rate limiting (future) | CAPTCHA or delay after 3 failed attempts |
| 10 | Audit logging (future) | Log admin logins to `admin_logs` table |

---

## 8. Step-by-Step Development Order

Follow this order to minimize merge conflicts and test incrementally:

### Phase 1: Foundation
1. **Add Maven dependency** for `jbcrypt` in `pom.xml`.
2. **Update `DBConnection`** (or create `HibernateUtil`) to provide `SessionFactory`.
3. **Create `User` entity** with Hibernate annotations.
4. **Create `PasswordUtil`** utility.

### Phase 2: Data Access
5. **Create `UserDAO`** with `findByEmail`, `save`, `update`.
6. **Create `AuthService`** with login logic.

### Phase 3: Web Layer
7. **Update `web.xml`** with servlets, filters, and session timeout.
8. **Create `LoginServlet`**.
9. **Create `LogoutServlet`**.
10. **Create `AdminFilter`** and map to `/views/Admin/*`.

### Phase 4: UI Integration
11. **Update `login.jsp`** form action and add error display.
12. **Update `admintopbar.jsp`** to show logged-in admin name + logout link.
13. **Optional:** Add admin user creation UI in `adminManageUsers.jsp`.

### Phase 5: Seeding & Testing
14. **Seed first admin** via SQL script or `AdminSetupServlet` (run once, then remove/secure).
15. **Test login flow**:
    - Correct credentials → dashboard
    - Wrong password → back to login with error
    - Non-admin tries `/views/Admin/adminDashboard.jsp` → redirected to login
    - Direct access after logout → redirected to login
16. **Test session timeout**: wait 30 min or reduce timeout temporarily.

### Phase 6: Cleanup
17. Remove demo/test JS from `login.jsp` and `Register.jsp`.
18. Add proper error pages (`404.jsp`, `500.jsp`, `unauthorized.jsp`).

---

## 9. Testing Scenarios

| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| Admin login success | POST valid email + password | Redirect to `adminDashboard.jsp`, session created |
| Admin login failure | POST invalid password | Forward to `login.jsp` with error message |
| Inactive admin login | Login with `status=INACTIVE` | Error: "Account not active" |
| Session expiration | Wait > 30 min, refresh admin page | Redirect to login |
| Direct URL access | Open `/views/Admin/adminDashboard.jsp` without login | Redirect to login |
| Non-admin access | Login as DONOR, navigate to `/views/Admin/*` | Redirect to `index.jsp` or login with "Access Denied" |
| Logout | Click logout | Session invalidated, redirect to login |
| Password hashing | Register new user, check DB | Stored value is BCrypt hash, not plain text |

---

## 10. Future Enhancements (Post-MVP)

- **Remember Me:** Persistent cookie with secure token stored in DB.
- **Password Reset:** Email-based token (requires JavaMail API).
- **2FA:** TOTP for admin accounts.
- **Audit Trail:** `admin_audit_log` table tracking all admin actions.
- **Role Granularity:** `SUPER_ADMIN` vs `ADMIN` (e.g., super admin can delete admins).
- **Account Lockout:** Lock after N failed attempts.

---

## 11. Appendix: SQL Setup Script

```sql
CREATE DATABASE IF NOT EXISTS blood_management_db;
USE blood_management_db;

CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    blood_group VARCHAR(5),
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN','DONOR','RECIPIENT','HOSPITAL') NOT NULL DEFAULT 'DONOR',
    status ENUM('ACTIVE','INACTIVE','SUSPENDED') NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Seed admin (password: Admin@123)
-- NOTE: Generate a real BCrypt hash before running this.
-- INSERT INTO users (full_name, email, phone, password_hash, role, status)
-- VALUES ('System', 'Admin', 'admin@lifelink.org', '9800000000', '<REAL_BCRYPT_HASH>', 'ADMIN', 'ACTIVE');
```

> To generate a real hash quickly, run a small Java main method using `PasswordUtil.hash("your_password")`.

---

**Document Owner:** Development Team  
**Last Updated:** 2026-05-03  
**Next Review:** After Phase 3 completion
