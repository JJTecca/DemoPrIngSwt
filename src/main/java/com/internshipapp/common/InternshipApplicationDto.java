package com.internshipapp.common;

import java.time.LocalDateTime;
import java.util.Date;

/******************************
 *Purpose of DTO Pattern:
 * 1.Data Transfer: Moves data between layers (Database → Business Logic → UI)
 * 2. Decoupling: Separates database entities from API/UI models
 * 3. Security: Controls what data gets exposed (avoid exposing sensitive fields)
 * 4. Customization: Combine data from multiple entities into one object
 * NOTE: Not all fields need to be used
 *****************************/
public class InternshipApplicationDto {
    private Long id;
    private Long internshipPositionId;
    private Long studentId;
    private String studentName;
    private String status;
    private Float grade;
    private LocalDateTime appliedAt;
    private String positionTitle;
    private String companyName;
    private String description;
    private String requirements;
    private Date deadline;
    private Long companyId;
    private LocalDateTime interview;
    private String interviewLocation;
    private boolean chatInitiated;
    private String studentStatus;
    private Float studyGrade;
    private boolean studyGradeVisibility;
    /************************************************
     *        Constructors
     *  - we have more type of constructors
     *  - adjust params as needed
     *  - *NOTE* : constructors called based on feature */
    /****************************************************************
     *               PERFORMANCE NOTES
     *  - Lazy relationships should not be initialized in constructors
     *   - Consider using factory methods for complex object creation
     **************************************************************/
    public InternshipApplicationDto() {}

    public InternshipApplicationDto(Long id, Long internshipPositionId, Long studentId, String status, Float grade, LocalDateTime appliedAt, String chatIds) {
        this.id = id;
        this.internshipPositionId = internshipPositionId;
        this.studentId = studentId;
        this.status = status;
        this.grade = grade;
        this.appliedAt = appliedAt;
    }

    // Update this constructor in InternshipApplicationDto.java
    public InternshipApplicationDto(Long id, Long internshipPositionId, Long studentId,
                                    String studentName, String studentStatus, String status,
                                    Float grade, Float studyGrade, boolean studyGradeVisibility,
                                    LocalDateTime appliedAt, LocalDateTime interview, String interviewLocation,
                                    boolean chatInitiated, String positionTitle, String companyName,
                                    Long companyId, String description, String requirements, Date deadline) {
        this.id = id;
        this.internshipPositionId = internshipPositionId;
        this.studentId = studentId;
        this.studentName = studentName; // Added this
        this.studentStatus = studentStatus;
        this.status = status;
        this.grade = grade;
        this.studyGrade = studyGrade;
        this.studyGradeVisibility = studyGradeVisibility;
        this.appliedAt = appliedAt;
        this.interview = interview;
        this.interviewLocation = interviewLocation;
        this.chatInitiated = chatInitiated;
        this.positionTitle = positionTitle;
        this.companyName = companyName;
        this.companyId = companyId;
        this.description = description;
        this.requirements = requirements;
        this.deadline = deadline;
    }

    public InternshipApplicationDto(Long id, Long aLong, Long id1, String string, Float grade, LocalDateTime appliedAt, String posTitle, String compName) {
        this.id = id;
        this.internshipPositionId = aLong;
        this.studentId = id1;
        this.status = string;
        this.grade = grade;
        this.appliedAt = appliedAt;
        this.positionTitle = posTitle;
        this.companyName = compName;
    }

    public InternshipApplicationDto(Long id, Long studentId, String studentName, String status, LocalDateTime appliedAt) {
        this.id = id;
        this.studentId = studentId;
        this.studentName = studentName;
        this.status = status;
        this.appliedAt = appliedAt;
    }

    // Add this 7-parameter constructor to your DTO
    public InternshipApplicationDto(Long id, Long positionId, String positionTitle,
                                    Long companyId, String companyName,
                                    Object status, Float grade) {
        this.id = id;
        this.internshipPositionId = positionId;
        this.positionTitle = positionTitle;
        this.companyId = companyId;
        this.companyName = companyName;

        // Handle the Enum-to-String conversion here
        this.status = (status != null) ? status.toString() : "Pending";
        this.grade = grade;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getInternshipPositionId() {
        return internshipPositionId;
    }

    public void setInternshipPositionId(Long internshipPositionId) {
        this.internshipPositionId = internshipPositionId;
    }

    public Long getStudentId() {
        return studentId;
    }

    public void setStudentId(Long studentId) {
        this.studentId = studentId;
    }

    public String getStudentName() { return studentName; }

    public void setStudentName(String studentName) { this.studentName = studentName; }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Float getGrade() {
        return grade;
    }

    public void setGrade(Float grade) {
        this.grade = grade;
    }

    public LocalDateTime getAppliedAt() {
        return appliedAt;
    }

    public void setAppliedAt(LocalDateTime appliedAt) {
        this.appliedAt = appliedAt;
    }

    public String getPositionTitle() {
        return positionTitle;
    }

    public void setPositionTitle(String positionTitle) {
        this.positionTitle = positionTitle;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getRequirements() {
        return requirements;
    }

    public void setRequirements(String requirements) {
        this.requirements = requirements;
    }

    public Date getDeadline() {
        return deadline;
    }

    public void setDeadline(Date deadline) {
        this.deadline = deadline;
    }

    public Long getCompanyId() { return companyId; }

    public void setCompanyId(Long companyId) { this.companyId = companyId; }

    public LocalDateTime getInterview() { return interview; }

    public void setInterview(LocalDateTime interview) { this.interview = interview; }

    public String getStudentStatus() { return studentStatus; }

    public void setStudentStatus(String studentStatus) { this.studentStatus = studentStatus; }

    public Float getStudyGrade() { return studyGrade; }

    public void setStudyGrade(Float studyGrade) { this.studyGrade = studyGrade; }

    public String getStudyGradeFormatted() {
        return (studyGrade != null) ? String.format("%.2f", studyGrade) : "N/A";
    }

    public String getInternshipGradeFormatted() {
        return (grade != null) ? String.format("%.2f", grade) : "N/A";
    }

    public boolean isStudyGradeAvailable() {
        return studyGradeVisibility;
    }

    public void setStudyGradeVisibility(boolean studyGradeVisibility) {
        this.studyGradeVisibility = studyGradeVisibility;
    }

    public LocalDateTime getInterviewTime(){
        return interview;
    }

    public void setInterviewTime(LocalDateTime interviewTime){ this.interview = interviewTime; }

    public String getInterviewLocation() { return interviewLocation; }
    public void setInterviewLocation(String interviewLocation) { this.interviewLocation = interviewLocation; }

    public boolean isChatInitiated() {
        return chatInitiated;
    }

    public void setChatInitiated(boolean chatInitiated) {
        this.chatInitiated = chatInitiated;
    }
}