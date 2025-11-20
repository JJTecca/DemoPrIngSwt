package org.proiect.IngSwt.JPAEntities;

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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Lob
    @Column(name = "CV", nullable = true)
    private byte[] cv;

    @Lob
    @Column(name = "profile_pic", nullable = true)
    private byte[] profilePic;

    public void setId(Integer id) { this.id = id; }
    public Integer getId() { return id; }
    public void setCv(byte[] cv) { this.cv = cv; }
    public byte[] getCv() { return cv; }
    public void setProfilePic(byte[] profilePic) { this.profilePic = profilePic; }
    public byte[] getProfilePic() { return profilePic; }

}