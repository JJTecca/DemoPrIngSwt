package com.internshipapp.config;

import jakarta.annotation.PostConstruct;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.inject.Inject;
import jakarta.servlet.ServletContext;

import java.io.InputStream;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Properties;
import java.util.logging.Logger;

@Singleton
@Startup
public class ApplicationConfig {

    private static final Logger LOG = Logger.getLogger(ApplicationConfig.class.getName());

    private static final String CONFIG_FILE = "/application-config.properties";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    private boolean applicationPeriodEnabled = true;
    private LocalDate applicationStartDate;
    private LocalDate applicationEndDate;
    private ZoneId timezone;

    @PostConstruct
    public void init() {
        loadConfiguration();
        LOG.info("Application Configuration Loaded: " +
                "Period: " + applicationStartDate + " to " + applicationEndDate +
                " (Enabled: " + applicationPeriodEnabled + ")");
    }

    private void loadConfiguration() {
        try (InputStream input = getClass().getResourceAsStream(CONFIG_FILE)) {
            if (input == null) {
                LOG.warning("Configuration file not found: " + CONFIG_FILE);
                setDefaultValues();
                return;
            }

            Properties props = new Properties();
            props.load(input);

            // Load configuration values
            applicationPeriodEnabled = Boolean.parseBoolean(
                    props.getProperty("internship.application.period.enabled", "true"));

            String startDateStr = props.getProperty("internship.application.start.date");
            String endDateStr = props.getProperty("internship.application.end.date");
            String timezoneStr = props.getProperty("internship.application.timezone", "Europe/Bucharest");

            timezone = ZoneId.of(timezoneStr);

            if (startDateStr != null && endDateStr != null) {
                applicationStartDate = LocalDate.parse(startDateStr, DATE_FORMATTER);
                applicationEndDate = LocalDate.parse(endDateStr, DATE_FORMATTER);
            } else {
                setDefaultValues();
            }

        } catch (Exception e) {
            LOG.severe("Error loading application configuration: " + e.getMessage());
            setDefaultValues();
        }
    }

    private void setDefaultValues() {
        int currentYear = LocalDate.now().getYear();
        applicationStartDate = LocalDate.of(currentYear, 6, 1);
        applicationEndDate = LocalDate.of(currentYear, 7, 1);
        timezone = ZoneId.of("Europe/Bucharest");
        LOG.info("Using default application period: " + applicationStartDate + " to " + applicationEndDate);
    }

    public boolean isApplicationPeriodActive() {
        if (!applicationPeriodEnabled) {
            return true; // If period checking is disabled, always allow
        }

        LocalDate today = LocalDate.now(timezone);
        return !today.isBefore(applicationStartDate) && !today.isAfter(applicationEndDate);
    }

    public LocalDate getApplicationStartDate() {
        return applicationStartDate;
    }

    public LocalDate getApplicationEndDate() {
        return applicationEndDate;
    }

    public ZoneId getTimezone() {
        return timezone;
    }

    public boolean isPeriodEnabled() {
        return applicationPeriodEnabled;
    }

    public String getApplicationPeriodStatus() {
        if (!applicationPeriodEnabled) {
            return "Application period checking is disabled";
        }

        LocalDate today = LocalDate.now(timezone);
        if (today.isBefore(applicationStartDate)) {
            return String.format("Applications open on %s",
                    applicationStartDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")));
        } else if (today.isAfter(applicationEndDate)) {
            return String.format("Application period ended on %s",
                    applicationEndDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")));
        } else {
            return String.format("Applications are open until %s",
                    applicationEndDate.format(DateTimeFormatter.ofPattern("MMMM d, yyyy")));
        }
    }

    public boolean isDateInApplicationPeriod(LocalDate date) {
        if (!applicationPeriodEnabled) {
            return true;
        }
        return !date.isBefore(applicationStartDate) && !date.isAfter(applicationEndDate);
    }
}