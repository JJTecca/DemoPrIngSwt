package com.internshipapp.entities;

import jakarta.persistence.*;

import java.time.LocalDateTime;
/************************
 *      FORMAT
 *      1. Ids
 *      2. Relationships (FKs)
 *      3. Columns
 *      4. Constructor
 *      5. Getter & Setter
 ************************/
@Entity
@Table(name = "accountActivity")
public class AccountActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    @Column(name = "id", nullable = false)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id")
    private UserAccount user;

    // --- UPDATED ENUM ---
    public enum Action {
        UploadCV,
        DeleteCV,
        UploadPFP,
        DeletePFP,
        ChangeCV,
        ChangePFP,
        ChangePassword,
        ChangeDepartRepresentative,
        AppliedForPosition,
        UpdateBiography,
        UpdateDescription,
        UpdateWebsiteURL,
        HideStudyGrade
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "action", nullable = false)
    private Action action;

    @Lob
    @Column(name = "old_data")
    private byte[] oldData;

    @Lob
    @Column(name = "new_data")
    private byte[] newData;

    @Column(name = "action_time", nullable = false)
    private LocalDateTime actionTime = LocalDateTime.now();

    public AccountActivity() {
    }

    public AccountActivity(UserAccount user, Action action, byte[] oldData, byte[] newData) {
        this.user = user;
        this.action = action;
        this.oldData = oldData;
        this.newData = newData;
        this.actionTime = LocalDateTime.now();
    }

    // --- Getters & Setters ---
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public UserAccount getUser() {
        return user;
    }

    // --- ADDED MISSING SETTER ---
    public void setUser(UserAccount user) {
        this.user = user;
    }

    public Action getAction() {
        return action;
    }

    public void setAction(Action action) {
        this.action = action;
    }

    public byte[] getOldData() {
        return oldData;
    }

    public void setOldData(byte[] oldData) {
        this.oldData = oldData;
    }

    public byte[] getNewData() {
        return newData;
    }

    public void setNewData(byte[] newData) {
        this.newData = newData;
    }

    public LocalDateTime getActionTime() {
        return actionTime;
    }

    public void setActionTime(LocalDateTime actionTime) {
        this.actionTime = actionTime;
    }
}