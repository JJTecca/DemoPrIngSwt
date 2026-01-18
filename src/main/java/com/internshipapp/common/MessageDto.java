package com.internshipapp.common;

import java.io.Serializable;
import java.time.LocalDateTime;

public class MessageDto implements Serializable {
    private Long id;
    private Long applicationId;
    private String senderRole;
    private Long senderId;
    private String senderName;
    private String senderFullName;
    private String messageText;
    private LocalDateTime timeSent;
    private String senderPfpUrl;

    public MessageDto(Long id, Long applicationId, String senderRole, Long senderId,
                      String senderName, String senderFullName, String messageText, LocalDateTime timeSent, String senderPfpUrl) {
        this.id = id;
        this.applicationId = applicationId;
        this.senderRole = senderRole;
        this.senderId = senderId;
        this.senderName = senderName;
        this.senderFullName = senderFullName;
        this.messageText = messageText;
        this.timeSent = timeSent;
        this.senderPfpUrl = senderPfpUrl;
    }

    // Getters
    public Long getId() { return id; }
    public String getSenderRole() { return senderRole; }
    public String getSenderName() { return senderName; }
    public Long getSenderId() { return senderId; }
    public Long getApplicationId() { return applicationId; }
    public String getMessageText() { return messageText; }
    public LocalDateTime getTimeSent() { return timeSent; }
    public String getSenderPfpUrl() { return senderPfpUrl; }
    public String getSenderFullName() { return senderFullName; }
}