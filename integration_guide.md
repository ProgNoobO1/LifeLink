# 🩸 LifeLink - Teammate Integration Guide (Hospital Module)

Welcome team! The **Hospital Module** is fully completed, isolated, and tested. To ensure a 100% seamless, conflict-free integration when merging our branches, please follow this guide.

---

## 🛡️ 1. Conflict-Free UI & Stylesheets (Zero Collisions)

To prevent layouts or custom colors from overwriting each other when merging folders, the Hospital Module's UI components are strictly isolated:

### 🎨 Isolated Stylesheet
* **Path:** `/css/hospital.css`
* **Teammate Info:** All hospital pages link *only* to `hospital.css` (using the vibrant crimson and deep dark-blue design tokens). Your `global.css` or other stylesheet files will **never** be overridden or collided with.

### 📐 Isolated Layout Includes
Our layouts inside `/includes/` are uniquely named:
* Header: `/includes/hospital_header.jsp`
* Sidebar: `/includes/hospital_sidebar.jsp`
* Footer: `/includes/hospital_footer.jsp`

> [!NOTE]
> When you copy the `/includes/` folder, you can safely merge it! Your own `header.jsp`, `sidebar.jsp`, or `footer.jsp` will remain completely untouched.

---

## 🗄️ 2. Database Schema (Single Source of Truth)

Please refer *only* to the unified schema file in this branch:
* **Path:** [`src/main/resources/db/full_schema.sql`](file:///c:/Users/USER/OneDrive%20-%20London%20Metropolitan%20University/Advance%20Programming/cw/src/main/resources/db/full_schema.sql)

### Critical Table Definitions (Aligned with live MySQL):
1. **`hospitals` Table:** uses **`user_id` as the PRIMARY KEY** (no auto-incrementing `id` column exists). Links to `users(id) ON DELETE CASCADE`.
2. **`blood_stock` Table:** maps blood types relationally using `blood_group_id` pointing to `blood_groups(id)` (no enum string column exists).
3. **`blood_requests` Table:** links to hospitals via `hospital_id` referencing `hospitals(user_id)`.
4. **`usage_history` Table:** links to hospitals via `hospital_id` referencing `hospitals(user_id)`.

---

## 🔄 3. Servlet Integration & Routing Points

### 🔑 A. Redirect after Successful Login (Auth Developer)
When a user logs in successfully, check their role. If `role` is `'hospital'`, redirect them to:
```java
response.sendRedirect(request.getContextPath() + "/hospital/dashboard");
```

### 🛡️ B. Hospital Profile Guard (Filter)
We created a custom `HospitalFilter.java` mapped to `/hospital/*`. 
* If a hospital user attempts to browse stock, requests, or usage history *before* completing their profile setup form, they are automatically redirected to `/hospital/profile` with a clean, descriptive alert warning.

### 🩸 C. Incoming Blood Requests (Recipient Developer)
When a Recipient searches for blood and submits a request to a specific hospital, insert a row in the `blood_requests` table with:
* `hospital_id` = the selected hospital's `user_id`
* `blood_group_id` = the requested blood group lookup ID (1 to 8)
* `status` = `'pending'`
This will automatically pop up inside the hospital's dashboard and **Incoming Requests** panel in real-time!

---

## 🚀 4. How to Merge My Branch (`Branches-n`)

When you are ready to pull the Hospital Module into your development branch or the main branch, run the following Git commands:

```bash
# 1. Fetch the latest branches from the remote
git fetch origin

# 2. Switch to your branch (e.g. main)
git checkout main

# 3. Merge the Hospital branch
git merge origin/Branches-n

# 4. Push the merged commits to origin
git push origin main
```

*For any questions regarding database constraints or routing links, feel free to ping me! Let's submit an amazing coursework!* 🩸
