# Add New User — Implementation Plan

**Project:** BloodManagementSystem (LifeLink)  
**Feature:** Admin "Add New User"  
**Branch:** `feature/new-feature`  
**Status:** Not Implemented / Ready for Development

---

## 1. Current Status

### What Exists Today
| Component | Status | Notes |
|-----------|--------|-------|
| `User` entity | ✅ Ready | Hibernate entity with firstName, lastName, email, role, status, etc. |
| `UserDAO.save()` | ✅ Ready | Can persist new users to DB |
| `PasswordUtil.hash()` | ✅ Ready | BCrypt hashing available |
| `AdminFilter` | ✅ Ready | Protects `/views/Admin/*` — ensures only admins access this feature |
| `Register.jsp` | ⚠️ Partial | Public registration page exists but only for self-registration (DONOR/RECIPIENT/HOSPITAL). Has demo JavaScript (`e.preventDefault()`) and no working `RegisterServlet`. Not reusable for admin flow. |
| "Add New User" button | ⚠️ UI Only | Exists in `adminManageUsers.jsp` but has **no action** — it's a dead button. |

### What Is Missing
| Component | Impact |
|-----------|--------|
| Admin user creation UI / modal | Admin has no form to create users |
| `RegisterServlet` or `AddUserServlet` | No backend endpoint to handle user creation |
| `UserService` / `UserRegistrationService` | No business logic layer for validation, email uniqueness checks, role assignment |
| Admin role authorization check | Need to ensure only admins can create other admins |
| Email uniqueness validation | Could insert duplicate emails via raw DB |
| Password generation / input flow | Admin needs to either set a password or auto-generate one |
| Success / error feedback | After creation, admin should see confirmation and updated list |

---

## 2. Goal

Enable **administrators** to create new user accounts directly from the **Manage Users** page. The admin should be able to:
1. Open an "Add New User" modal or navigate to a form
2. Fill in user details (name, email, phone, blood group, role, status)
3. Set or auto-generate a password
4. Submit — the user is saved to the database
5. See the new user immediately in the user list

**Security rule:** Only `ADMIN` role users can create accounts. Admins can create users of **any role** (including other admins). Non-admin access must be blocked.

---

## 3. User Stories

| ID | Story | Priority |
|----|-------|----------|
| AU-1 | As an admin, I want to click "Add New User" and see a form so I can enter new user details. | Must Have |
| AU-2 | As an admin, I want to select the user's role (Donor, Recipient, Hospital, Admin) so I can create different types of users. | Must Have |
| AU-3 | As an admin, I want the system to validate that the email is unique so I don't create duplicate accounts. | Must Have |
| AU-4 | As an admin, I want the system to auto-generate a secure temporary password so I don't have to invent one. | Should Have |
| AU-5 | As an admin, I want to see a success message and the updated user list after creation so I know it worked. | Must Have |
| AU-6 | As an admin, I want validation errors (empty fields, invalid email, duplicate email) shown clearly so I can fix them. | Must Have |

---

## 4. Proposed UI Approach: Inline Modal

Rather than navigating to a separate page, we recommend a **modal popup** on the Manage Users page. This keeps the admin in context and provides a faster workflow.

### 4.1 Modal Trigger
In `adminManageUsers.jsp`, change the dead button:
```html
<button class="btn-add" onclick="openAddUserModal()">
  <svg>...</svg> Add New User
</button>
```

### 4.2 Modal HTML Structure (add inside `adminManageUsers.jsp`)
```html
<div id="addUserModal" class="modal" style="display:none;">
  <div class="modal-content">
    <div class="modal-header">
      <h3>Add New User</h3>
      <button onclick="closeAddUserModal()">&times;</button>
    </div>
    <form id="addUserForm" action="${pageContext.request.contextPath}/admin/users/add" method="post">
      <!-- First Name -->
      <div class="form-group">
        <label>First Name</label>
        <input type="text" name="firstName" required maxlength="50"/>
      </div>
      <!-- Last Name -->
      <div class="form-group">
        <label>Last Name</label>
        <input type="text" name="lastName" required maxlength="50"/>
      </div>
      <!-- Email -->
      <div class="form-group">
        <label>Email</label>
        <input type="email" name="email" required maxlength="100"/>
      </div>
      <!-- Phone -->
      <div class="form-group">
        <label>Phone</label>
        <input type="tel" name="phone" maxlength="20"/>
      </div>
      <!-- Blood Group -->
      <div class="form-group">
        <label>Blood Group</label>
        <select name="bloodGroup">
          <option value="">None</option>
          <option value="A+">A+</option>
          <option value="A-">A-</option>
          <option value="B+">B+</option>
          <option value="B-">B-</option>
          <option value="AB+">AB+</option>
          <option value="AB-">AB-</option>
          <option value="O+">O+</option>
          <option value="O-">O-</option>
        </select>
      </div>
      <!-- Role -->
      <div class="form-group">
        <label>Role</label>
        <select name="role" required>
          <option value="DONOR">Donor</option>
          <option value="RECIPIENT">Recipient</option>
          <option value="HOSPITAL">Hospital</option>
          <option value="ADMIN">Admin</option>
        </select>
      </div>
      <!-- Status -->
      <div class="form-group">
        <label>Status</label>
        <select name="status" required>
          <option value="ACTIVE">Active</option>
          <option value="INACTIVE">Inactive</option>
          <option value="SUSPENDED">Suspended</option>
        </select>
      </div>
      <!-- Password -->
      <div class="form-group">
        <label>Password</label>
        <div class="password-row">
          <input type="text" name="password" id="passwordField" required minlength="8"/>
          <button type="button" onclick="generatePassword()">Generate</button>
        </div>
        <small>Minimum 8 characters. User should change this on first login.</small>
      </div>
      <!-- Actions -->
      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeAddUserModal()">Cancel</button>
        <button type="submit" class="btn-save">Create User</button>
      </div>
    </form>
  </div>
</div>
```

### 4.3 Minimal Modal CSS (add to page `<style>`)
```css
.modal {
  position: fixed; inset: 0; z-index: 200;
  background: rgba(0,0,0,.45);
  display: flex; align-items: center; justify-content: center;
}
.modal-content {
  background: var(--white); border-radius: 16px;
  width: 100%; max-width: 480px; max-height: 90vh; overflow-y: auto;
  padding: 1.5rem; box-shadow: 0 20px 60px rgba(0,0,0,.2);
}
.modal-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:1.2rem; }
.modal-header h3 { font-size:1.1rem; font-weight:700; }
.form-group { display:flex; flex-direction:column; gap:.35rem; margin-bottom:1rem; }
.form-group label { font-size:.82rem; font-weight:600; }
.form-group input, .form-group select {
  padding:.55rem .8rem; border:1.5px solid var(--border); border-radius:9px;
  font-family:inherit; font-size:.88rem; outline:none;
}
.form-group input:focus, .form-group select:focus { border-color:var(--red); }
.password-row { display:flex; gap:.5rem; }
.password-row button {
  padding:.55rem .9rem; border:none; border-radius:9px; background:var(--red-light);
  color:var(--red); font-weight:600; cursor:pointer; white-space:nowrap;
}
.modal-actions { display:flex; justify-content:flex-end; gap:.6rem; margin-top:1.2rem; }
.btn-cancel { padding:.55rem 1rem; border:1.5px solid var(--border); background:white; border-radius:9px; cursor:pointer; }
.btn-save { padding:.55rem 1.2rem; border:none; background:var(--red); color:white; border-radius:9px; font-weight:600; cursor:pointer; }
```

### 4.4 JavaScript Helpers
```javascript
function openAddUserModal() {
  document.getElementById('addUserModal').style.display = 'flex';
}
function closeAddUserModal() {
  document.getElementById('addUserModal').style.display = 'none';
  document.getElementById('addUserForm').reset();
}
function generatePassword() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
  let pw = '';
  for (let i = 0; i < 12; i++) pw += chars.charAt(Math.floor(Math.random() * chars.length));
  document.getElementById('passwordField').value = pw;
}
// Close on backdrop click
document.getElementById('addUserModal').addEventListener('click', function(e) {
  if (e.target === this) closeAddUserModal();
});
```

---

## 5. Backend Architecture

### 5.1 New Files
```
src/main/java/
├── backend/
│   ├── service/
│   │   └── UserService.java          (NEW)
│   ├── servlet/
│   │   └── AddUserServlet.java       (NEW)
```

### 5.2 `UserService.java`
Business logic layer between servlet and DAO.

```java
package backend.service;

import backend.dao.UserDAO;
import backend.model.User;
import backend.utils.PasswordUtil;

public class UserService {

    private final UserDAO userDAO = new UserDAO();

    public void registerUser(String firstName, String lastName, String email,
                             String phone, String bloodGroup, String password,
                             User.Role role, User.Status status) throws AuthException {

        // Validation
        if (firstName == null || firstName.trim().isEmpty())
            throw new AuthException("First name is required.");
        if (lastName == null || lastName.trim().isEmpty())
            throw new AuthException("Last name is required.");
        if (email == null || email.trim().isEmpty())
            throw new AuthException("Email is required.");
        if (password == null || password.length() < 8)
            throw new AuthException("Password must be at least 8 characters.");
        if (role == null)
            throw new AuthException("Role is required.");

        // Email uniqueness check
        User existing = userDAO.findByEmail(email.trim());
        if (existing != null)
            throw new AuthException("A user with this email already exists.");

        // Create user
        User user = new User(
            firstName.trim(),
            lastName.trim(),
            email.trim().toLowerCase(),
            phone != null ? phone.trim() : null,
            bloodGroup != null && !bloodGroup.isEmpty() ? bloodGroup : null,
            PasswordUtil.hash(password),
            role,
            status != null ? status : User.Status.ACTIVE
        );

        boolean saved = userDAO.save(user);
        if (!saved)
            throw new AuthException("Failed to save user. Please try again.");
    }
}
```

### 5.3 `AddUserServlet.java`
Mapped to `/admin/users/add`.

```java
package backend.servlet;

import backend.model.User;
import backend.service.AuthException;
import backend.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class AddUserServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Admin check is handled by AdminFilter on /views/Admin/*,
        // but this servlet is at /admin/users/add which is NOT under /views/Admin/*.
        // We need to either:
        //   Option A: Map AdminFilter to /admin/* as well
        //   Option B: Add an admin check here manually

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }
        User admin = (User) session.getAttribute("currentUser");
        if (admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        // Read form data
        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String bloodGroup = req.getParameter("bloodGroup");
        String password = req.getParameter("password");
        String roleStr = req.getParameter("role");
        String statusStr = req.getParameter("status");

        try {
            User.Role role = User.Role.valueOf(roleStr);
            User.Status status = User.Status.valueOf(statusStr);

            userService.registerUser(firstName, lastName, email, phone,
                                     bloodGroup, password, role, status);

            // Redirect back to user list with success message
            req.getSession().setAttribute("successMessage", "User created successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("formData", req.getParameterMap());
            req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", "Invalid role or status selected.");
            req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
        }
    }
}
```

> **Note:** Since `AddUserServlet` is mapped to `/admin/users/add` (not under `/views/Admin/*`), the `AdminFilter` will **not** protect it automatically. We must either:
> 1. Add a second `filter-mapping` for `AdminFilter` to `/admin/*`, OR
> 2. Add manual admin checks inside the servlet (shown above).  
> **Recommendation:** Do both for defense in depth.

### 5.4 `web.xml` Updates
```xml
<servlet>
    <servlet-name>AddUserServlet</servlet-name>
    <servlet-class>backend.servlet.AddUserServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>AddUserServlet</servlet-name>
    <url-pattern>/admin/users/add</url-pattern>
</servlet-mapping>

<!-- ALSO protect /admin/* paths with AdminFilter -->
<filter-mapping>
    <filter-name>AdminFilter</filter-name>
    <url-pattern>/admin/*</url-pattern>
</filter-mapping>
```

---

## 6. JSP Updates for Feedback

In `adminManageUsers.jsp`, add success/error banners near the top of `.content`:

```jsp
<c:if test="${not empty sessionScope.successMessage}">
    <div class="alert alert-success">
        ${sessionScope.successMessage}
        <% session.removeAttribute("successMessage"); %>
    </div>
</c:if>
<c:if test="${not empty error}">
    <div class="alert alert-error">${error}</div>
</c:if>
```

Add alert styles:
```css
.alert {
    padding: .85rem 1.2rem; border-radius: 12px; font-size: .9rem; font-weight: 600;
}
.alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
.alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
```

---

## 7. Security Checklist

| # | Check | Implementation |
|---|-------|----------------|
| 1 | Only admins can access | `AdminFilter` on `/admin/*` + manual check in servlet |
| 2 | Email uniqueness | Checked in `UserService` before saving |
| 3 | Password hashing | `PasswordUtil.hash()` (BCrypt) before storage |
| 4 | Input validation | Required fields, min password length, enum validation |
| 5 | No SQL injection | Hibernate ORM parameterized queries |
| 6 | XSS protection | JSP `<c:out>` or default EL escaping (enabled in modern JSP) |
| 7 | Role enum safety | `User.Role.valueOf()` with try-catch |
| 8 | Session fixation | Not applicable here (no login on create) |

---

## 8. Step-by-Step Development Order

### Phase 1: Backend Foundation
1. Create `UserService.java` with `registerUser()` method.
2. Add `findByEmail()` validation logic inside `UserService`.
3. Create `AddUserServlet.java` with form handling and admin checks.

### Phase 2: Configuration
4. Add `AddUserServlet` mapping to `web.xml`.
5. Add `AdminFilter` mapping for `/admin/*` in `web.xml`.

### Phase 3: Frontend (Modal)
6. Add modal HTML structure to `adminManageUsers.jsp`.
7. Add modal CSS to page `<style>` block.
8. Add JavaScript helpers (`openAddUserModal`, `closeAddUserModal`, `generatePassword`).
9. Wire the "Add New User" button to `openAddUserModal()`.
10. Add success/error alert banners to `adminManageUsers.jsp`.

### Phase 4: Integration & Testing
11. Build WAR and deploy to Tomcat.
12. Test creating a Donor user.
13. Test creating an Admin user.
14. Test validation: duplicate email, empty fields, short password.
15. Test security: try accessing `/admin/users/add` without login → should redirect.
16. Test security: try accessing `/admin/users/add` as a Donor → should get 403 or redirect.

---

## 9. Testing Scenarios

| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| Create donor | Fill form, role=DONOR, submit | Success message, user appears in list |
| Create admin | Fill form, role=ADMIN, submit | Success message, new admin in list |
| Duplicate email | Submit with existing email | Error: "A user with this email already exists" |
| Empty first name | Leave first name blank | Error: "First name is required" |
| Short password | Password = "123" | Error: "Password must be at least 8 characters" |
| Invalid role | Manually POST with role=SUPERHUMAN | Error: "Invalid role or status selected" |
| No-login access | POST to `/admin/users/add` without session | Redirect to login |
| Non-admin access | Login as DONOR, POST to `/admin/users/add` | 403 Forbidden or redirect |
| Generate password | Click "Generate" button | 12-char random password appears in field |
| Cancel modal | Click "Cancel" or backdrop | Modal closes, form resets |

---

## 10. Future Enhancements (Post-MVP)

- **Send welcome email:** Email the new user their temporary password (requires JavaMail).
- **Force password change:** Add `force_password_change` flag so user must reset on first login.
- **Bulk import:** CSV upload for mass user creation.
- **Audit log:** Log which admin created which user and when.
- **Profile picture upload:** Allow attaching an avatar during creation.
- **Phone validation:** Regex or SMS verification for phone numbers.

---

## 11. Appendix: Quick SQL to Check After Testing

```sql
USE blood_management_db;
SELECT id, first_name, last_name, email, role, status, created_at
FROM users
ORDER BY id DESC
LIMIT 5;
```

---

**Document Owner:** Development Team  
**Last Updated:** 2026-05-03  
**Depends On:** Admin Authentication Implementation (completed)
