package com.internshipapp.common;
/******************************
 *Purpose of DTO Pattern:
 * 1.Data Transfer: Moves data between layers (Database → Business Logic → UI)
 * 2. Decoupling: Separates database entities from API/UI models
 * 3. Security: Controls what data gets exposed (avoid exposing sensitive fields)
 * 4. Customization: Combine data from multiple entities into one object
 * NOTE: Not all fields need to be used
 *****************************/
public class StudentInfoDto {
    private Long id;
    private Long attachmentId;
    private String firstName;
    private String middleName;
    private String lastName;
    private Integer studyYear;
    private Float lastYearGrade;
    private String status;
    private Boolean enrolled;

     /***************************************************
     *        Constructors
     *  - we have more type of constructors
     *  - adjust params as needed
     *  - *NOTE* : constructors called based on feature */
    /****************************************************************
     *               PERFORMANCE NOTES
     *  - Lazy relationships should not be initialized in constructors
     *   - Consider using factory methods for complex object creation
     **************************************************************/
    public StudentInfoDto() {}
    public StudentInfoDto(Long id, Long attachmentId, String firstName, String middleName, String lastName, Integer studyYear, Float lastYearGrade, String status, Boolean enrolled) {
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
}