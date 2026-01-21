package com.internshipapp.commands;

import java.time.LocalDateTime;

public class UpdateApplicationCommand {
    public Long appId;
    public String statusName;
    public LocalDateTime interviewDate;
    public String location;
    public String role;

    public UpdateApplicationCommand(Long appId, String statusName, LocalDateTime interviewDate,
                                    String location, String role) {
        this.appId = appId;
        this.statusName = statusName;
        this.interviewDate = interviewDate;
        this.location = location;
        this.role = role;
    }

    public void setInterviewDate(LocalDateTime interviewDate) {
        this.interviewDate = interviewDate;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}
