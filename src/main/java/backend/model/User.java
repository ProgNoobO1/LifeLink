package backend.model;

public class User {

    private Long id;
    private String firstName;
    private String lastName;
    private String email;
    private String phone;
    private String bloodGroup;
    private String passwordHash;
    private Role role;
    private Status status = Status.ACTIVE;

    public enum Role {
        ADMIN, DONOR, RECIPIENT, HOSPITAL
    }

    public enum Status {
        ACTIVE, INACTIVE, SUSPENDED
    }

    public User() {}

    public User(String firstName, String lastName, String email, String phone,
                String bloodGroup, String passwordHash, Role role, Status status) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phone = phone;
        this.bloodGroup = bloodGroup;
        this.passwordHash = passwordHash;
        this.role = role;
        this.status = status;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public String getFullName() {
        return firstName + " " + lastName;
    }
}
