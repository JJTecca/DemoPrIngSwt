package com.internshipapp.common;

import java.io.Serializable;
import java.util.List;

public class StudentInfoDto implements Serializable {
    private Long id;
    // private Long attachmentId; <-- REMOVED
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
    private List<InternshipApplicationDto> internshipApplications;
    private String biography;
    private boolean gradeVisibility;


    // Primary source of attachment data
    private AttachmentDto attachment;


    // Constructors
    public StudentInfoDto() {
    }

    // Constructor 1 (Basic Student Info - User Account data excluded)
    public StudentInfoDto(Long id, String firstName, String middleName,
                          String lastName, Integer studyYear, Float lastYearGrade,
                          String status, Boolean enrolled) {
        this.id = id;
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.studyYear = studyYear;
        this.lastYearGrade = lastYearGrade;
        this.status = status;
        this.enrolled = enrolled;
    }

    // Constructor 2 (Student + User Account Info)
    public StudentInfoDto(Long id, String firstName, String middleName,
                          String lastName, Integer studyYear, Float lastYearGrade,
                          String status, Boolean enrolled, String userEmail,
                          String username, Long userId) {
        this.id = id;
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

    // Constructor 3 (Full DTO - Used by copyStudentToDto)
    public StudentInfoDto(Long id, String firstName, String middleName, String lastName,
                          Integer studyYear, Float lastYearGrade, String status,
                          Boolean enrolled, String userEmail, String username, Long userId,
                          AttachmentDto attachment, String biography, boolean gradeVisibility) {
        this.id = id;
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
        this.attachment = attachment;
        this.biography = biography;
        this.gradeVisibility = gradeVisibility;
    }

    public StudentInfoDto(Long id, Long aLong, String firstName, String middleName, String lastName, Integer studyYear, Float lastYearGrade, String string, Boolean enrolled, String email, String username, Long userId) {
        this.id = id;
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.studyYear = studyYear;
        this.lastYearGrade = lastYearGrade;
        this.status = string;
        this.enrolled = enrolled;
        this.userEmail = email;
        this.username = username;
        this.userId = userId;
    }

    // Note: Constructors 3 and 4 from your original file were redundant/similar
    // and have been streamlined into the final Constructor 3 above.


    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    // Removed getAttachmentId() and setAttachmentId()

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getMiddleName() {
        return middleName;
    }

    public void setMiddleName(String middleName) {
        this.middleName = middleName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public Integer getStudyYear() {
        return studyYear;
    }

    public void setStudyYear(Integer studyYear) {
        this.studyYear = studyYear;
    }

    public Float getLastYearGrade() {
        return lastYearGrade;
    }

    public void setLastYearGrade(Float lastYearGrade) {
        this.lastYearGrade = lastYearGrade;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getEnrolled() {
        return enrolled;
    }

    public void setEnrolled(Boolean enrolled) {
        this.enrolled = enrolled;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    // DTO Composition Getters for JSP (Correctly used in your JSP)
    public boolean hasCv() {
        return attachment != null && attachment.isCvAvailable();
    }

    public boolean hasProfilePic() {
        return attachment != null && attachment.isProfilePicAvailable();
    }

    public AttachmentDto getAttachment() {
        return attachment;
    }

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

    // Removed hasAttachment() which relied on attachmentId
    // If you need a replacement:
    // public boolean hasAttachment() { return this.attachment != null; }

    public boolean hasUserAccount() {
        return userId != null;
    }

    public String getBiography() {
        return biography;
    }

    public void setBiography(String biography) {
        this.biography = biography;
    }

    public boolean getGradeVisibility() {
        return gradeVisibility;
    }

    public void setGradeVisibility(boolean gradeVisibility) {
        this.gradeVisibility = gradeVisibility;
    }
}