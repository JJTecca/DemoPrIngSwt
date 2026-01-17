<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.AccountActivityDto" %>
<%@ page import="java.util.List" %>

<%
    List<AccountActivityDto> activities = (List<AccountActivityDto>) request.getAttribute("activities");
%>

<style>
    /* 1. Container & Scrolling Logic */
    .activity-timeline {
        padding: 0;
        max-height: 450px;
        overflow-y: auto;
    }

    /* 2. Row Styling */
    .activity-row {
        padding: 1.1rem 1.2rem;
        border-bottom: 1px solid #f0f0f0;
        transition: background 0.2s;
        display: flex;
        align-items: flex-start; /* Align icon with text */
        gap: 15px;
    }

    .activity-row:last-child {
        border-bottom: none;
    }

    .activity-row:hover {
        background-color: #fafafa;
    }

    /* Icon Styling */
    .activity-icon-wrapper {
        width: 38px;
        height: 38px;
        background-color: #f8f9fa;
        border-radius: 8px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--brand-blue);
        font-size: 1.1rem;
        flex-shrink: 0;
    }

    .activity-info {
        display: flex;
        flex-direction: column;
        gap: 2px;
    }

    .activity-label {
        font-weight: 600;
        color: var(--brand-blue-dark);
        font-size: 1rem; /* Increased font size */
        line-height: 1.2;
    }

    .activity-time {
        color: #888;
        font-size: 0.85rem; /* Increased font size */
    }

    /* 3. Card Structure */
    .custom-card {
        width: 100%;
        border: none;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        border-radius: 8px;
        background: white;
        margin-bottom: 2rem;
        overflow: hidden;
    }
</style>

<div class="card custom-card">
    <div class="card-header fw-bold" style="color: var(--brand-blue); background: white; border-bottom: 1px solid #eee; font-size: 1.1rem; padding: 1.2rem;">
        <i class="fa-solid fa-clock-rotate-left me-2"></i> Recent Activity
    </div>
    <div class="card-body activity-timeline custom-scroll">
        <% if (activities != null && !activities.isEmpty()) { %>
        <% for (AccountActivityDto activity : activities) {
            String rawAction = activity.getAction();
            String prettyAction = rawAction.replaceAll("(?<=[a-z])(?=[A-Z])", " ");

            // Icon Mapping Logic
            String iconClass = "fa-solid fa-circle-dot"; // Default

            // 1. Phone specific icon
            if (rawAction.contains("Phone")) {
                iconClass = "fa-solid fa-phone text-success";
            }
            // 2. Profile & Bio changes
            else if (rawAction.contains("Biography") || rawAction.contains("Description")) {
                iconClass = "fa-solid fa-address-card text-primary";
            }
            // 3. Link & URL changes
            else if (rawAction.contains("Website") || rawAction.contains("URL")) {
                iconClass = "fa-solid fa-globe text-info";
            }
            // 4. Security & Account
            else if (rawAction.contains("Password")) {
                iconClass = "fa-solid fa-shield-halved text-danger";
            }
            else if (rawAction.contains("Login")) {
                iconClass = "fa-solid fa-right-to-bracket text-info";
            }
            // 5. File & Upload Actions
            else if (rawAction.contains("Upload") || rawAction.contains("Picture")) {
                iconClass = "fa-solid fa-camera-rotate text-success";
            }
            // 6. Recruitment Actions
            else if (rawAction.contains("Apply") || rawAction.contains("Position")) {
                iconClass = "fa-solid fa-briefcase text-warning";
            }
            // 7. Generic Fallbacks for keywords
            else if (rawAction.contains("Delete") || rawAction.contains("Remove")) {
                iconClass = "fa-solid fa-trash-can text-danger";
            }
            else if (rawAction.contains("Update") || rawAction.contains("Edit")) {
                iconClass = "fa-solid fa-pen-nib text-primary";
            }
        %>
        <div class="activity-row">
            <div class="activity-icon-wrapper">
                <i class="<%= iconClass %>"></i>
            </div>
            <div class="activity-info">
                <div class="activity-label"><%= prettyAction %></div>
                <div class="activity-time">
                    <i class="fa-regular fa-clock me-1"></i>
                    <%= activity.getActionTime() != null ? activity.getActionTime().toString().substring(0, 16) : "Just now" %>
                </div>
            </div>
        </div>
        <% } %>
        <% } else { %>
        <div class="text-center py-5 text-muted">
            <i class="fa-solid fa-bed fa-3x mb-3 opacity-25 d-block"></i>
            <p class="fs-6">No recent activity found.</p>
        </div>
        <% } %>
    </div>
</div>