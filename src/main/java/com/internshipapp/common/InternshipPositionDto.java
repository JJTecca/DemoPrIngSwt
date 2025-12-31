package com.internshipapp.common;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

/******************************
 *Purpose of DTO Pattern:
 * 1.Data Transfer: Moves data between layers (Database → Business Logic → UI)
 * 2. Decoupling: Separates database entities from API/UI models
 * 3. Security: Controls what data gets exposed (avoid exposing sensitive fields)
 * 4. Customization: Combine data from multiple entities into one object
 * NOTE: Not all fields need to be used
 *****************************/
public class InternshipPositionDto {
    private Long id;
    private Long companyId;           // id_company in DB
    private String companyName;
    private String title;
    private String description;
    private String requirements;
    private LocalDateTime deadline;   // DATETIME in DB
    private Integer maxSpots;         // max_spots in DB
    private Integer acceptedCount;     // REPLACED filledSpots
    private Integer applicationsCount; // Calculated field
    private Boolean isActive;         // Calculated field
    private Integer availableSpots;
    private boolean alreadyApplied;   // Calculated field
    private List<InternshipApplicationDto> applicants;
    private String status;             // Pending, Open, Closed
    private Date datePosted;           // date_posted in DB

    /************************************************
     * Constructors
     * - we have more type of constructors
     * - adjust params as needed
     * - *NOTE* : constructors called based on feature */
    /****************************************************************
     * PERFORMANCE NOTES
     * - Lazy relationships should not be initialized in constructors
     * - Consider using factory methods for complex object creation
     **************************************************************/
    public InternshipPositionDto() {
    }

    public InternshipPositionDto(Long id, Long companyId, String title,
                                 String description, String requirements,
                                 LocalDateTime deadline, Integer maxSpots) {
        this.id = id;
        this.companyId = companyId;
        this.title = title;
        this.description = description;
        this.requirements = requirements;
        this.deadline = deadline;
        this.maxSpots = maxSpots;
    }

    // Full constructor (Updated to replace filledSpots with acceptedCount and add new fields)
    public InternshipPositionDto(Long id, Long companyId, String companyName,
                                 String title, String description, String requirements,
                                 LocalDateTime deadline, Integer maxSpots,
                                 Integer acceptedCount, Integer applicationsCount,
                                 Boolean isActive, Integer availableSpots,
                                 String status, Date datePosted) {
        this.id = id;
        this.companyId = companyId;
        this.companyName = companyName;
        this.title = title;
        this.description = description;
        this.requirements = requirements;
        this.deadline = deadline;
        this.maxSpots = maxSpots;
        this.acceptedCount = acceptedCount;
        this.applicationsCount = applicationsCount;
        this.isActive = isActive;
        this.availableSpots = availableSpots;
        this.status = status;
        this.datePosted = datePosted;
    }

    // Constructor for Date type (if needed)
    public InternshipPositionDto(Long id, Long companyId, String companyName,
                                 String title, String description, String requirements,
                                 Date deadline, Integer maxSpots) {
        this.id = id;
        this.companyId = companyId;
        this.companyName = companyName;
        this.title = title;
        this.description = description;
        this.requirements = requirements;
        this.deadline = deadline != null ?
                LocalDateTime.ofInstant(deadline.toInstant(), java.time.ZoneId.systemDefault()) : null;
        this.maxSpots = maxSpots;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(Long companyId) {
        this.companyId = companyId;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
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

    public LocalDateTime getDeadline() {
        return deadline;
    }

    public void setDeadline(LocalDateTime deadline) {
        this.deadline = deadline;
    }

    // Set deadline from Date
    public void setDeadlineFromDate(Date deadline) {
        if (deadline != null) {
            this.deadline = LocalDateTime.ofInstant(deadline.toInstant(),
                    java.time.ZoneId.systemDefault());
        }
    }

    // Get deadline as Date
    public Date getDeadlineAsDate() {
        if (deadline != null) {
            return Date.from(deadline.atZone(java.time.ZoneId.systemDefault()).toInstant());
        }
        return null;
    }

    public Integer getMaxSpots() {
        return maxSpots;
    }

    public void setMaxSpots(Integer maxSpots) {
        this.maxSpots = maxSpots;
    }

    public Integer getAcceptedCount() {
        return acceptedCount;
    }

    public void setAcceptedCount(Integer acceptedCount) {
        this.acceptedCount = acceptedCount;
    }

    public Integer getApplicationsCount() {
        return applicationsCount;
    }

    public void setApplicationsCount(Integer applicationsCount) {
        this.applicationsCount = applicationsCount;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public Integer getAvailableSpots() {
        if (availableSpots != null) return availableSpots;
        return calculateAvailableSpots();
    }

    public void setAvailableSpots(Integer availableSpots) {
        this.availableSpots = availableSpots;
    }

    public boolean isAlreadyApplied() {
        return alreadyApplied;
    }

    public void setAlreadyApplied(boolean alreadyApplied) {
        this.alreadyApplied = alreadyApplied;
    }

    public List<InternshipApplicationDto> getApplicants() {
        return applicants;
    }

    public void setApplicants(List<InternshipApplicationDto> applicants) {
        this.applicants = applicants;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Date getDatePosted() {
        return datePosted;
    }

    public void setDatePosted(Date datePosted) {
        this.datePosted = datePosted;
    }

    // Helper methods
    public Integer calculateAvailableSpots() {
        if (acceptedCount != null && maxSpots != null) {
            return Math.max(0, maxSpots - acceptedCount);
        }
        return maxSpots != null ? maxSpots : 0;
    }

    public Boolean calculateIsActive() {
        if (deadline != null) {
            return deadline.isAfter(LocalDateTime.now());
        }
        return false;
    }

    // Check if position is expired
    public Boolean isExpired() {
        if (deadline != null) {
            return deadline.isBefore(LocalDateTime.now());
        }
        return false;
    }

    // Check if position has available spots
    public Boolean hasAvailableSpots() {
        return getAvailableSpots() > 0;
    }
}