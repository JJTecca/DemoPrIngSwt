package com.internshipapp.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "InternshipApplication")

/************************
 *      FORMAT
 *      1. Id
 *      2. Relationships (FKs)
 *      3. Columns
 *      4. Constructor
 *      5. Getter & Setter
 ************************/
public class InternshipApplication {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_internship_position")
    private InternshipPosition internshipPosition;
    @ManyToOne(optional = false)
    @JoinColumn(name = "id_student")
    private StudentInfo student;

    // ENUM for application status
    public enum ApplicationStatus {
        Pending,
        Interview,
        Accepted,
        Rejected,
        Discussion
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ApplicationStatus status = ApplicationStatus.Pending;

    @Column(name = "grade")
    private Float grade;

    @Column(name = "applied_at", nullable = false)
    private LocalDateTime appliedAt = LocalDateTime.now();

    @Column(name = "chat_ids", columnDefinition = "JSON", nullable = false)
    private String chatIds; // Or use @Convert with List<String>

    @Column(name = "interview")
    private LocalDateTime interview;

    public InternshipApplication() {}
    public InternshipApplication(Long id, InternshipPosition internshipPosition, StudentInfo student, ApplicationStatus status, Float grade, LocalDateTime appliedAt, String chatIds) {
        this.id = id;
        this.internshipPosition = internshipPosition;
        this.student = student;
        this.status = status;
        this.grade = grade;
        this.appliedAt = appliedAt;
        this.chatIds = chatIds;
    }

    // Getters and setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public InternshipPosition getInternshipPosition() { return internshipPosition; }
    public void setInternshipPosition(InternshipPosition internshipPosition) { this.internshipPosition = internshipPosition; }

    public StudentInfo getStudent() { return student; }

    public void setStudent(StudentInfo student) {
        this.student = student;
    }

    public ApplicationStatus getStatus() {
        return status;
    }

    public void setStatus(ApplicationStatus status) {
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

    public String getChatIds() {
        return chatIds;
    }

    public void setChatIds(String chatIds) {
        this.chatIds = chatIds;
    }

    public LocalDateTime getInterview() { return interview; }

    public void setInterview(LocalDateTime interview) { this.interview = interview; }
}
