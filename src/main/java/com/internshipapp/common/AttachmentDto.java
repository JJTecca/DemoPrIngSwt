package com.internshipapp.common;

/******************************
 *Purpose of DTO Pattern:
 * 1.Data Transfer: Moves data between layers (Database → Business Logic → UI)
 * 2. Decoupling: Separates database entities from API/UI models
 * 3. Security: Controls what data gets exposed (avoid exposing sensitive fields)
 * 4. Customization: Combine data from multiple entities into one object
 * NOTE: Not all fields need to be used
 *****************************/
public class AttachmentDto {
    private Long id;
    private byte[] cv;
    private byte[] profilePic;
    private boolean cvAvailable;
    private boolean profilePicAvailable;

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
    public AttachmentDto() {
    }

    public AttachmentDto(Long id, boolean cvAvailable, boolean profilePicAvailable) {
        this.id = id;
        this.cvAvailable = cvAvailable;
        this.profilePicAvailable = profilePicAvailable;
        this.cv = null;        // Optimization: Don't carry payload
        this.profilePic = null; // Optimization: Don't carry payload
    }

    // Constructor for full data (if ever needed)
    public AttachmentDto(Long id, byte[] cv, byte[] profilePic) {
        this.id = id;
        this.cv = cv;
        this.profilePic = profilePic;
        this.cvAvailable = (cv != null && cv.length > 0);
        this.profilePicAvailable = (profilePic != null && profilePic.length > 0);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public byte[] getCv() {
        return cv;
    }

    public void setCv(byte[] cv) {
        this.cv = cv;
    }

    public byte[] getProfilePic() {
        return profilePic;
    }

    public void setProfilePic(byte[] profilePic) {
        this.profilePic = profilePic;
    }

    public boolean isCvAvailable() {
        return cvAvailable;
    }

    public boolean isProfilePicAvailable() {
        return profilePicAvailable;
    }
}