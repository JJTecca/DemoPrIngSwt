package com.internshipapp.common;

import java.io.Serializable;

public class StudentInfoDto implements Serializable {
    private Long id;
    private Long attachmentId;
    private String firstName;
    private String middleName;
    private String lastName;
    private Integer studyYear;
    private Float lastYearGrade;
    private String status;
    private Boolean enrolled;
    private String userEmail;
    private String username;
    private Long userId;

    // Constructors
    public StudentInfoDto() {}

    public StudentInfoDto(Long id, Long attachmentId, String firstName, String middleName,
                          String lastName, Integer studyYear, Float lastYearGrade,
                          String status, Boolean enrolled) {
        this.id = id;
        this.attachmentId = attachmentId;
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.studyYear = studyYear;
        this.lastYearGrade = lastYearGrade;
        this.status = status;
        this.enrolled = enrolled;
    }

    public StudentInfoDto(Long id, Long attachmentId, String firstName, String middleName,
                          String lastName, Integer studyYear, Float lastYearGrade,
                          String status, Boolean enrolled, String userEmail,
                          String username, Long userId) {
        this.id = id;
        this.attachmentId = attachmentId;
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.studyYear = studyYear;
        this.lastYearGrade = lastYearGrade;
        this.status = status;
        this.enrolled = enrolled;
        this.userEmail = userEmail;
        this.username = username;
        this.userId = userId;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getAttachmentId() { return attachmentId; }
    public void setAttachmentId(Long attachmentId) { this.attachmentId = attachmentId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getMiddleName() { return middleName; }
    public void setMiddleName(String middleName) { this.middleName = middleName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public Integer getStudyYear() { return studyYear; }
    public void setStudyYear(Integer studyYear) { this.studyYear = studyYear; }

    public Float getLastYearGrade() { return lastYearGrade; }
    public void setLastYearGrade(Float lastYearGrade) { this.lastYearGrade = lastYearGrade; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Boolean getEnrolled() { return enrolled; }
    public void setEnrolled(Boolean enrolled) { this.enrolled = enrolled; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    // Helper methods
    public String getFullName() {
        if (middleName != null && !middleName.isEmpty()) {
            return firstName + " " + middleName + " " + lastName;
        }
        return firstName + " " + lastName;
    }

    public String getInitials() {
        String initials = "";
        if (firstName != null && !firstName.isEmpty()) {
            initials += firstName.charAt(0);
        }
        if (lastName != null && !lastName.isEmpty()) {
            initials += lastName.charAt(0);
        }
        return initials.toUpperCase();
    }

    public String getGradeFormatted() {
        if (lastYearGrade == null) return "N/A";
        return String.format("%.2f", lastYearGrade);
    }

    public boolean hasAttachment() {
        return attachmentId != null;
    }

    public boolean hasUserAccount() {
        return userId != null;
    }
}