<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.*" %>
<%@ page import="java.util.List" %>
<%
    // 1. Authentication and Data Retrieval
    List<InternshipApplicationDto> sidebarApps = (List<InternshipApplicationDto>) request.getAttribute("applications");
    InternshipApplicationDto activeApp = (InternshipApplicationDto) request.getAttribute("activeApplication");
    List<MessageDto> chatHistory = (List<MessageDto>) request.getAttribute("chatHistory");
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("companyInfo");
    String role = (String) session.getAttribute("userRole");
    Long userId = (Long) session.getAttribute("userId");

    if (session == null || userId == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }

    boolean isHired = activeApp != null && ("Accepted".equals(activeApp.getStatus()) || "Completed".equals(activeApp.getStatus()));

    // 2. Personalized Greetings Logic
    String personalizedTitle = "Welcome to your Workspace";
    String personalizedMessage = "Select an application to view details. If a company initiates a discussion, you will see it here.";

    if ("Student".equals(role) && sidebarApps != null) {
        boolean hasAccepted = sidebarApps.stream().anyMatch(a -> "Accepted".equals(a.getStatus()));
        boolean hasInterview = sidebarApps.stream().anyMatch(a -> "Interview".equals(a.getStatus()));
        boolean hasDiscussion = sidebarApps.stream().anyMatch(a -> "Discussion".equals(a.getStatus()));

        if (hasAccepted) {
            personalizedTitle = "Congratulations!";
            personalizedMessage = "One of your applications has been accepted! Check the details tab for the company's contact info.";
        } else if (hasInterview) {
            personalizedTitle = "Upcoming Interviews";
            personalizedMessage = "You have scheduled interviews. Review the time and location in the Application Details tab.";
        } else if (hasDiscussion) {
            personalizedTitle = "Active Discussions";
            personalizedMessage = "Companies are messaging you! Look for the blue indicator in the sidebar to reply.";
        } else if (!sidebarApps.isEmpty()) {
            personalizedTitle = "Applications Sent";
            personalizedMessage = "Your applications are currently pending review. You will be notified once a company starts a conversation.";
        }
    }

    String partnerName = "";
    String partnerEmail = "N/A";
    String partnerPhone = "N/A";

    if (activeApp != null) {
        if ("Student".equals(role)) {
            // Student sees Company info
            partnerName = activeApp.getCompanyName();
            // We use the 'company' object which was correctly fetched by the servlet
            if (company != null) {
                partnerEmail = (company.getContactEmail() != null) ? company.getContactEmail() : "N/A";
                partnerPhone = (company.getPhoneNumber() != null) ? company.getPhoneNumber() : "N/A";
            }
        } else {
            // Company/Faculty sees Student info
            partnerName = activeApp.getStudentName();
            // The activeApp DTO should have the student's email. If not, we rely on the DTO structure.
            // Assuming activeApp.getStudentEmail() exists in your DTO:
            partnerEmail = (activeApp.getStudentEmail() != null) ? activeApp.getStudentEmail() : "Email N/A";
        }
    }

    boolean interviewHasPassed = false;
    if (activeApp != null && activeApp.getInterview() != null) {
        try {
            java.time.LocalDateTime interviewTime = java.time.LocalDateTime.parse(activeApp.getInterview().toString());
            interviewHasPassed = interviewTime.isBefore(java.time.LocalDateTime.now());
        } catch (Exception e) {
            // Fallback for different date formats if necessary
            interviewHasPassed = false;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Applications Hub - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f7f9;
        }

        .main-container {
            height: calc(100vh - 72px);
            display: flex !important;
            align-items: stretch;
            overflow: hidden;
        }

        /* Sidebars Positioning */
        .sidebar-container, .applications-sidebar {
            height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            top: 0 !important;
            position: relative;
        }

        /* Main Content Column */
        .content-pane {
            flex: 1;
            background: white;
            display: flex;
            flex-direction: column;
            justify-content: flex-start !important;
            overflow: hidden;
            animation: fadeIn 0.4s ease-in-out;
        }

        /* Tab Content filled height */
        .tab-content {
            flex: 1;
            display: block; /* Standard block to prevent centering */
            position: relative;
            overflow: hidden;
        }

        /* Pane Visibility Sync */
        .tab-pane {
            display: none;
            height: 100%;
            width: 100%;
        }

        .tab-pane.active {
            display: block;
        }

        /* Chat specific flex for input stickiness */
        #chatContent.active {
            display: flex !important;
            flex-direction: column;
        }

        /* Chat UI */
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 25px;
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .bubble {
            max-width: 75%;
            padding: 12px 18px;
            border-radius: 18px;
            font-size: 0.95rem;
            line-height: 1.5;
        }

        .bubble-in {
            background: white;
            align-self: flex-start;
            border: 1px solid #eee;
        }

        .bubble-out {
            background: linear-gradient(135deg, #0E2B58 0%, #1a4a8d 100%);
            color: white;
            align-self: flex-end;
        }

        .chat-pfp {
            width: 32px;
            height: 32px;
            object-fit: cover;
        }

        .hub-header {
            background: white;
            border-bottom: 1px solid #eef2f5;
            padding: 1rem 1.5rem;
        }

        .nav-tabs-custom {
            border: none;
            gap: 15px;
            display: flex;
            flex-wrap: nowrap;
            overflow-x: auto;
            margin: 0;
            padding: 5px;
        }

        .nav-tabs-custom .nav-link {
            border: none;
            border-radius: 12px;
            padding: 0.75rem 2rem;
            font-weight: 700;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            white-space: nowrap;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);

            background: var(--brand-gradient) !important;
            color: white !important;
            opacity: 0.85;
            box-shadow: 0 4px 6px rgba(14, 43, 88, 0.1);
        }

        .nav-tabs-custom .nav-link i {
            color: white !important;
            margin-right: 8px;
        }

        .nav-tabs-custom .nav-link:hover {
            opacity: 1;
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 8px 15px rgba(14, 43, 88, 0.25);
            z-index: 10;
            color: white !important;
        }

        .nav-tabs-custom .nav-link.active {
            opacity: 1;
            transform: translateY(-3px) scale(1.05);
            box-shadow: 0 8px 20px rgba(14, 43, 88, 0.35);
            border: 1px solid rgba(255, 255, 255, 0.2);
            color: white !important;
        }

        .nav-tabs-custom .nav-link.active::after {
            content: none;
        }

        .form-control-chat {
            border-radius: 30px;
            padding: 12px 25px;
            background: #fdfdfd;
            border: 1px solid #eef2f5;
        }

        .empty-hub-icon {
            font-size: 5rem;
            background: linear-gradient(135deg, #eef2f5 0%, #dce3e8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(5px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .status-select-custom {
            font-weight: 800 !important;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-radius: 50px !important; /* Pill shape like badges */
            padding: 0.5rem 1.2rem !important;
            font-size: 0.75rem !important;
            transition: all 0.3s ease;
        }

        /* Specific state colors for the select element */
        select.status-discussion {
            background-color: #f3e5f5;
            color: #6a1b9a;
            border-color: #e1bee7;
        }

        select.status-interview {
            background-color: #cff4fc;
            color: #055160;
            border-color: #b6effb;
        }

        select.status-accepted {
            background-color: #d1e7dd;
            color: #0f5132;
            border-color: #badbcc;
        }

        select.status-rejected {
            background-color: #f8d7da;
            color: #842029;
            border-color: #f5c2c7;
        }

        /* --- Application Details Styling --- */
        .detail-label {
            font-size: 0.9rem;
            font-weight: 800;
            color: var(--brand-blue-dark);
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .highlight-box {
            background-color: #f8fafc;
            border: 1px solid #eef2f5;
            border-radius: 12px;
            padding: 1.5rem;
            color: #475569;
            line-height: 1.7;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.02);
        }

        /* --- Management Card Upgrades --- */
        .manage-card {
            background: white;
            border: 1px solid #eef2f5 !important;
            border-top: 4px solid var(--brand-blue) !important;
            border-radius: 12px !important;
        }

        .form-label-custom {
            font-size: 0.75rem;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
            margin-bottom: 0.5rem;
        }

        /* Custom Status Select that mimics badge styles */
        .status-select-custom {
            font-weight: 700 !important;
            border-radius: 8px !important;
            padding: 0.6rem 1rem !important;
            border: 1px solid #cbd5e1 !important;
            cursor: pointer;
        }

        /* Apply gradient to update button */
        .btn-update-status {
            background: var(--brand-gradient);
            border: none;
            color: white;
            padding: 0.8rem;
            border-radius: 10px;
            font-weight: 700;
            transition: all 0.3s ease;
        }

        .btn-update-status:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(14, 43, 88, 0.3);
            color: white;
        }

        .app-card {
            transition: all 0.2s ease-in-out;
        }

        .app-card:hover {
            transform: translateX(5px);
            background-color: #f8f9fa;
        }

        /* Targeted Area: View Student Profile Button Style */
        .btn-view-profile {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;

            background-color: #ffffff;
            color: var(--brand-blue);
            border: 1.5px solid var(--brand-blue);
            border-radius: 8px; /* Professional squared corners */
            padding: 0.6rem 1.2rem;

            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all 0.2s ease-in-out;
        }

        .btn-view-profile i {
            font-size: 0.9rem;
            transition: transform 0.2s ease;
        }

        .btn-view-profile:hover {
            background-color: #f0f4f8; /* Very light faculty blue tint */
            color: var(--brand-blue-dark);
            border-color: var(--brand-blue-dark);
            box-shadow: 0 4px 12px rgba(14, 43, 88, 0.1);
        }

        .btn-view-profile:hover i {
            transform: translateX(3px); /* Subtle directional hint */
        }

        .grading-header {
            background: var(--brand-gradient);
            color: white;
            padding: 1.25rem;
            border-radius: 12px 12px 0 0;
        }

        .grade-input-group {
            background: #f8fafc;
            border: 2px solid #eef2f5;
            border-radius: 12px;
            padding: 1.5rem;
            transition: border-color 0.3s ease;
        }

        .grade-input-group:focus-within {
            border-color: var(--brand-blue);
        }

        .grade-number {
            font-size: 2rem;
            font-weight: 800;
            color: var(--brand-blue-dark);
            max-width: 120px;
            text-align: center;
            border: none;
            background: transparent;
        }

        .grade-number:focus {
            outline: none;
        }

        .feedback-area {
            height: 340px;
            min-height: 1000px;
            max-height: 1500px;

            width: 100%;
            resize: vertical;
            border: none;
            font-size: 1rem;
            line-height: 1.7;
            padding: 2rem !important;
            background-color: #fff;

            display: block;
            overflow-y: auto;

            transition: background-color 0.2s ease;
        }

        .feedback-area:focus {
            background-color: #fcfdfe;
            outline: none;
        }

        .btn-submit-evaluation {
            background: var(--brand-gradient);
            border: none;
            color: white;
            padding: 0.8rem 2.5rem;
            border-radius: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: filter 0.2s ease;
        }

        .btn-submit-evaluation:hover {
            filter: brightness(1.1);
            color: white;
        }

        .status-badge {
            font-size: 0.65rem;
            padding: 0.3em 0.7em;
            border-radius: 50px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
            border-width: 1px;
            border-style: solid;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
            border-color: #ffeeba;
        }

        .status-accepted {
            background-color: #d1e7dd;
            color: #0f5132;
            border-color: #badbcc;
        }

        .status-rejected {
            background-color: #f8d7da;
            color: #842029;
            border-color: #f5c2c7;
        }

        .status-interview {
            background-color: #cff4fc;
            color: #055160;
            border-color: #b6effb;
        }

        .status-discussion {
            background-color: #f3e5f5;
            color: #6a1b9a;
            border-color: #e1bee7;
        }

        .status-request {
            background-color: #e8eaf6;
            color: #283593;
            border-color: #c5cae9;
        }

        .invalid-feedback-custom {
            font-size: 0.7rem;
            font-weight: 700;
            color: #dc3545;
            margin-top: 0.25rem;
            display: none; /* Shown via JS */
        }

        .form-control.is-invalid {
            border-color: #dc3545 !important;
            background-image: none !important; /* Remove default bootstrap icon if desired */
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid p-0">
    <div class="main-container">
        <%-- Sidebars --%>
        <jsp:include page='<%= "../blocks/" + role.toLowerCase() + "Sidebar.jsp" %>'/>
        <jsp:include page="../blocks/applicationsSidebar.jsp"/>

        <main class="content-pane">
            <% if (activeApp == null) { %>
            <div class="m-auto text-center p-5" style="max-width: 600px;">
                <div class="empty-hub-icon mb-4"><i class="fa-solid fa-comments"></i></div>
                <h3 class="fw-bold text-dark"><%= "Faculty".equals(role) ? "Tutoring Management Hub" : personalizedTitle %>
                </h3>
                <p class="text-muted lead"><%= "Faculty".equals(role) ? "Review qualifications or finalize assignments." : personalizedMessage %>
                </p>
            </div>
            <% } else { %>
            <div class="hub-header d-flex justify-content-between align-items-center shadow-sm">
                <div class="d-flex align-items-center gap-3">
                    <div class="bg-primary-subtle p-2 rounded-3 text-primary"><i
                            class="fa-solid fa-briefcase fa-lg"></i></div>
                    <div>
                        <h5 class="fw-bold mb-0 text-dark"><%= activeApp.getPositionTitle() %>
                        </h5>
                        <span class="small text-muted fw-semibold">Discussion with <%= partnerName %></span>
                    </div>
                </div>
                <div class="text-end">
                    <% if ("Student".equals(role)) { %>
                    <div class="small fw-bold text-muted">
                        <i class="fa-regular fa-envelope me-2"></i><%= partnerEmail %>
                    </div>

                    <% if (isHired) { %>
                    <div class="small fw-bold text-success mt-1">
                        <i class="fa-solid fa-phone-volume me-2"></i><%= partnerPhone %>
                    </div>
                    <% } %>

                    <% } else { %>
                    <div class="small fw-bold text-muted">
                        <i class="fa-regular fa-envelope me-2"></i><%= partnerEmail %>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="tabs-wrapper">
                <ul class="nav nav-tabs nav-tabs-custom" id="hubTabs" role="tablist">
                    <% boolean chatIsPrimary = activeApp.isChatInitiated() || !"Student".equals(role); %>

                    <% if (chatIsPrimary) { %>
                    <li class="nav-item">
                        <button class="nav-link active" id="chat-tab" data-bs-toggle="tab" data-bs-target="#chatContent"
                                type="button">
                            <i class="fa-solid fa-comments"></i>Chat
                        </button>
                    </li>
                    <% } %>

                    <li class="nav-item">
                        <button class="nav-link <%= !chatIsPrimary ? "active" : "" %>" id="details-tab"
                                data-bs-toggle="tab" data-bs-target="#detailsContent" type="button">
                            <i class="fa-solid fa-circle-info"></i>Application Details
                        </button>
                    </li>
                </ul>
            </div>

            <div class="tab-content">
                <div class="tab-pane fade <%= chatIsPrimary ? "show active" : "" %>" id="chatContent" role="tabpanel">
                    <div class="chat-messages custom-scrollbar">
                        <% if (chatHistory != null && !chatHistory.isEmpty()) {
                            for (MessageDto msg : chatHistory) {
                                boolean isMe = (userId.equals(msg.getSenderId())); %>
                        <div class="d-flex <%= isMe ? "justify-content-end" : "justify-content-start" %> mb-2">
                            <% if (!isMe) { %><img src="<%= msg.getSenderPfpUrl() %>"
                                                   class="chat-pfp rounded-circle me-2 mt-auto border shadow-sm"><% } %>
                            <div class="bubble <%= isMe ? "bubble-out" : "bubble-in" %>">
                                <% if (!isMe) { %>
                                <div class="fw-bold mb-1" style="font-size: 0.75rem;"><%= msg.getSenderName() %>
                                </div>
                                <% } %>
                                <div class="message-text"><%= msg.getMessageText() %>
                                </div>
                                <div class="text-end mt-1 opacity-50"
                                     style="font-size: 0.65rem;"><%= msg.getTimeSent().toString().substring(11, 16) %>
                                </div>
                            </div>
                            <% if (isMe) { %><img src="<%= msg.getSenderPfpUrl() %>"
                                                  class="chat-pfp rounded-circle ms-2 mt-auto border shadow-sm"><% } %>
                        </div>
                        <% }
                        } else { %>
                        <div class="m-auto text-center opacity-50">
                            <i class="fa-regular fa-comments fa-3x mb-3"></i>
                            <p class="fw-bold">No messages yet.</p>
                        </div>
                        <% } %>
                    </div>
                    <div class="p-3 border-top bg-white">
                        <% if ("Rejected".equals(activeApp.getStatus())) { %>
                        <div class="alert alert-secondary mb-0 py-2 text-center small border-0 bg-light">Closed.
                            Messaging disabled.
                        </div>
                        <% } else { %>
                        <form action="SendMessage" method="POST" class="d-flex gap-2">
                            <input type="hidden" name="appId" value="<%= activeApp.getId() %>">
                            <input type="text" name="message" class="form-control form-control-chat"
                                   placeholder="Type a message..." required autocomplete="off">
                            <button type="submit" class="btn btn-primary rounded-circle"
                                    style="width: 48px; height: 48px;"><i class="fa-solid fa-paper-plane"></i></button>
                        </form>
                        <% } %>
                    </div>
                </div>

                <div class="tab-pane fade <%= !chatIsPrimary ? "show active" : "" %> p-5 overflow-auto custom-scrollbar"
                     id="detailsContent" role="tabpanel">
                    <div class="row g-5 align-items-start">
                        <div class="col-lg-7">
                            <div class="mb-5">
                                <h5 class="detail-label"><i class="fa-solid fa-file-lines text-primary"></i> Job
                                    Description</h5>
                                <div class="highlight-box">
                                    <%= (activeApp.getDescription() != null) ? activeApp.getDescription() : "No description." %>
                                </div>
                            </div>
                            <div class="mb-5">
                                <h5 class="detail-label"><i class="fa-solid fa-list-check text-primary"></i>
                                    Requirements</h5>
                                <div class="highlight-box">
                                    <%= (activeApp.getRequirements() != null) ? activeApp.getRequirements() : "No requirements." %>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-5">
                            <% if (!"Student".equals(role)) { %>
                            <div class="mb-4">
                                <a href="${pageContext.request.contextPath}/StudentProfile?id=<%= activeApp.getStudentId() %>"
                                   class="btn btn-view-profile w-100 shadow-sm">
                                    <i class="fa-solid fa-user-graduate me-2"></i> View Student Profile
                                </a>
                            </div>

                            <% if (isHired) { %>
                            <div class="card manage-card shadow-sm border-0 mb-4 overflow-hidden">
                                <div class="grading-header">
                                    <h6 class="m-0 fw-bold small text-uppercase"><i class="fa-solid fa-graduation-cap me-2"></i>Final Grade</h6>
                                </div>
                                <div class="card-body py-5 text-center">
                                    <div class="grade-input-group d-inline-flex align-items-center gap-2">
                                        <input type="number" form="gradingForm" name="grade" step="0.1" min="0" max="10"
                                               class="grade-number" placeholder="0.0"
                                               value="<%= activeApp.getGrade() != null ? activeApp.getGrade() : "" %>" required>
                                        <span class="h3 m-0 text-muted opacity-50">/ 10</span>
                                    </div>
                                    <p class="text-muted small mt-2">Enter numeric score for student records.</p>
                                </div>
                            </div>
                            <% } else if ("Request".equals(activeApp.getStatus())) { %>
                            <div class="card manage-card shadow-sm p-4 text-center border-warning">
                                <div class="mb-3 text-warning">
                                    <i class="fa-solid fa-hourglass-half fa-3x"></i>
                                </div>
                                <h5 class="fw-bold">Awaiting Student</h5>
                                <p class="text-muted small">
                                    This interview was requested by you. Management options will become available once
                                    the student accepts the discussion.
                                </p>
                                <div class="status-badge status-request mt-2">Current Status: Request</div>
                            </div>
                            <% } else { %>
                            <div class="card manage-card shadow-sm p-4">
                                <div id="formErrorAlert" class="alert alert-danger d-none border-0 small mb-3 py-2">
                                    <i class="fa-solid fa-circle-exclamation me-2"></i> <span>Please fill all required fields.</span>
                                </div>
                                <h5 class="fw-bold mb-4 d-flex align-items-center justify-content-between">
                                    Management <span
                                        class="status-badge status-<%= activeApp.getStatus().toLowerCase() %>"><%= activeApp.getStatus() %></span>
                                </h5>
                                <form action="InternshipApplications" method="GET"
                                      onsubmit="return validateManagementForm(this)">
                                    <input type="hidden" name="action" value="updateStatus">
                                    <input type="hidden" name="id" value="<%= activeApp.getId() %>">

                                    <div class="mb-3">
                                        <label class="form-label-custom">Interview Date</label>
                                        <input type="datetime-local" name="interviewDate" id="dateInput"
                                               class="form-control"
                                               value="<%= (activeApp.getInterview() != null) ? activeApp.getInterview().toString() : "" %>">
                                        <div class="invalid-feedback-custom" id="dateFeedback">A date is required for
                                            interviews.
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label-custom">Location</label>
                                        <input type="text" name="location" id="locInput" class="form-control"
                                               value="<%= (activeApp.getInterviewLocation() != null) ? activeApp.getInterviewLocation() : "" %>"
                                               placeholder="Not yet specified">
                                        <div class="invalid-feedback-custom" id="locFeedback">A location is required for
                                            interviews.
                                        </div>
                                    </div>
                                    <div class="mb-4">
                                        <label class="form-label-custom">Application Status</label>
                                        <select name="status" id="statusSelect"
                                                class="form-select status-select-custom status-<%= activeApp.getStatus().toLowerCase() %>"
                                                onchange="updateSelectTheme(this)">
                                            <option value="Discussion" <%= "Discussion".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Discussion
                                            </option>
                                            <option value="Interview" <%= "Interview".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Interview
                                            </option>

                                            <%--
                                                RULE 1: Only show 'Accepted' if currently in 'Interview' status.
                                                RULE 2: Only allow selecting 'Accepted' if the interview date has passed.
                                            --%>
                                            <% if ("Interview".equals(activeApp.getStatus())) { %>
                                            <option value="Accepted"
                                                    <%= !interviewHasPassed ? "disabled title='Interview date must pass before accepting'" : "" %>
                                                    <%= "Accepted".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Accepted <%= !interviewHasPassed ? "(Locked)" : "" %>
                                            </option>
                                            <% } %>

                                            <option value="Rejected" <%= "Rejected".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Rejected
                                            </option>
                                        </select>
                                    </div>
                                    <button type="submit" class="btn btn-update-status w-100">
                                        <i class="fa-solid fa-rotate me-2"></i> Update Application
                                    </button>
                                </form>
                            </div>
                            <% } %>
                            <% } %>
                        </div>
                    </div>
                    <% if (!"Student".equals(role) && isHired) { %>
                    <div class="row mt-4">
                        <div class="col-12">
                            <form action="InternshipApplications" method="POST" id="gradingForm">
                                <input type="hidden" name="action" value="gradeInternship">
                                <input type="hidden" name="id" value="<%= activeApp.getId() %>">
                                <%-- Grade input is handled by the form="gradingForm" attribute in the sidebar code above --%>

                                <div class="feedback-container shadow-sm overflow-hidden mb-4">
                                    <div class="grading-header">
                                        <h6 class="m-0 fw-bold small text-uppercase"><i class="fa-solid fa-comment-medical me-2"></i>QUALITATIVE EVALUATION & REMARKS</h6>
                                    </div>
                                    <textarea name="feedback" class="form-control feedback-area p-4"
                                              placeholder="Provide detailed remarks on performance and growth..."><%= activeApp.getFeedback() != null ? activeApp.getFeedback() : "" %></textarea>
                                    <div class="p-3 bg-light border-top text-center">
                                        <button type="submit" class="btn btn-submit-evaluation">
                                            <i class="fa-solid fa-cloud-arrow-up me-2"></i> Finalize Evaluation & Save
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>
        </main>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.app-card').forEach(link => {
        link.addEventListener('click', () => {
            const sidebar = document.querySelector('.flex-grow-1.overflow-auto');
            if (sidebar) localStorage.setItem('sidebarScroll', sidebar.scrollTop);
        });
    });
    window.addEventListener('load', () => {
        const sidebar = document.querySelector('.flex-grow-1.overflow-auto');
        const scrollPos = localStorage.getItem('sidebarScroll');
        if (scrollPos && sidebar) sidebar.scrollTop = scrollPos;
    });

    function updateSelectTheme(selectElement) {
        if (!selectElement) return;
        const statuses = ['status-discussion', 'status-interview', 'status-accepted', 'status-rejected'];
        selectElement.classList.remove(...statuses);
        const selectedStatus = 'status-' + selectElement.value.toLowerCase();
        selectElement.classList.add(selectedStatus);

        const dateInput = document.getElementById('dateInput');
        const locInput = document.getElementById('locInput');

        if (selectElement.value === 'Interview') {
            if (dateInput) dateInput.setAttribute('required', 'true');
            if (locInput) locInput.setAttribute('required', 'true');
        } else {
            if (dateInput) dateInput.removeAttribute('required');
            if (locInput) locInput.removeAttribute('required');
        }
    }

    function validateManagementForm(form) {
        const statusSelect = document.getElementById('statusSelect');
        const dateInput = document.getElementById('dateInput');
        const locInput = document.getElementById('locInput');
        const alertBox = document.getElementById('formErrorAlert');

        // CRITICAL: If the form isn't rendered (Accepted/Request state), exit silently
        if (!statusSelect || !dateInput || !locInput) return true;

        const newStatus = statusSelect.value;
        const currentStatus = "<%= (activeApp != null) ? activeApp.getStatus() : "" %>";

        // 2. Reset states
        dateInput.classList.remove('is-invalid');
        locInput.classList.remove('is-invalid');
        if (alertBox) alertBox.classList.add('d-none');

        // Safety check for feedback elements
        const dFeed = document.getElementById('dateFeedback');
        const lFeed = document.getElementById('locFeedback');
        if (dFeed) dFeed.style.display = 'none';
        if (lFeed) lFeed.style.display = 'none';

        // 3. Data comparison (Do nothing if no changes)
        if (newStatus === currentStatus) {
            if (newStatus === 'Interview') {
                const currentDataDate = "<%= (activeApp != null && activeApp.getInterview() != null) ? activeApp.getInterview().toString() : "" %>";
                const currentDataLoc = "<%= (activeApp != null && activeApp.getInterviewLocation() != null) ? activeApp.getInterviewLocation() : "" %>";

                if (dateInput.value === currentDataDate && locInput.value.trim() === currentDataLoc) {
                    return false;
                }
            } else {
                return false;
            }
        }

        // 4. Required Field Validation (Only for Interview)
        if (newStatus === 'Interview') {
            let isValid = true;
            if (!dateInput.value) {
                dateInput.classList.add('is-invalid');
                if (dFeed) dFeed.style.display = 'block';
                isValid = false;
            }
            if (!locInput.value || locInput.value.trim() === "") {
                locInput.classList.add('is-invalid');
                if (lFeed) lFeed.style.display = 'block';
                isValid = false;
            }
            if (!isValid) {
                if (alertBox) alertBox.classList.remove('d-none');
                return false;
            }
        }
        return true;
    }

    <% if (activeApp != null) { %>
    (function() {
        const appId = <%= activeApp.getId() %>;
        // Construct the WebSocket URL (ws:// for http, wss:// for https)
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const wsUrl = protocol + "//" + window.location.host + "<%= request.getContextPath() %>/chat-socket/" + appId;

        const chatSocket = new WebSocket(wsUrl);

        chatSocket.onmessage = function(event) {
            if (event.data === "NEW_MESSAGE") {
                const messageInput = document.querySelector('input[name="message"]');
                // Only reload if the user isn't currently typing to avoid losing their draft
                if (document.activeElement !== messageInput) {
                    window.location.reload();
                } else {
                    console.log("New message arrived. Refresh pending (user typing)...");
                }
            }
        };

        // Optional: Reconnect logic if the socket closes
        chatSocket.onclose = function() {
            console.log("ChatSocket closed. Real-time updates disabled until refresh.");
        };
    })();
    <% } %>
</script>
</body>
</html>