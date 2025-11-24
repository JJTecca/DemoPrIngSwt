package com.internshipapp.common;

import java.time.LocalDateTime;

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
    private String status;
    private Integer grade;
    private LocalDateTime appliedAt;
    private String chatIds;

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
    public InternshipApplicationDto(Long id, Long internshipPositionId, Long studentId, String status, Integer grade, LocalDateTime appliedAt, String chatIds) {
        this.id = id;
        this.internshipPositionId = internshipPositionId;
        this.studentId = studentId;
        this.status = status;
        this.grade = grade;
        this.appliedAt = appliedAt;
        this.chatIds = chatIds;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getInternshipPositionId() { return internshipPositionId; }
    public void setInternshipPositionId(Long internshipPositionId) { this.internshipPositionId = internshipPositionId; }
    public Long getStudentId() { return studentId; }
    public void setStudentId(Long studentId) { this.studentId = studentId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status;}
    public Integer getGrade() { return grade; }
    public void setGrade(Integer grade) { this.grade = grade; }
    public LocalDateTime getAppliedAt() { return appliedAt; }
    public void setAppliedAt(LocalDateTime appliedAt) { this.appliedAt = appliedAt; }
    public String getChatIds() { return chatIds; }
    public void setChatIds(String chatIds) { this.chatIds = chatIds;}
}