package com.internshipapp.common;

/******************************
 *Purpose of DTO Pattern:
 * 1.Data Transfer: Moves data between layers (Database → Business Logic → UI)
 * 2. Decoupling: Separates database entities from API/UI models
 * 3. Security: Controls what data gets exposed (avoid exposing sensitive fields)
 * 4. Customization: Combine data from multiple entities into one object
 * NOTE: Not all fields need to be used
 *****************************/
public class CompanyInfoDto {
    private Long id;
    private Long attachmentId;
    private String name;
    private String shortName;
    private String website;
    private String compDescription;
    private String openedPositions;
    private String studentsApplied;
    private String biography; // ADDED

    private String userEmail; // ADDED for session data retrieval
    private String username;  // ADDED for display
    private Long userId;      // ADDED for linking

    // Primary source of attachment data
    private AttachmentDto attachment; // ADDED

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
    public CompanyInfoDto() {
    }

    // FULL CONSTRUCTOR (Used by CompanyInfoBean)
    public CompanyInfoDto(Long id, String name, String shortName, String website,
                          String compDescription, String openedPositions,
                          String studentsApplied, String biography, // NEW BIOGRAPHY
                          AttachmentDto attachment, // NEW ATTACHMENT DTO
                          String userEmail, String username, Long userId) { // NEW USER INFO
        this.id = id;
        this.name = name;
        this.shortName = shortName;
        this.website = website;
        this.compDescription = compDescription;
        this.openedPositions = openedPositions;
        this.studentsApplied = studentsApplied;
        this.biography = biography;
        this.attachment = attachment;
        this.userEmail = userEmail;
        this.username = username;
        this.userId = userId;
    }

    // Helper method for JSP to check PFP existence (Company uses PFP field in Attachment)
    public boolean hasProfilePic() {
        return attachment != null && attachment.isProfilePicAvailable();
    }

    // Helper to get Attachment DTO
    public AttachmentDto getAttachment() {
        return attachment;
    }

    // Getter and Setters (omitting boilerplate except new ones for brevity)

    public Long getId() { return id; }

    public void setId(Long id) { this.id = id; }

    public Long getAttachmentId() { return attachmentId; }

    public void setAttachmentId(Long attachmentId) { this.attachmentId = attachmentId; }

    public String getName() { return name; }

    public void setName(String name) { this.name = name; }

    public String getShortName() { return shortName; }

    public void setShortName(String shortName) { this.shortName = shortName; }

    public String getWebsite() { return website; }

    public void setWebsite(String website) { this.website = website; }

    public String getCompDescription() { return compDescription; }
    public void setCompDescription(String compDescription) { this.compDescription = compDescription; }

    public String getOpenedPositions() { return openedPositions; }

    public void setOpenedPositions(String openedPositions) { this.openedPositions = openedPositions; }

    public String getStudentsApplied() { return studentsApplied; }

    public void setStudentsApplied(String studentsApplied) { this.studentsApplied = studentsApplied; }

    public String getBiography() { return biography; }

    public void setBiography(String biography) { this.biography = biography; }

    public String getUserEmail() { return userEmail; }

    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUsername() { return username; }

    public void setUsername(String username) { this.username = username; }

    public Long getUserId() { return userId; }

    public void setUserId(Long userId) { this.userId = userId; }

}