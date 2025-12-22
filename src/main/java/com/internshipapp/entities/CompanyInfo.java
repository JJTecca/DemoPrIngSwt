package com.internshipapp.entities;

import jakarta.persistence.*;

@Entity
@Table(name = "CompanyInfo")

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
public class CompanyInfo {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    //Zero to One relationship -> OneToOne -> Join with FK
    @OneToOne(optional = true)
    @JoinColumn(name = "id_attachment")
    private Attachment attachment;

    @Column(name = "name", nullable = false, length = 150)
    private String name;
    @Column(name = "short_name", length = 255)
    private String shortName;
    @Column(name = "website", length = 510)
    private String website;
    @Column(name = "comp_description", length = 50)
    private String compDescription;
    @Column(name = "opened_positions", length = 50)
    private String openedPositions;
    @Column(name = "students_applied")
    private String studentsApplied;
    @Column(name = "biography", length = 255)
    private String biography;
    @Column(name = "contact_email", length = 255)
    private String contactEmail;

    public CompanyInfo() {
    }

    public Attachment getAttachment() {
        return attachment;
    }

    public void setAttachment(Attachment attachment) {
        this.attachment = attachment;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getWebsite() {
        return website;
    }

    public void setWebsite(String website) {
        this.website = website;
    }

    public String getShortName() {
        return shortName;
    }

    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public String getCompDescription() {
        return compDescription;
    }

    public void setCompDescription(String compDescription) {
        this.compDescription = compDescription;
    }

    public String getOpenedPositions() {
        return openedPositions;
    }

    public void setOpenedPositions(String openedPositions) {
        this.openedPositions = openedPositions;
    }

    public String getStudentsApplied() {
        return studentsApplied;
    }

    public void setStudentsApplied(String studentsApplied) {
        this.studentsApplied = studentsApplied;
    }

    public String getBiography() { return this.biography; }

    public void setBiography(String biography) { this.biography = biography; }

    public String getContactEmail() { return this.contactEmail; }

    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }
}