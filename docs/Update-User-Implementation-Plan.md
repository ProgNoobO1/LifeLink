# Update User — Implementation Plan

**Project:** BloodManagementSystem (LifeLink)  
**Feature:** Admin "Edit / Update User"  
**Branch:** `feature/new-feature`  
**Status:** Not Implemented / Ready for Development

---

## 1. Current Status

### What Exists Today
| Component | Status | Notes |
|-----------|--------|-------|
| `User` entity | ✅ Ready | Full JPA entity with getters/setters |
| `UserDAO.update(User user)` | ✅ Ready | Hibernate `merge()` available |
| `UserService` | ✅ Ready | Can be extended with `updateUser()` method |
| `AdminFilter` | ✅ Ready | Protects `/views/Admin/*` and `/admin/*` |
| `ViewUserServlet` | ✅ Ready | Returns JSON by ID — can be reused for fetching edit data |
| **Edit (pencil) button in table** | ⚠️ UI Only | Exists in `adminManageUsers.jsp` for every row but has **no action** |

### What Is Missing
| Component | Impact |
|-----------|--------|
| `EditUserServlet` | No backend endpoint to receive update form submission |
| Pre-populated edit form / modal | Admin cannot see existing data before editing |
| Email uniqueness check (self-exclusion) | Editing a user would fail with "email already exists" because the DB still has their own record |
| Optional password update | Currently no way to update password only if provided; must handle "leave blank = keep old password" |
| Self-edit protection | An admin should not be able to demote themselves or suspend their own account (could lock themselves out) |
| Success/error feedback after edit | After updating, admin should see confirmation and refreshed list |

---

## 2. Goal

Enable **administrators** to click the **Edit** (pencil) icon on any user row, open a pre-filled form, modify fields, and save changes.

Key requirements:
- Form must be **pre-populated** with existing user data
- Email must remain unique, but **exclude the current user** from the duplicate check
- Password update must be **optional** (blank = keep existing password)
- An admin **cannot change their own role to non-admin** or **suspend themselves**
- After saving, redirect back to user list with success message

---

## 3. User Stories

| ID | Story | Priority |
|----|-------|----------|
| EU-1 | As an admin, I want to click the edit icon and see a form pre-filled with the user's current data. | Must Have |
| EU-2 | As an admin, I want to change a user's role (e.g., promote Donor to Admin) and save it. | Must Have |
| EU-3 | As an admin, I want to change a user's status (Active → Suspended) without re-entering their password. | Must Have |
| EU-4 | As an admin, I want to leave the password field blank so the existing password is preserved. | Must Have |
| EU-5 | As an admin, I want the system to prevent me from accidentally suspending or demoting my own account. | Must Have |
| EU-6 | As an admin, I want to see a success message after updating a user. | Must Have |

---

## 4. UI Approach: Reuse Add User Modal

Instead of building a completely new modal, we recommend **reusing the existing Add User modal** with these modifications:

1. **Change the title** dynamically to "Edit User"
2. **Pre-fill all fields** from the database
3. **Add a hidden `id` field** to identify which user is being edited
4. **Make password optional** (remove `required`, add helper text)
5. **Change the submit action** to `/admin/users/edit`
6. **Show "Update User"** button text instead of "Create User"

### 4.1 Edit Button Wiring
In `adminManageUsers.jsp`, inside the `<c:forEach>` loop:
```jsp
<button class="act-btn act-edit" title="Edit"
        onclick="openEditUserModal(${user.id})">
  <svg viewBox="0 0 24 24">...</svg>
</button>
```

### 4.2 JavaScript: Open Edit Modal
```javascript
function openEditUserModal(userId) {
  fetch('${pageContext.request.contextPath}/admin/users/view?id=' + userId)
    .then(r => {
      if (!r.ok) throw new Error('Failed to load user');
      return r.json();
    })
    .then(user => {
      // Populate form fields
      document.querySelector('[name="editId"]').value = user.id;
      document.querySelector('[name="editFirstName"]').value = user.firstName;
      document.querySelector('[name="editLastName"]').value = user.lastName;
      document.querySelector('[name="editEmail"]').value = user.email;
      document.querySelector('[name="editPhone"]').value = user.phone || '';
      document.querySelector('[name="editBloodGroup"]').value = user.bloodGroup || '';
      document.querySelector('[name="editRole"]').value = user.role;
      document.querySelector('[name="editStatus"]').value = user.status;
      document.getElementById('editPasswordField').value = '';

      // Change title and button
      document.getElementById('editModalTitle').textContent = 'Edit User';
      document.getElementById('editSubmitBtn').textContent = 'Update User';

      document.getElementById('editUserModal').style.display = 'flex';
    })
    .catch(err => alert(err.message));
}

function closeEditUserModal() {
  document.getElementById('editUserModal').style.display = 'none';
}
```

### 4.3 Edit Modal HTML
Reuse the same structure as Add User modal, but with:
- Different field names (`editFirstName`, `editEmail`, etc.)
- Hidden `editId` field
- Optional password (no `required`)
- Form action = `/admin/users/edit`

```html
<div id="editUserModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h3 id="editModalTitle">Edit User</h3>
      <button type="button" onclick="closeEditUserModal()">&times;</button>
    </div>
    <form id="editUserForm" action="${pageContext.request.contextPath}/admin/users/edit" method="post">
      <input type="hidden" name="editId" />
      <div class="form-group">
        <label>First Name</label>
        <input type="text" name="editFirstName" required maxlength="50"/>
      </div>
      <div class="form-group">
        <label>Last Name</label>
        <input type="text" name="editLastName" required maxlength="50"/>
      </div>
      <div class="form-group">
        <label>Email</label>
        <input type="email" name="editEmail" required maxlength="100"/>
      </div>
      <div class="form-group">
        <label>Phone</label>
        <input type="tel" name="editPhone" maxlength="20"/>
      </div>
      <div class="form-group">
        <label>Blood Group</label>
        <select name="editBloodGroup">
          <option value="">None</option>
          <option value="A+">A+</option>
          ...
        </select>
      </div>
      <div class="form-group">
        <label>Role</label>
        <select name="editRole" required>
          <option value="DONOR">Donor</option>
          <option value="RECIPIENT">Recipient</option>
          <option value="HOSPITAL">Hospital</option>
          <option value="ADMIN">Admin</option>
        </select>
      </div>
      <div class="form-group">
        <label>Status</label>
        <select name="editStatus" required>
          <option value="ACTIVE">Active</option>
          <option value="INACTIVE">Inactive</option>
          <option value="SUSPENDED">Suspended</option>
        </select>
      </div>
      <div class="form-group">
        <label>New Password (leave blank to keep current)</label>
        <div class="password-row">
          <input type="text" name="editPassword" id="editPasswordField" minlength="8" placeholder="Leave blank to keep current"/>
          <button type="button" onclick="generateEditPassword()">Generate</button>
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeEditUserModal()">Cancel</button>
        <button type="submit" class="btn-save" id="editSubmitBtn">Update User</button>
      </div>
    </form>
  </div>
</div>
```

---

## 5. Backend Architecture

### 5.1 Updated `UserService.java`
Add these methods to the existing `UserService`:

```java
public void updateUser(Long id, String firstName, String lastName, String email,
                       String phone, String bloodGroup, String password,
                       User.Role role, User.Status status, User currentAdmin) throws AuthException {

    if (id == null) throw new AuthException("User ID is required.");
    if (firstName == null || firstName.trim().isEmpty()) throw new AuthException("First name is required.");
    if (lastName == null || lastName.trim().isEmpty()) throw new AuthException("Last name is required.");
    if (email == null || email.trim().isEmpty()) throw new AuthException("Email is required.");
    if (role == null) throw new AuthException("Role is required.");

    User existing = userDAO.findById(id);
    if (existing == null) throw new AuthException("User not found.");

    // Self-edit protection
    if (currentAdmin.getId().equals(id)) {
        if (role != User.Role.ADMIN) {
            throw new AuthException("You cannot demote yourself from Admin.");
        }
        if (status != User.Status.ACTIVE) {
            throw new AuthException("You cannot deactivate or suspend your own account.");
        }
    }

    // Email uniqueness check (exclude self)
    User emailOwner = userDAO.findByEmail(email.trim());
    if (emailOwner != null && !emailOwner.getId().equals(id)) {
        throw new AuthException("Another user with this email already exists.");
    }

    existing.setFirstName(firstName.trim());
    existing.setLastName(lastName.trim());
    existing.setEmail(email.trim().toLowerCase());
    existing.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
    existing.setBloodGroup(bloodGroup != null && !bloodGroup.isEmpty() ? bloodGroup : null);
    existing.setRole(role);
    existing.setStatus(status);

    // Only update password if provided
    if (password != null && !password.trim().isEmpty()) {
        if (password.length() < 8) {
            throw new AuthException("Password must be at least 8 characters.");
        }
        existing.setPasswordHash(PasswordUtil.hash(password));
    }

    boolean saved = userDAO.update(existing);
    if (!saved) throw new AuthException("Failed to update user. Please try again.");
}
```

### 5.2 New `EditUserServlet.java`
Mapped to `/admin/users/edit`.

```java
package backend.servlet;

import backend.model.User;
import backend.service.AuthException;
import backend.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class EditUserServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        String idParam = req.getParameter("editId");
        String firstName = req.getParameter("editFirstName");
        String lastName = req.getParameter("editLastName");
        String email = req.getParameter("editEmail");
        String phone = req.getParameter("editPhone");
        String bloodGroup = req.getParameter("editBloodGroup");
        String password = req.getParameter("editPassword");
        String roleStr = req.getParameter("editRole");
        String statusStr = req.getParameter("editStatus");

        try {
            Long userId = Long.parseLong(idParam);
            User.Role role = User.Role.valueOf(roleStr);
            User.Status status = User.Status.valueOf(statusStr);

            userService.updateUser(userId, firstName, lastName, email, phone,
                    bloodGroup, password, role, status, admin);

            session.setAttribute("successMessage", "User updated successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
        } catch (IllegalArgumentException | NumberFormatException e) {
            req.setAttribute("error", "Invalid input provided.");
            req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
        }
    }
}
```

### 5.3 `web.xml` Updates
```xml
<servlet>
    <servlet-name>EditUserServlet</servlet-name>
    <servlet-class>backend.servlet.EditUserServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>EditUserServlet</servlet-name>
    <url-pattern>/admin/users/edit</url-pattern>
</servlet-mapping>
```

> No additional filter mapping needed — `AdminFilter` already covers `/admin/*`.

---

## 6. JSP Updates Summary

In `adminManageUsers.jsp`:

1. **Wire each Edit button** in the `<c:forEach>` loop:
   ```jsp
   <button class="act-btn act-edit" title="Edit" onclick="openEditUserModal(${user.id})">
   ```

2. **Add Edit User modal HTML** (similar structure to Add User modal but with `editXxx` field names).

3. **Add JavaScript functions** (`openEditUserModal`, `closeEditUserModal`, `generateEditPassword`).

4. **Add `generateEditPassword()` helper**:
   ```javascript
   function generateEditPassword() {
     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
     let pw = '';
     for (let i = 0; i < 12; i++) pw += chars.charAt(Math.floor(Math.random() * chars.length));
     document.getElementById('editPasswordField').value = pw;
   }
   ```

---

## 7. Security Checklist

| # | Check | Implementation |
|---|-------|----------------|
| 1 | Only admins can access | `AdminFilter` on `/admin/*` + manual check in servlet |
| 2 | Validate user ID | Check `editId` is present and numeric |
| 3 | Email uniqueness (exclude self) | `findByEmail()` then compare IDs |
| 4 | Self-edit protection | Block role demotion and status change on own account |
| 5 | Optional password | Only hash and save if provided and ≥ 8 chars |
| 6 | Input validation | Required fields, enum validation |
| 7 | No SQL injection | Hibernate ORM parameterized |
| 8 | XSS protection | JSP EL escaping in output |

---

## 8. Step-by-Step Development Order

### Phase 1: Backend
1. Add `updateUser()` method to `UserService.java`.
2. Create `EditUserServlet.java`.
3. Add servlet mapping to `web.xml`.

### Phase 2: Frontend
4. Add **Edit User modal HTML** to `adminManageUsers.jsp`.
5. **Wire the Edit button** inside `<c:forEach>` to call `openEditUserModal(${user.id})`.
6. Add **JavaScript** (`openEditUserModal`, `closeEditUserModal`, `generateEditPassword`).

### Phase 3: Integration & Testing
7. Build WAR and deploy to Tomcat.
8. Edit a Donor → change blood group → save → verify updated in list.
9. Edit a user → change email to an existing user's email → verify error.
10. Edit self (admin) → try to change role to Donor → verify blocked.
11. Edit self → try to change status to Suspended → verify blocked.
12. Edit a user → leave password blank → verify login still works with old password.
13. Edit a user → set new password → verify login works with new password.

---

## 9. Testing Scenarios

| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| Edit blood group | Change donor from A+ to O+ | Success, updated in list |
| Change role | Promote Donor to Admin | Success, role badge updates |
| Change status | Set user to Suspended | Success, status pill updates |
| Duplicate email | Change email to another user's email | Error: "Another user with this email already exists" |
| Self-demotion | Admin tries to change own role to Donor | Error: "You cannot demote yourself" |
| Self-suspension | Admin tries to suspend own account | Error: "You cannot deactivate or suspend your own account" |
| Blank password | Edit user, leave password blank | Old password still works |
| New password | Edit user, set new password 12 chars | New password works, old one doesn't |
| Short password | Set password to "abc" | Error: "Password must be at least 8 characters" |
| Invalid ID | POST with `editId=abc` | Error: "Invalid input provided" |
| No login | POST to `/admin/users/edit` without session | Redirect to login |
| Non-admin | Login as Donor, POST to edit endpoint | 403 Forbidden |

---

## 10. Future Enhancements (Post-MVP)

- **Bulk edit:** Select multiple users via checkboxes and change status/role in bulk.
- **Edit from view modal:** Add an "Edit" button inside the View User modal that switches to edit mode.
- **Audit trail:** Log every edit with old value vs new value.
- **Email notification:** Send email to user when their profile is updated by an admin.
- **Avatar upload:** Allow changing profile picture during edit.

---

**Document Owner:** Development Team  
**Last Updated:** 2026-05-03  
**Depends On:** Admin Authentication + View User + Add New User (all completed)
