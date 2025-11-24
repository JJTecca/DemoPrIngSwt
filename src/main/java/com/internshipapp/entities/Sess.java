package com.internshipapp.entities;

import jakarta.persistence.*;

import java.time.LocalDateTime;


@Entity
@Table(name = "sess")

/************************
 *      FORMAT
 *      1. Ids
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
public class Sess {
    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    //Relationship with UserAccount
    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id")
    private UserAccount user;

    @Column(name="login")
    private LocalDateTime login;
    @Column(name="token",length = 255)
    private String token;
}