package com.internshipapp.commands;

public class InterviewRequestCommand {
    public Long studentId;
    public Long positionId;
    public String initialMessage;
    public Long senderUserId;

    public InterviewRequestCommand(Long studentId, Long positionId,
                                   String initialMessage, Long senderUserId) {
        this.studentId = studentId;
        this.positionId = positionId;
        this.initialMessage = initialMessage;
        this.senderUserId = senderUserId;
    }
}
