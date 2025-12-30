package com.internshipapp.entities;

import jakarta.persistence.*;
/************************
 *      FORMAT
 *      1. Ids
 *      2. Relationships (FKs)
 *      3. Columns
 *      4. Constructor
 *      5. Getter & Setter
 ************************/
@Entity
@Table(name = "Attachment")
public class Attachment {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    // --- CV DATA ---
    @Lob
    @Column(name = "CV", length = 10000000) // 10MB limit hint
    private byte[] cv;

    @Column(name = "cv_file_name")
    private String cvFileName;

    @Column(name = "cv_content_type")
    private String cvContentType;

    // --- PROFILE PIC ---
    @Lob
    @Column(name = "profile_pic", length = 5000000)
    private byte[] profilePic;

    @Column(name = "has_cv")
    private Boolean hasCv = false;

    @Column(name = "has_profile_pic")
    private Boolean hasProfilePic = false;

    public Attachment() {}

    // Getters and Setters
    public void setId(Long id) {
        this.id = id;
    }

    public Long getId() {
        return id;
    }

    public void setCv(byte[] cv) {
        this.cv = cv;
    }

    public byte[] getCv() {
        return cv;
    }

    public String getCvFileName() {
        return cvFileName;
    }

    public void setCvFileName(String cvFileName) {
        this.cvFileName = cvFileName;
    }

    public String getCvContentType() {
        return cvContentType;
    }

    public void setCvContentType(String cvContentType) {
        this.cvContentType = cvContentType;
    }

    public void setProfilePic(byte[] profilePic) {
        this.profilePic = profilePic;
    }

    public byte[] getProfilePic() {
        return profilePic;
    }

    public Boolean hasCv() {
        return hasCv != null && hasCv;
    }

    public void setHasCv(Boolean hasCv) {
        this.hasCv = hasCv;
    }

    public Boolean hasProfilePic() {
        return hasProfilePic != null && hasProfilePic;
    }

    public void setHasProfilePic(Boolean hasProfilePic) {
        this.hasProfilePic = hasProfilePic;
    }
}