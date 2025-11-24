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
    public AttachmentDto() {}
    public AttachmentDto(Long id, byte[] cv, byte[] profilePic) {
        this.id = id;
        this.cv = cv;
        this.profilePic = profilePic;
    }

    public Long getId() { return id;}
    public void setId(Long id) {this.id = id;}
    public byte[] getCv() { return cv; }
    public void setCv(byte[] cv) { this.cv = cv; }
    public byte[] getProfilePic() { return profilePic; }
    public void setProfilePic(byte[] profilePic) { this.profilePic = profilePic; }
}