package com.internshipapp.entities;

import jakarta.persistence.*;

@Entity
@Table(name = "user_account")
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
public class UserAccount {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer userId;

    @Column(name="username", length = 255, nullable = false)
    private String username;
    @Column(name="password", length = 20, nullable = false)
    private String password;
    @Column(name="email", length = 255,  nullable = false)
    private String email;

    // Relationship with StudentInfo
    @ManyToOne(optional = false)
    @JoinColumn(name = "id_student")
    private StudentInfo studentInfo;
    // Relationship with CompanyInfo
    @ManyToOne(optional = false)
    @JoinColumn(name = "id_company")
    private CompanyInfo companyInfo;

    //Constructors
    public UserAccount() {}
    public UserAccount(String username, Integer userId, String email, String password, CompanyInfo companyInfo, StudentInfo studentInfo) {
        this.username = username;
        this.userId = userId;
        this.email = email;
        this.password = password;
        this.companyInfo = companyInfo;
        this.studentInfo = studentInfo;
    }

    public String getUsername() {return username;}
    public void setUsername(String username) {this.username = username;}
    public Integer getUserId() {return userId;}
    public void setUserId(Integer userId) {this.userId = userId;}
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public CompanyInfo getCompanyInfo() { return companyInfo; }
    public void setCompanyInfo(CompanyInfo companyInfo) { this.companyInfo = companyInfo; }
    public StudentInfo getStudentInfo() { return studentInfo; }
    public void setStudentInfo(StudentInfo studentInfo) { this.studentInfo = studentInfo; }
}