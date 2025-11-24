package com.internshipapp.entities;
import jakarta.persistence.*;

@Entity
@Table(name = "Attachment")

/************************
 *      FORMAT
 *      1. Id
 *      2. Relationships (FKs)
 *      3. Columns
 *      4. Constructor
 *      5. Getter & Setter
 ************************/
public class Attachment {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    @Lob
    @Column(name = "CV", nullable = true)
    private byte[] cv;

    @Lob
    @Column(name = "profile_pic", nullable = true)
    private byte[] profilePic;

    public void setId(Long id) { this.id = id; }
    public Long getId() { return id; }
    public void setCv(byte[] cv) { this.cv = cv; }
    public byte[] getCv() { return cv; }
    public void setProfilePic(byte[] profilePic) { this.profilePic = profilePic; }
    public byte[] getProfilePic() { return profilePic; }

}