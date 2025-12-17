package com.internshipapp.entities;

import jakarta.persistence.*;

@Entity
@Table(name = "studentInfo")

/************************
 *      FORMAT
 *      1. Id
 *      2. Relationships (FKs)
 *      3. Columns
 *      4. Constructor
 *      5. Getter & Setter
 ************************/
public class StudentInfo {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;
    @OneToOne(mappedBy = "studentInfo")
    private UserAccount userAccount;
    // Zero to One relationship with Attachment
    @OneToOne(optional = true)
    @JoinColumn(name = "id_attachment")
    private Attachment attachment;
    @Column(name = "first_name", nullable = false)
    private String firstName;
    @Column(name = "middle_name")
    private String middleName;
    @Column(name = "last_name", nullable = false)
    private String lastName;
    @Column(name = "study_year", nullable = false)
    private Integer studyYear;
    @Column(name = "last_year_grade", nullable = false)
    private Float lastYearGrade;

    public enum StudentStatus {
        Available,
        Accepted,
        Completed
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "status")
    private StudentStatus status = StudentStatus.Available; // default
    @Column(name = "enrolled")
    private Boolean enrolled = true; // default TRUE
    @Column(name = "biography", length = 255)
    private String biography;

    // Constructors
    public StudentInfo() {
    }

    public StudentInfo(Long id, Attachment attachment, String firstName, String middleName, String lastName, Integer studyYear) {
        this.id = id;
        this.attachment = attachment;
        this.firstName = firstName;
        this.middleName = middleName;
        this.lastName = lastName;
        this.studyYear = studyYear;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Attachment getAttachment() {
        return attachment;
    }

    public void setAttachment(Attachment attachment) {
        this.attachment = attachment;
    }

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

    public StudentStatus getStatus() {
        return status;
    }

    public void setStatus(StudentStatus status) {
        this.status = status;
    }

    public Boolean getEnrolled() {
        return enrolled;
    }

    public void setEnrolled(Boolean enrolled) {
        this.enrolled = enrolled;
    }

    public String getBiography() { return this.biography; }

    public void setBiography(String biography) { this.biography = biography; }
}
