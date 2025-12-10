package com.internshipapp.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "request")

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
public class Request {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "company_name", nullable = false, length = 150)
    private String companyName;

    @Column(name = "company_email", nullable = false, length = 255)
    private String companyEmail;

    @Column(name = "hq_address", nullable = false, length = 255)
    private String hqAddress;

    @Column(name = "phone_number", nullable = false, length = 20)
    private String phoneNumber;

    @Column(name = "password", nullable = false, length = 255)
    private String password;

    @Column(name = "token", length = 512, unique = true)
    private String token;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", columnDefinition = "ENUM('pending', 'approved', 'rejected') DEFAULT 'pending'")
    private RequestStatus status;

    // Constructors
    public Request() {}

    public Request(String companyName, String companyEmail, String hqAddress,
                   String phoneNumber, String password, String token) {
        this.companyName = companyName;
        this.companyEmail = companyEmail;
        this.hqAddress = hqAddress;
        this.phoneNumber = phoneNumber;
        this.password = password;
        this.token = token;
        this.status = RequestStatus.pending;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    public String getCompanyEmail() { return companyEmail; }
    public void setCompanyEmail(String companyEmail) { this.companyEmail = companyEmail; }

    public String getHqAddress() { return hqAddress; }
    public void setHqAddress(String hqAddress) { this.hqAddress = hqAddress; }

    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getToken() { return token; }
    public void setToken(String token) { this.token = token; }

    public RequestStatus getStatus() { return status; }
    public void setStatus(RequestStatus status) { this.status = status; }

    // Enum for request status
    public enum RequestStatus {
        pending, approved, rejected
    }
}