package org.proiect.IngSwt.JPAEntities;

import jakarta.persistence.*;

//    NOTE:
//    MySQL supports JSON as a type, but JPA doesn’t natively support JSON. You have a few options in Jakarta EE:
//    You’ll need to manually serialize/deserialize objects using Jackson, Gson, or another library.
@Entity
@Table(name = "company_info")

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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    //Zero to One relationship -> OneToOne -> Join with FK
    @OneToOne(optional = true)
    @JoinColumn(name="id_attachment")
    private Attachment attachment;

    @Column(name="name",nullable = false,length = 255)
    private String name;
    @Column(name="short_name",nullable = false,length = 255)
    private String shortName;
    @Column(name="website",nullable = false,length = 510)
    private String website;
    @Column(name="comp_description",nullable = false, length = 50)
    private String compDescription;
    @Column(name="opened_positions",nullable = false, length = 50)
    private String openedPositions;
    @Column(name="students_applied",nullable = false)
    private String studentsApplied;

    public CompanyInfo() {}

    public Attachment getAttachment() { return attachment; }
    public void setAttachment(Attachment attachment) { this.attachment = attachment;}
    public Integer getId() {return id;}
    public void setId(Integer id) {this.id = id;}
    public String getName() {return name;}
    public void setName(String name) {this.name = name;}
    public String getWebsite() {return website;}
    public void setWebsite(String website) {this.website = website;}
    public String getShortName() {return shortName;}
    public void setShortName(String shortName) {this.shortName = shortName;}
    public String getCompDescription() {return compDescription;}
    public void setCompDescription(String compDescription) {this.compDescription = compDescription;}
    public String getOpenedPositions() {return openedPositions;}
    public void setOpenedPositions(String openedPositions) {this.openedPositions = openedPositions;}
    public String getStudentsApplied() {return studentsApplied;}
    public void setStudentsApplied(String studentsApplied) {this.studentsApplied = studentsApplied;}
}