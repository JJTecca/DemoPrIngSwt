package org.proiect.IngSwt.JPAEntities;

import jakarta.persistence.*;

@Entity
@Table(name = "permission")
/************************
 *      FORMAT
 *      1. Ids
 *      2. Relationships (FKs)
 *      3. Columns
 *      4. Constructor
 *      5. Getter & Setter
 ************************/
/************************
 *      Notes:
 *      1. Long or Integer for Ids
 *      2. Length on varchar is def 255
 *************************/

public class Permission {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer permissionId;

    // Relationship to UserAccount (optional, unique)
    @OneToOne(optional = true)
    @JoinColumn(name = "user_id", unique = true)
    private UserAccount user;

    // Enum for role
    public enum Role {
        Faculty,
        Student,
        Company
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private Role role;

    // Constructors
    public Permission() {}
    public Permission(UserAccount user, Role role) {
        this.user = user;
        this.role = role;
    }

    // Getters and Setters
    public Integer getId() { return permissionId; }
    public void setId(Integer id) { this.permissionId = id; }
    public UserAccount getUser() { return user; }
    public void setUser(UserAccount user) { this.user = user; }
    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }

}