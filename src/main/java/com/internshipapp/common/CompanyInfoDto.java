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
    public CompanyInfoDto() {}
    public CompanyInfoDto(Long id, Long attachmentId, String name, String shortName, String website, String compDescription, String openedPositions, String studentsApplied) {
        this.id = id;
        this.attachmentId = attachmentId;
        this.name = name;
        this.shortName = shortName;
        this.website = website;
        this.compDescription = compDescription;
        this.openedPositions = openedPositions;
        this.studentsApplied = studentsApplied;
    }

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
    public void setStudentsApplied(String studentsApplied) { this.studentsApplied = studentsApplied;}
}