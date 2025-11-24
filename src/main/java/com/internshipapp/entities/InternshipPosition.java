package com.internshipapp.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "internship_position")

/************************
 *      FORMAT
 *      1. Id
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
public class InternshipPosition {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;
    //Many-to-One Relationship with FK id_company
    @ManyToOne(optional = false)
    @JoinColumn(name = "id_company")
    private CompanyInfo company;
    @Column(name = "title", nullable = false)
    private String title;
    @Lob
    @Column(name = "description", nullable = false)
    private String description;
    @Lob
    @Column(name = "requirements", nullable = false)
    private String requirements;
    @Column(name = "deadline", nullable = false)
    private LocalDateTime deadline;
    @Column(name = "max_spots", nullable = false)
    private Integer maxSpots;

    @OneToMany(mappedBy = "internshipPosition", cascade = CascadeType.ALL)
    private List<InternshipApplication> applications;

    // Constructor
    public InternshipPosition() {}
    public InternshipPosition(CompanyInfo company, String title, String description,
                              String requirements, LocalDateTime deadline, Integer maxSpots) {
        this.company = company;
        this.title = title;
        this.description = description;
        this.requirements = requirements;
        this.deadline = deadline;
        this.maxSpots = maxSpots;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public CompanyInfo getCompany() { return company; }
    public void setCompany(CompanyInfo company) { this.company = company; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getRequirements() { return requirements; }
    public void setRequirements(String requirements) { this.requirements = requirements; }
    public LocalDateTime getDeadline() { return deadline; }
    public void setDeadline(LocalDateTime deadline) { this.deadline = deadline; }
    public Integer getMaxSpots() { return maxSpots; }
    public void setMaxSpots(Integer maxSpots) { this.maxSpots = maxSpots; }
    public List<InternshipApplication> getApplications() { return applications; }
    public void setApplications(List<InternshipApplication> applications) { this.applications = applications; }
}
