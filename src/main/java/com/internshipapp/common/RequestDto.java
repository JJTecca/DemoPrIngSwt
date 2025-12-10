package com.internshipapp.common;

public class RequestDto {
    private Long id;
    private String companyName;
    private String companyEmail;
    private String hqAddress;
    private String phoneNumber;
    private String password;
    private String token;
    private String status;

    // Constructors
    public RequestDto() {}

    // Constructor for String status (used by servlet)
    public RequestDto(Long id, String companyName, String companyEmail, String hqAddress,
                      String phoneNumber, String password, String token, String status) {
        this.id = id;
        this.companyName = companyName;
        this.companyEmail = companyEmail;
        this.hqAddress = hqAddress;
        this.phoneNumber = phoneNumber;
        this.password = password;
        this.token = token;
        this.status = status;
    }

    // For enum status (used by RequestBean)
    public RequestDto(Long id, String companyName, String companyEmail, String hqAddress,
                      String phoneNumber, String password, String token,
                      com.internshipapp.entities.Request.RequestStatus status) {
        this(id, companyName, companyEmail, hqAddress, phoneNumber, password, token,
                status != null ? status.name() : null);
    }

    // Getters and setters
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

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}