# Implementation Plan: Hibernate → JDBC DAO Migration

## Branch
`feature/jdbc-dao-migration`

## Goal
Remove Hibernate ORM and migrate all user database operations to plain JDBC DAO. Keep the service layer (`AuthService`, `UserService`) and servlet layer untouched.

---

## Current State

| Component | Technology |
|---|---|
| ORM | Hibernate 7.3.2.Final |
| Connection Pool | C3P0 (via `hibernate-c3p0`) |
| Model | `User` with JPA annotations (`@Entity`, `@Id`, `@Column`, etc.) |
| DAO | `UserDAO` using `Session`, `Transaction`, `Query` |
| Utils | `HibernateUtil` (SessionFactory builder) |
| Listener | `AppContextListener` (eager init / shutdown of Hibernate) |
| Seeder | `Seeder.java` using `UserService.registerUser()` → Hibernate |

A plain-JDBC `DBConnection.java` already exists but is **unused** by the DAO layer.

---

## Proposed Architecture (After)

```
Servlet Layer ──► Service Layer (unchanged) ──► UserDAO (JDBC) ──► MySQL
                                                     │
                                              DBConnection
                                              (Connection pool)
```

---

## Phase 1: Foundation — Connection & Model (Files: 2)

### 1.1 `backend.utils.DBConnection` — Connection Pool
**Action:** Replace the simple `DriverManager` approach with **HikariCP** (lightweight, fast, standard).

**Why HikariCP:**
- Industry standard connection pool
- Much faster than C3P0
- Small dependency footprint
- No Hibernate required

**Changes:**
- Add `com.zaxxer:HikariCP` to `pom.xml`
- Replace `DBConnection.java` with a `HikariDataSource` singleton
- Load DB credentials from `db.properties` (or keep inline for simplicity)
- Expose `getConnection()` and `close()` methods

**New methods:**
```java
public static Connection getConnection()
public static void close()
```

### 1.2 `backend.model.User` — Strip JPA Annotations
**Action:** Remove all JPA imports and annotations. Keep the class as a **plain POJO** with the same fields, enums, constructors, getters/setters.

**Annotations to remove:**
- `@Entity`, `@Table(name = "users")`
- `@Id`, `@GeneratedValue`
- All `@Column(...)`
- `@Enumerated(EnumType.STRING)`

**Keep:**
- All fields (`id`, `firstName`, `lastName`, `email`, `phone`, `bloodGroup`, `passwordHash`, `role`, `status`)
- `Role` and `Status` enums
- All constructors and getters/setters
- `getFullName()` helper

---

## Phase 2: Rewrite `UserDAO` — JDBC Implementation (File: 1)

**Action:** Rewrite `UserDAO.java` to use `Connection`, `PreparedStatement`, and `ResultSet` instead of Hibernate `Session`/`Query`.

**Methods to migrate (all 9):**

| Method | Hibernate → JDBC |
|---|---|
| `findByEmail(String)` | `SELECT * FROM users WHERE email = ?` |
| `findById(Long)` | `SELECT * FROM users WHERE id = ?` |
| `save(User)` | `INSERT INTO users (...)` |
| `update(User)` | `UPDATE users SET ... WHERE id = ?` |
| `delete(Long)` | `DELETE FROM users WHERE id = ?` |
| `findAll(int, int)` | `SELECT * FROM users ORDER BY id DESC LIMIT ? OFFSET ?` |
| `countAll()` | `SELECT COUNT(*) FROM users` |
| `countByRole(Role)` | `SELECT COUNT(*) FROM users WHERE role = ?` |
| `countByBloodGroup(String)` | `SELECT COUNT(*) FROM users WHERE blood_group = ?` |
| `findRecent(int)` | `SELECT * FROM users ORDER BY id DESC LIMIT ?` |

**Key implementation details:**
- Use **try-with-resources** for `Connection`, `PreparedStatement`, `ResultSet`
- Map `ResultSet` → `User` object in a private `mapResultSetToUser(ResultSet)` helper
- Handle `role` and `status` as `VARCHAR` → enum conversion
- Return `Collections.emptyList()` on error (match current behavior)
- Print stack traces on error (match current behavior — can be improved later)

**SQL Schema assumed (matches current `users` table):**
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    blood_group VARCHAR(5),
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);
```

---

## Phase 3: Remove Hibernate Artifacts (Files: 3 removed/modified)

### 3.1 Delete `HibernateUtil.java`
No longer needed. Connection management moves to `DBConnection`.

### 3.2 Delete `hibernate.cfg.xml`
No longer needed. DB config moves to `DBConnection` or a properties file.

### 3.3 Update `AppContextListener.java`
**Before:** Calls `HibernateUtil.getSessionFactory()` on init, `HibernateUtil.shutdown()` on destroy.
**After:** Calls `DBConnection.close()` on destroy (if HikariCP — pool shutdown). Init can be empty or validate DB connectivity.

### 3.4 Update `pom.xml`
**Remove:**
```xml
<dependency>
  <groupId>org.hibernate.orm</groupId>
  <artifactId>hibernate-core</artifactId>
  <version>7.3.2.Final</version>
</dependency>
<dependency>
  <groupId>org.hibernate.orm</groupId>
  <artifactId>hibernate-c3p0</artifactId>
  <version>7.3.2.Final</version>
</dependency>
```

**Add:**
```xml
<dependency>
  <groupId>com.zaxxer</groupId>
  <artifactId>HikariCP</artifactId>
  <version>6.2.1</version>
</dependency>
```

**Keep:** `mysql-connector-j` (still needed for JDBC driver).

---

## Phase 4: Update Seeder (File: 1)

### 4.1 `Seeder.java`
**Action:** Replace Hibernate-based seeding with direct JDBC `INSERT` statements or use the new `UserDAO.save()`.

**Approach A (recommended):** Keep using `UserService.registerUser()` — since `UserService` only depends on `UserDAO`, and `UserDAO` will be JDBC-based, the seeder works with zero changes.

**Approach B (faster):** Direct JDBC `INSERT` with pre-computed BCrypt hashes (bypasses validation). Use only if seeding 1000+ rows.

**Decision:** Use Approach A — no changes needed to `Seeder.java` because the service layer contract is unchanged.

---

## Phase 5: Verification & Cleanup

### 5.1 Build Check
```bash
mvn clean package
```
- Must compile with zero errors
- No Hibernate classes on classpath

### 5.2 Runtime Check
1. Deploy WAR to Tomcat
2. Verify login works (`admin@lifelink.org` / `Admin@123`)
3. Verify admin dashboard shows correct counts
4. Verify user CRUD (add, edit, view, delete)
5. Verify pagination on Manage Users page
6. Verify logout works

### 5.3 Delete Unused Files
- `src/main/java/backend/utils/HibernateUtil.java`
- `src/main/resources/hibernate.cfg.xml`
- `src/main/java/backend/utils/testdb.java` (if no longer needed)

---

## Files Changed Summary

| # | File | Action |
|---|---|---|
| 1 | `pom.xml` | Remove hibernate-core, hibernate-c3p0. Add HikariCP |
| 2 | `backend/model/User.java` | Strip JPA annotations |
| 3 | `backend/utils/DBConnection.java` | Rewrite with HikariCP |
| 4 | `backend/dao/UserDAO.java` | Rewrite with JDBC |
| 5 | `backend/listener/AppContextListener.java` | Remove Hibernate init/shutdown |
| 6 | `backend/utils/HibernateUtil.java` | **Delete** |
| 7 | `resources/hibernate.cfg.xml` | **Delete** |
| 8 | `backend/utils/testdb.java` | **Delete** (optional) |
| 9 | `backend/utils/Seeder.java` | No changes needed |
| 10 | `backend/service/AuthService.java` | No changes needed |
| 11 | `backend/service/UserService.java` | No changes needed |
| 12 | All Servlets | No changes needed |

**Total files to modify:** 5  
**Total files to delete:** 3  
**Total files untouched:** 10+

---

## Risk Mitigation

| Risk | Mitigation |
|---|---|
| JDBC SQL syntax errors | Test each DAO method individually against real MySQL DB |
| Connection leaks | Use try-with-resources everywhere; HikariCP handles pool cleanup |
| Enum mapping (`Role`, `Status`) | Map via `Role.valueOf(rs.getString("role"))` with null checks |
| `AUTO_INCREMENT` ID not returned after insert | Use `Statement.RETURN_GENERATED_KEYS` in `save()` |
| Service layer breaks | Keep `UserDAO` public method signatures **identical** |

---

## Alternative: Skip Connection Pool (Simpler)

Instead of HikariCP, we can keep the current `DBConnection` with `DriverManager` + manual connection per request. This removes one dependency but lacks pooling.

**Trade-offs:**
- **With HikariCP (recommended):** Better performance under load, connection reuse, built-in timeout/retry
- **Without HikariCP:** Simpler, one less dependency, fine for low-traffic academic projects

**Recommendation:** Use HikariCP — it's a 150KB JAR and the de-facto standard. The project already accepted C3P0 via Hibernate, so a dedicated pool is not a new concept.
