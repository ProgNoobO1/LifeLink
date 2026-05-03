# View User — Implementation Plan

**Project:** BloodManagementSystem (LifeLink)  
**Feature:** Admin "View User Details"  
**Branch:** `feature/new-feature`  
**Status:** Not Implemented / Ready for Development

---

## 1. Current Status

### What Exists Today
| Component | Status | Notes |
|-----------|--------|-------|
| `User` entity | ✅ Ready | Contains all fields needed for display: id, firstName, lastName, email, phone, bloodGroup, role, status, createdAt |
| `UserDAO.findById(Long id)` | ✅ Ready | Can fetch a single user by primary key |
| `UserService` | ✅ Ready | Business layer exists (can be extended) |
| `AdminFilter` | ✅ Ready | Protects `/views/Admin/*` and `/admin/*` |
| **View button in user table** | ⚠️ UI Only | Exists in `adminManageUsers.jsp` for every row but has **no action** — it's a dead button |

### What Is Missing
| Component | Impact |
|-----------|--------|
| `ViewUserServlet` or endpoint | No backend to fetch a single user's details by ID |
| User detail view UI / modal | Admin cannot see full profile of any user |
| View button wiring | The eye-icon button in each table row does nothing on click |
| User creation timestamp display | `created_at` field exists in DB but is never shown anywhere |
| Phone number display | Stored in DB but not visible in the compact table view |
| Password hash visibility | Should NOT be shown (security), but status should be prominent |

---

## 2. Goal

Enable **administrators** to click the **View** (eye) icon on any user row in the Manage Users table and see a detailed read-only profile of that user.

The view should display:
- Full name (first + last)
- Email address
- Phone number
- Blood group (if applicable)
- Role (with colored badge)
- Status (with colored pill)
- Account creation date
- User ID

**Security rule:** Only `ADMIN` role users can view user details. The endpoint must validate the ID parameter and prevent unauthorized access.

---

## 3. User Stories

| ID | Story | Priority |
|----|-------|----------|
| VU-1 | As an admin, I want to click the eye icon on any user row to see their full details. | Must Have |
| VU-2 | As an admin, I want to see the user's creation date so I know how long they've been registered. | Should Have |
| VU-3 | As an admin, I want the view modal to be read-only so I don't accidentally edit data. | Must Have |
| VU-4 | As an admin, I want to close the detail view easily and return to the user list. | Must Have |
| VU-5 | As an admin, I want a clear error if I try to view a non-existent user ID. | Should Have |

---

## 4. Proposed UI Approach: Inline Modal

Following the same pattern as "Add New User," we recommend a **modal popup** on the Manage Users page. This provides a consistent admin experience.

### 4.1 View Button Wiring
In `adminManageUsers.jsp`, inside the `<c:forEach>` loop, change the dead view button:
```jsp
<button class="act-btn act-view" title="View"
        onclick="openViewUserModal(${user.id})">
  <svg viewBox="0 0 24 24">...</svg>
</button>
```

### 4.2 Modal HTML Structure (add inside `adminManageUsers.jsp`)
```html
<div id="viewUserModal" class="modal" style="display:none;">
  <div class="modal-content" style="max-width:420px;">
    <div class="modal-header">
      <h3>User Details</h3>
      <button type="button" onclick="closeViewUserModal()">&times;</button>
    </div>
    <div class="user-detail-body" id="viewUserBody">
      <!-- Content loaded dynamically via fetch -->
    </div>
  </div>
</div>
```

### 4.3 Two Implementation Strategies

#### Strategy A: Server-Side Rendered (Simpler)
The servlet forwards to a dedicated JSP page (e.g., `viewUser.jsp`). Admin sees a new page with full details.

**Pros:** Simple, no JavaScript needed, works without AJAX  
**Cons:** Page refresh, admin loses scroll position in user list

#### Strategy B: AJAX Modal (Recommended)
JavaScript fetches user JSON from a servlet endpoint and renders it in the modal.

**Pros:** No page refresh, stays in context, modern UX  
**Cons:** Requires JSON endpoint + client-side rendering

**Recommendation:** Use **Strategy B (AJAX Modal)** for consistency with the Add User modal pattern.

### 4.4 AJAX Modal JavaScript
```javascript
function openViewUserModal(userId) {
  fetch('${pageContext.request.contextPath}/admin/users/view?id=' + userId)
    .then(r => {
      if (!r.ok) throw new Error('Failed to load user');
      return r.json();
    })
    .then(user => {
      const html = `
        <div class="detail-row">
          <span class="detail-label">User ID</span>
          <span class="detail-value">#USR-${user.id}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Full Name</span>
          <span class="detail-value">${user.firstName} ${user.lastName}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Email</span>
          <span class="detail-value">${user.email}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Phone</span>
          <span class="detail-value">${user.phone || '—'}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Blood Group</span>
          <span class="detail-value">${user.bloodGroup || '—'}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Role</span>
          <span class="detail-value badge-role-${user.role.toLowerCase()}">${user.role}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Status</span>
          <span class="detail-value badge-status-${user.status.toLowerCase()}">${user.status}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Created At</span>
          <span class="detail-value">${user.createdAt}</span>
        </div>
      `;
      document.getElementById('viewUserBody').innerHTML = html;
      document.getElementById('viewUserModal').style.display = 'flex';
    })
    .catch(err => {
      alert(err.message);
    });
}

function closeViewUserModal() {
  document.getElementById('viewUserModal').style.display = 'none';
}
```

### 4.5 Modal Detail CSS (add to page `<style>`)
```css
.user-detail-body { display: flex; flex-direction: column; gap: 1rem; }
.detail-row { display: flex; justify-content: space-between; align-items: center; padding: .6rem 0; border-bottom: 1px solid #f3f4f6; }
.detail-row:last-child { border-bottom: none; }
.detail-label { font-size: .82rem; color: var(--text-light); font-weight: 500; }
.detail-value { font-size: .9rem; color: var(--text-dark); font-weight: 600; }
.badge-role-donor     { color: var(--red); background: var(--red-light); padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
.badge-role-recipient { color: #2563eb; background: #dbeafe; padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
.badge-role-hospital  { color: #7c3aed; background: #ede9fe; padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
.badge-role-admin     { color: #d97706; background: #fef3c7; padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
.badge-status-active    { color: #059669; background: #d1fae5; padding: .2rem .6rem; border-radius: 999px; font-size: .78rem; }
.badge-status-inactive  { color: var(--text-light); background: #f3f4f6; padding: .2rem .6rem; border-radius: 999px; font-size: .78rem; }
.badge-status-suspended { color: var(--red); background: #fee2e2; padding: .2rem .6rem; border-radius: 999px; font-size: .78rem; }
```

---

## 5. Backend Architecture

### 5.1 New Files
```
src/main/java/
├── backend/
│   ├── servlet/
│   │   └── ViewUserServlet.java       (NEW)
```

### 5.2 `ViewUserServlet.java`
Mapped to `/admin/users/view`. Returns JSON for AJAX consumption.

```java
package backend.servlet;

import backend.dao.UserDAO;
import backend.model.User;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class ViewUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Admin check (AdminFilter handles /admin/*, but we double-check)
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Please login");
            return;
        }
        User admin = (User) session.getAttribute("currentUser");
        if (admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "User ID is required");
            return;
        }

        try {
            Long userId = Long.parseLong(idParam);
            User user = userDAO.findById(userId);

            if (user == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
                return;
            }

            Map<String, Object> data = new HashMap<>();
            data.put("id", user.getId());
            data.put("firstName", user.getFirstName());
            data.put("lastName", user.getLastName());
            data.put("email", user.getEmail());
            data.put("phone", user.getPhone());
            data.put("bloodGroup", user.getBloodGroup());
            data.put("role", user.getRole().name());
            data.put("status", user.getStatus().name());
            data.put("createdAt", user.getId() != null ? "Available in DB" : "N/A");
            // Note: If User entity has createdAt field mapped, use user.getCreatedAt()

            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();
            out.print(gson.toJson(data));
            out.flush();

        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid user ID");
        }
    }
}
```

> **Note on Gson:** Add the Gson dependency to `pom.xml` for JSON serialization:
> ```xml
> <dependency>
>     <groupId>com.google.code.gson</groupId>
>     <artifactId>gson</artifactId>
>     <version>2.10.1</version>
> </dependency>
> ```
> Alternative: Use `org.json` or manual JSON string building if you prefer fewer dependencies.

### 5.3 `web.xml` Updates
```xml
<servlet>
    <servlet-name>ViewUserServlet</servlet-name>
    <servlet-class>backend.servlet.ViewUserServlet</servlet-class>
</servlet>
<servlet-mapping>
    <servlet-name>ViewUserServlet</servlet-name>
    <url-pattern>/admin/users/view</url-pattern>
</servlet-mapping>
```

> No additional filter mapping needed — `AdminFilter` already covers `/admin/*`.

---

## 6. Alternative: Server-Side Rendered Page

If you prefer a dedicated page instead of a modal, create `viewUser.jsp`:

```jsp
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head><title>User #${user.id}</title></head>
<body>
  <h2>${user.firstName} ${user.lastName}</h2>
  <p>Email: ${user.email}</p>
  <p>Phone: ${user.phone}</p>
  <p>Role: ${user.role}</p>
  <p>Status: ${user.status}</p>
  <a href="${pageContext.request.contextPath}/admin/users">Back to list</a>
</body>
</html>
```

And change `ViewUserServlet` to forward instead of returning JSON:
```java
req.setAttribute("user", user);
req.getRequestDispatcher("/views/Admin/viewUser.jsp").forward(req, resp);
```

---

## 7. JSP Updates Summary

In `adminManageUsers.jsp`, you need to:

1. **Wire each View button** in the `<c:forEach>` loop:
   ```jsp
   <button class="act-btn act-view" title="View" onclick="openViewUserModal(${user.id})">
   ```

2. **Add View User modal HTML** before `</body>` (similar to Add User modal).

3. **Add detail CSS** to the `<style>` block.

4. **Add JavaScript functions** (`openViewUserModal`, `closeViewUserModal`) to the `<script>` block.

5. **Add Gson dependency** to `pom.xml` (if using JSON approach).

---

## 8. Security Checklist

| # | Check | Implementation |
|---|-------|----------------|
| 1 | Only admins can access | `AdminFilter` on `/admin/*` + manual check in servlet |
| 2 | Validate user ID | Check `id` parameter is present and numeric |
| 3 | Handle missing users | Return 404 if `findById()` returns null |
| 4 | No password leak | Never include `passwordHash` in the JSON response |
| 5 | Prevent IDOR | Admin can only view users via the endpoint (no cross-account risk since all users are visible to admin) |
| 6 | XSS protection | JSON response with Gson automatically escapes strings |

---

## 9. Step-by-Step Development Order

### Phase 1: Backend
1. Add **Gson dependency** to `pom.xml`.
2. Create `ViewUserServlet.java` with JSON output.
3. Add servlet mapping to `web.xml`.

### Phase 2: Frontend
4. Add **View User modal HTML** to `adminManageUsers.jsp`.
5. Add **detail CSS styles** to the page `<style>` block.
6. Add **JavaScript fetch logic** to the page `<script>` block.
7. **Wire the View button** inside the `<c:forEach>` loop to call `openViewUserModal(${user.id})`.

### Phase 3: Integration & Testing
8. Build WAR and deploy to Tomcat.
9. Click View on an existing user → modal opens with correct details.
10. Click View on a non-existent user ID (manually crafted URL) → 404 error.
11. Access `/admin/users/view?id=1` without login → redirect to login or 401.
12. Access `/admin/users/view?id=1` as a Donor → 403 Forbidden.

---

## 10. Testing Scenarios

| Scenario | Steps | Expected Result |
|----------|-------|-----------------|
| View donor | Click eye icon on Sarah Johnson | Modal shows name, email, role=Donor, blood group=A+ |
| View hospital | Click eye icon on City General Hospital | Modal shows name, email, role=Hospital, blood group=— |
| View admin | Click eye icon on System Admin | Modal shows role=Admin, status=Active |
| Close modal | Click X or backdrop | Modal closes smoothly |
| Invalid ID | GET `/admin/users/view?id=abc` | 400 Bad Request |
| Missing ID | GET `/admin/users/view` | 400 Bad Request |
| Non-existent ID | GET `/admin/users/view?id=99999` | 404 Not Found |
| No login | Access `/admin/users/view?id=1` without session | 401 or redirect to login |
| Non-admin | Login as Donor, access `/admin/users/view?id=1` | 403 Forbidden |
| Password not leaked | Inspect JSON response | No `passwordHash` field present |

---

## 11. Future Enhancements (Post-MVP)

- **Edit from view:** Add an "Edit" button inside the view modal that transitions to an edit form.
- **User activity log:** Show donation history / request history inside the view modal.
- **Profile picture:** Display a larger avatar in the detail view.
- **Delete from view:** Add a "Delete User" button inside the modal with confirmation.
- **Export profile:** Generate a PDF or printable view of the user profile.

---

## 12. Appendix: Quick API Test

After implementation, test the JSON endpoint with curl:

```bash
# Login first to establish session
curl -c cookies.txt -X POST -d "email=admin@lifelink.org&password=Admin@123" \
  http://localhost:8080/BloodManagementSystem/login

# Fetch user JSON
curl -b cookies.txt \
  http://localhost:8080/BloodManagementSystem/admin/users/view?id=1
```

Expected response:
```json
{
  "id": 1,
  "firstName": "System",
  "lastName": "Admin",
  "email": "admin@lifelink.org",
  "phone": "9800000000",
  "bloodGroup": null,
  "role": "ADMIN",
  "status": "ACTIVE",
  "createdAt": "..."
}
```

---

**Document Owner:** Development Team  
**Last Updated:** 2026-05-03  
**Depends On:** Admin Authentication + Add New User (completed)
