package com.internshipapp.config;

import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

@Stateless
public class ApplicationPeriodService {

    @Inject
    private ApplicationConfig applicationConfig;

    public boolean canApply() {
        return applicationConfig.isApplicationPeriodActive();
    }

    public Map<String, Object> getApplicationPeriodStatus() {
        Map<String, Object> status = new HashMap<>();

        LocalDate startDate = applicationConfig.getApplicationStartDate();
        LocalDate endDate = applicationConfig.getApplicationEndDate();
        LocalDate today = LocalDate.now(applicationConfig.getTimezone());

        status.put("canApply", canApply());
        status.put("startDate", startDate);
        status.put("endDate", endDate);
        status.put("currentDate", today);
        status.put("statusMessage", applicationConfig.getApplicationPeriodStatus());

        // Determine period state
        if (today.isBefore(startDate)) {
            status.put("periodState", "BEFORE");
            status.put("daysUntilStart", java.time.temporal.ChronoUnit.DAYS.between(today, startDate));
        } else if (today.isAfter(endDate)) {
            status.put("periodState", "AFTER");
            status.put("daysSinceEnd", java.time.temporal.ChronoUnit.DAYS.between(endDate, today));
        } else {
            status.put("periodState", "ACTIVE");
            status.put("daysRemaining", java.time.temporal.ChronoUnit.DAYS.between(today, endDate));
        }

        // Formatted dates for display
        DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("MMMM d, yyyy");
        status.put("startDateFormatted", startDate.format(displayFormatter));
        status.put("endDateFormatted", endDate.format(displayFormatter));

        return status;
    }

    public String getBlockedApplicationMessage() {
        Map<String, Object> status = getApplicationPeriodStatus();
        String state = (String) status.get("periodState");

        if ("BEFORE".equals(state)) {
            return String.format("Applications will open on %s. Please check back then!",
                    status.get("startDateFormatted"));
        } else if ("AFTER".equals(state)) {
            return String.format("The application period ended on %s. Please contact the faculty for assistance.",
                    status.get("endDateFormatted"));
        }

        return "Applications are currently closed.";
    }

    public void validateApplicationPeriod() throws IllegalStateException {
        if (!canApply()) {
            throw new IllegalStateException(getBlockedApplicationMessage());
        }
    }
}