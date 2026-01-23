<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
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
    String personalizedMessage;
    String personalizedTitle = "Welcome to your Workspace";
    if ("Student".equals(role)) {
        personalizedMessage = "Select an application to view details. If a company initiates a discussion, you will see it here.";
    } else {
        personalizedMessage = "Select an application to view details. Set interviews with your applicants and evaluate them at the end of the internship period.";
    }

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

    boolean canChat = activeApp != null &&
            ("Discussion".equals(activeApp.getStatus()) ||
                    "Interview".equals(activeApp.getStatus()));

    Map<String, Object> pStatus = (Map<String, Object>) request.getAttribute("applicationPeriod");
    // Ensure this is ISO format for the JS Date constructor
    String interviewMaxDate = (pStatus != null) ? pStatus.get("interviewCutoffDate").toString() : "";
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
            background: #ffffff !important;
            padding: 30px;
            display: flex !important;
            flex-direction: column !important;
            gap: 10px;
            width: 100% !important;
            align-items: stretch !important;
        }

        /* The Row: Always 100% wide */
        .message-row {
            display: flex !important;
            width: 100% !important;
            flex-direction: row !important;
            margin-bottom: 1rem;
            align-items: flex-end !important;
        }

        /* Custom class: Moves content to the RIGHT */
        .row-right {
            justify-content: flex-end !important;
        }

        /* Custom class: Moves content to the LEFT */
        .row-left {
            justify-content: flex-start !important;
        }

        #sendBtn {
            display: flex; /* Always flex but controlled by opacity/pointer */
            opacity: 0;
            transform: scale(0.8);
            pointer-events: none;
            transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }

        #sendBtn.visible {
            opacity: 1;
            transform: scale(1);
            pointer-events: auto;
        }

        .bubble {
            padding: 15px 22px; /* Tiny bit bigger as requested */
            border-radius: 20px;
            font-size: 1rem;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
            position: relative;
            background: #f1f4f7; /* Light gray bubble background */
            color: #1e293b;
            border: 1px solid #e2e8f0;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }

        /* Specific tail logic for orientation */
        .bubble-in {
            border-bottom-left-radius: 4px;
        }

        .bubble-out {
            border-bottom-right-radius: 4px;
        }

        .row-right .bubble {
            margin-left: auto;
        }

        .row-left .bubble {
            margin-right: auto;
        }

        .flex-spacer {
            flex-grow: 1;
            background: rgba(255, 0, 0, 0.2);
        }

        .chat-date-separator {
            text-align: center;
            margin: 20px 0;
            position: relative;
            width: 100%; /* Force this to span the whole chat */
        }

        /* Centered Date Separator on white bg */
        .chat-date-separator span {
            background: #ffffff; /* Matches new bg */
            padding: 0 20px;
            color: #94a3b8;
            font-size: 0.75rem;
            font-weight: 800;
        }

        /* Professional Send Button with Faculty Gradient */
        .btn-send-gradient {
            background: var(--brand-gradient);
            color: white !important;
            border: none;
            border-radius: 15px !important;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .btn-send-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(14, 43, 88, 0.2);
        }

        /* Date Separator */
        .chat-date-separator {
            text-align: center;
            margin: 20px 0;
            position: relative;
        }

        /* Professional Input Area */
        .chat-input-wrapper {
            background: white;
            border-top: 1px solid #eef2f5;
            padding: 20px 30px;
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
            justify-content: center;
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
            background-color: #f2f4f7;
            border: 1px solid #d1d9e2;
            border-radius: 12px;
            padding: 1.5rem;
            color: #334155;
            line-height: 1.7;
            box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.01);
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

        .profile-link-refined {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #64748b;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            position: relative;
            padding: 8px 16px; /* Increased padding for the background box */
            background-color: #f1f5f9; /* Constant light gray background */
            border-radius: 8px;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        .profile-link-refined i {
            font-size: 0.9rem;
            color: #94a3b8;
            transition: transform 0.3s ease, color 0.3s ease;
        }

        .profile-link-refined:hover {
            transform: translateY(-2px); /* Smaller lift for secondary links */
            background-color: #eef2f6;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
        }

        .profile-link-refined:hover i {
            transform: translateX(4px);
            color: var(--brand-blue);
        }

        /* The animated underline */
        .profile-link-refined::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: 0;
            right: 0; /* Starts from right for a smooth flow */
            background-color: var(--brand-blue);
            transition: width 0.3s ease;
        }

        .profile-link-refined:hover i {
            transform: translateX(4px); /* Original subtle nudge */
            color: var(--brand-blue);
        }

        .profile-link-refined:hover::after {
            width: 100%;
            left: 0;
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

        .grading-card-header {
            background: var(--brand-gradient);
            color: white !important;
            padding: 1rem 1.25rem;
            border: none;
        }

        .grading-card-header h6 {
            color: white !important;
            margin: 0;
            font-weight: 700;
        }

        .grade-display-large {
            font-size: 3.5rem;
            font-weight: 800;
            color: var(--brand-blue-dark);
        }

        .grade-placeholder {
            color: #cbd5e1;
            font-style: italic;
        }

        #feedbackDisplay {
            text-align: left !important;
            display: block !important; /* Overrides any flex centering */
            overflow-y: auto;
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 2rem !important;
        }

        #feedbackDisplay::first-line {
            line-height: 1;
        }

        .btn-brand-gradient {
            background: var(--brand-gradient);
            color: white !important;
            border: none;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 0.8rem 1.5rem;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            box-shadow: 0 4px 12px rgba(14, 43, 88, 0.2);
        }

        .btn-brand-gradient:hover {
            transform: translateY(-4px); /* Vertical Lift */
            box-shadow: 0 8px 20px rgba(14, 43, 88, 0.35);
            filter: brightness(1.1);
        }

        .btn-brand-gradient:active {
            transform: translateY(-1px); /* Pressed effect */
        }

        /* Icon specific animation */
        .btn-brand-gradient i {
            transition: transform 0.3s ease;
        }

        .btn-brand-gradient:hover i {
            transform: scale(1.2) rotate(-5deg); /* Slight pop for the icon */
        }

        .copy-btn-utility {
            font-size: 0.7rem;
            font-weight: 700;
            color: #64748b;
            text-decoration: none;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 4px 8px;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
            transition: all 0.2s ease;
            cursor: pointer !important; /* Forces the hand cursor */
            position: relative;
            user-select: none;
        }

        .copy-btn-utility:hover {
            background: #e2e8f0;
            color: var(--brand-blue);
        }

        .copy-toast {
            position: fixed;
            bottom: 20px;
            left: 50%;
            transform: translateX(-50%);
            background: #0E2B58;
            color: white;
            padding: 10px 20px;
            border-radius: 30px;
            font-size: 0.8rem;
            font-weight: 700;
            z-index: 9999;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            animation: slideUpFade 0.3s ease-out;
        }

        .copy-btn-utility.disabled-link {
            opacity: 0.5;
            pointer-events: none;
            cursor: default;
        }

        @keyframes slideUpFade {
            from {
                opacity: 0;
                transform: translate(-50%, 10px);
            }
            to {
                opacity: 1;
                transform: translate(-50%, 0);
            }
        }

        .grade-badge-modal {
            background: rgba(255, 255, 255, 0.2);
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 0.9rem;
            font-weight: 800;
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
                        <%
                            java.time.LocalDate lastDate = null;
                            if (chatHistory != null && !chatHistory.isEmpty()) {
                                for (MessageDto msg : chatHistory) {
                                    // LOGIC CHECK: We compare objects using equals()
                                    boolean isMe = msg.getSenderId().equals(userId);

                                    java.time.LocalDate msgDate = msg.getTimeSent().toLocalDate();

                                    // Date Separator
                                    if (lastDate == null || !msgDate.equals(lastDate)) { %>
                        <div class="chat-date-separator w-100 mb-3">
                            <span><%= msgDate.equals(java.time.LocalDate.now()) ? "Today" : msgDate.toString() %></span>
                        </div>
                        <% lastDate = msgDate;
                        }

                            boolean isSenderStudent = "Student".equals(msg.getSenderRole());
                            // Clean currentSenderName for Avatar service
                            String imgClass = isSenderStudent ? "rounded-circle" : "rounded-3 bg-white p-1";

                            String studentFallback = "https://ui-avatars.com/api/?name=" + msg.getSenderFullName().replace(" ", "+") + "&background=0E2B58&color=fff";
                            String companyFallback = "https://ui-avatars.com/api/?name=" + msg.getSenderFullName().replace(" ", "+") + "&background=F8F9FA&color=0E2B58";

                            String activeFallback = isSenderStudent ? studentFallback : companyFallback;

                            // FORCE ALIGNMENT based on isMe
                            String justifyStyle = isMe ? "justify-content: flex-end;" : "justify-content: flex-start;";
                        %>

                        <%-- ROW CONTAINER: 100% Width + Justify Content --%>
                        <div class="message-row" style="<%= justifyStyle %>">

                            <%-- LEFT SIDE (THEM): Image First --%>
                            <% if (!isMe) { %>
                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= msg.getInfoId() %>&targetRole=<%= msg.getSenderRole() %>"
                                 onerror="this.src='<%= activeFallback %>';"
                                 class="chat-pfp <%= imgClass %> me-2 border shadow-sm"
                                 style="width: 38px; height: 38px; object-fit: cover;">
                            <% } %>

                            <%-- MESSAGE BUBBLE --%>
                            <div class="bubble <%= isMe ? "bubble-out" : "bubble-in" %>" style="max-width: 70%;">
                                <% if (!isMe) { %>
                                <div class="fw-bold mb-1 text-primary"
                                     style="font-size: 0.7rem; text-transform: uppercase;">
                                    <%= msg.getSenderName() %>
                                </div>
                                <% } %>

                                <div class="message-text"><%= msg.getMessageText() %>
                                </div>

                                <div class="d-flex justify-content-between align-items-end mt-1">
                                    <small style="font-size: 0.5rem; color: red; display: none;">
                                        Me:<%= userId %> vs Sender:<%= msg.getInfoId() %>
                                    </small>

                                    <div class="opacity-50 ms-auto" style="font-size: 0.65rem; font-weight: 700;">
                                        <%= msg.getTimeSent().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm")) %>
                                    </div>
                                </div>
                            </div>

                            <%-- RIGHT SIDE (ME): Image Last --%>
                            <% if (isMe) { %>
                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= msg.getInfoId() %>&targetRole=<%= msg.getSenderRole() %>"
                                 onerror="this.src='<%= activeFallback %>';"
                                 class="chat-pfp <%= imgClass %> ms-2 border shadow-sm"
                                 style="width: 38px; height: 38px; object-fit: cover;">
                            <% } %>

                        </div>
                        <% }
                        } else { %>
                        <div class="m-auto text-center opacity-25">
                            <i class="fa-regular fa-comments fa-4x mb-3"></i>
                            <p class="fw-bold">No messages yet.</p>
                        </div>
                        <% } %>

                        <% if ("Student".equals(role) && "Request".equals(activeApp.getStatus())) { %>
                        <div class="mx-5 mb-4 p-3 bg-primary-subtle border border-primary-subtle rounded-3 text-center shadow-sm">
                            <i class="fa-solid fa-circle-info text-primary me-2"></i>
                            <span class="small fw-bold text-primary-emphasis">
                                An interview has been requested! Please go to your <strong>Applications in Dashboard</strong> to review and accept the invitation.
                            </span>
                        </div>
                        <% } %>
                    </div>

                    <div class="chat-input-wrapper">
                        <% if (!canChat) { %>
                        <div class="alert alert-secondary mb-0 py-2 text-center small border-0"
                             style="background-color: #e9ecef; color: #4a4a4a; font-weight: 600;">
                            <i class="fa-solid fa-lock me-2"></i>Closed. Messaging disabled.
                        </div>
                        <% } else { %>
                        <form action="SendMessage" method="POST" class="d-flex gap-3 align-items-center">
                            <input type="hidden" name="appId" value="<%= activeApp.getId() %>">
                            <div class="flex-grow-1 position-relative">
                                <input type="text" name="message"
                                       class="form-control form-control-chat shadow-sm py-3 px-4"
                                       placeholder="Write your message here..." required autocomplete="off"
                                       style="border-radius: 15px; border: 1px solid #e2e8f0;">
                            </div>
                            <button type="submit" id="sendBtn" class="btn btn-send-gradient rounded-4 shadow-sm"
                                    style="width: 55px; height: 55px; border-radius: 18px !important;">
                                <i class="fa-solid fa-paper-plane fs-5"></i>
                            </button>
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
                            <div class="mb-4 text-center">
                                <a href="${pageContext.request.contextPath}/StudentProfile?id=<%= activeApp.getStudentId() %>"
                                   class="profile-link-refined">
                                    <i class="fa-solid fa-user-graduate me-2"></i>View Student Profile
                                </a>
                            </div>
                            <% } else { %>
                            <div class="mb-4 text-center">
                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= activeApp.getCompanyId() %>"
                                   class="profile-link-refined">
                                    <i class="fa-solid fa-building me-2"></i>View Company Profile
                                </a>
                            </div>

                            <% } %>

                            <%-- Targeted Area: Grade Container with Gradient Header --%>
                            <% if (isHired) { %>
                            <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="border-radius: 12px;">
                                <div class="grading-card-header d-flex justify-content-between align-items-center">
                                    <h6><i class="fa-solid fa-graduation-cap me-2"></i>Internship Grade</h6>
                                    <span class="status-badge status-<%= activeApp.getStatus().toLowerCase() %>"><%= activeApp.getStatus() %></span>
                                </div>
                                <div class="card-body py-5 text-center border border-top-0 highlight-box"
                                     style="border-color: #eef2f5 !important; border-radius: 0 0 12px 12px;">
                                    <% if ("Student".equals(role) || activeApp.getGrade() != null) { %>
                                    <div class="d-inline-flex align-items-baseline gap-2">
                                        <% if (activeApp.getGrade() != null) { %>
                                        <span class="grade-display-large"><%= activeApp.getGrade() %></span>
                                        <% } else { %>
                                        <span class="grade-display-large grade-placeholder"
                                              title="Grade not yet assigned">?</span>
                                        <% } %>
                                        <span class="h4 m-0 text-muted opacity-50">/ 10</span>
                                    </div>

                                    <% if (activeApp.getFeedback() != null && !activeApp.getFeedback().trim().isEmpty()) { %>
                                    <div class="mt-4">
                                        <a href="" class="profile-link-refined w-100" data-bs-toggle="modal"
                                           data-bs-target="#viewFeedbackModal">
                                            <i class="fa-solid fa-comment-dots me-2"></i>View Internship Feedback
                                        </a>
                                    </div>
                                    <% } else { %>
                                    <p class="text-muted small mt-3 mb-0 italic">Feedback will appear here once
                                        finalized.</p>
                                    <% } %>

                                    <% } else { %>
                                    <div class="grade-input-group d-inline-flex align-items-center gap-2 p-2 px-3"
                                         style="background: #f8fafc; border-radius: 15px;">
                                        <input type="number" id="sidebarGradeInput" name="grade_display" step="0.1"
                                               min="0" max="10"
                                               class="grade-number" placeholder="--"
                                               value="<%= activeApp.getGrade() != null ? activeApp.getGrade() : "" %>"
                                               required>
                                        <span class="h3 m-0 text-muted opacity-50">/ 10</span>
                                    </div>

                                    <div class="mt-4 d-grid gap-2">
                                        <div class="mt-4 d-grid gap-2">
                                            <button type="button" class="btn btn-brand-gradient btn-sm py-2 shadow-sm"
                                                    onclick="openEvaluationModal()">
                                                <i class="fa-solid fa-pen-to-square me-2"></i>WRITE EVALUATION
                                            </button>
                                            <div id="gradeValidationMessage"
                                                 class="text-danger small mt-1 fw-bold d-none">
                                                <i class="fa-solid fa-circle-exclamation me-1"></i>Please set a grade
                                                before evaluating.
                                            </div>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } else if ("Rejected".equals(activeApp.getStatus())) { %>

                            <%-- SHARED VIEW: Rejected Status for BOTH Student and Company --%>
                            <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="border-radius: 12px;">
                                <div class="grading-card-header d-flex justify-content-between align-items-center"
                                     style="background: #64748b !important;">
                                    <h6 class="m-0"><i class="fa-solid fa-folder-closed me-2"></i>Application Closed
                                    </h6>
                                    <span class="status-badge status-rejected">Rejected</span>
                                </div>
                                <div class="card-body p-4 border border-top-0 highlight-box text-center"
                                     style="border-color: #eef2f5 !important; border-radius: 0 0 12px 12px;">
                                    <div class="mb-3 opacity-50">
                                        <i class="fa-solid fa-circle-xmark fa-3x text-danger"></i>
                                    </div>
                                    <p class="text-dark fw-bold mb-1">Process Terminated</p>
                                    <p class="text-muted small">This application has been moved to the archives. No
                                        further actions can be taken at this time.</p>
                                </div>
                            </div>
                            <% } else if ("Student".equals(role)) { %>
                            <% if ("Request".equals(activeApp.getStatus())) { %>
                            <%-- PERSONALIZED Request STUDENT TAB --%>
                            <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="border-radius: 12px;">
                                <div class="grading-card-header d-flex justify-content-between align-items-center">
                                    <h6 class="m-0"><i class="fa-solid fa-calendar-plus me-2"></i>Action Needed</h6>
                                    <span class="status-badge status-request">Request</span>
                                </div>
                                <div class="card-body p-4 border border-top-0 highlight-box"
                                     style="border-color: #eef2f5 !important; border-radius: 0 0 12px 12px;">
                                    <div class="text-center mb-3">
                                        <div class="bg-white p-3 d-inline-block rounded-circle shadow-sm mb-3">
                                            <i class="fa-solid fa-bell-concierge fa-2x text-primary"></i>
                                        </div>
                                        <h6 class="fw-bold text-dark">Invitation Received</h6>
                                        <p class="text-muted small">
                                            <%= partnerName %> wants to schedule an interview with you!
                                        </p>
                                    </div>

                                    <div class="alert alert-warning border-0 small mb-0">
                                        <i class="fa-solid fa-arrow-right-to-bracket me-2"></i>
                                        To accept this request and start the discussion, please visit your <strong>Main
                                        Dashboard</strong> and look for this application in My Applications
                                        section.
                                    </div>

                                    <div class="mt-4 d-grid">
                                        <a href="${pageContext.request.contextPath}/StudentDashboard"
                                           class="btn btn-brand-gradient btn-sm py-2">
                                            <i class="fa-solid fa-gauge-high me-2"></i>GO TO DASHBOARD
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <% } else if ("Discussion".equals(activeApp.getStatus()) || "Interview".equals(activeApp.getStatus())) { %>
                            <%-- NEW: Student View for Active Applications (Discussion/Interview) --%>
                            <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="border-radius: 12px;">
                                <div class="grading-card-header d-flex justify-content-between align-items-center">
                                    <h6 class="m-0"><i class="fa-solid fa-calendar-day me-2"></i>Interview Schedule</h6>
                                    <span class="status-badge status-<%= activeApp.getStatus().toLowerCase() %>">
                                        <%= activeApp.getStatus() %>
                                    </span>
                                </div>

                                <div class="card-body p-4 border border-top-0 highlight-box"
                                     style="border-color: #eef2f5 !important; border-radius: 0 0 12px 12px;">

                                    <div class="mb-4 pb-3 border-bottom">
                                        <label class="form-label-custom d-block mb-2">Scheduled Date & Time</label>
                                        <div class="d-flex align-items-center gap-2 text-dark fw-bold">
                                            <i class="fa-regular fa-clock text-primary"></i>
                                            <%= (activeApp.getInterview() != null) ? activeApp.getInterview().toString().replace("T", " ") : "Not yet scheduled" %>
                                        </div>
                                    </div>

                                    <div>
                                        <label class="form-label-custom d-block mb-2">Location / Meeting Link</label>
                                        <div class="d-flex align-items-center gap-2 text-dark fw-bold">
                                            <i class="fa-solid fa-location-dot text-primary"></i>
                                            <%= (activeApp.getInterviewLocation() != null && !activeApp.getInterviewLocation().isEmpty()) ? activeApp.getInterviewLocation() : "To be specified by recruiter" %>
                                        </div>
                                    </div>

                                    <% if ("Discussion".equals(activeApp.getStatus())) { %>
                                    <div class="mt-4 p-3 bg-white rounded-3 border small text-muted italic">
                                        <i class="fa-solid fa-circle-info me-2 text-info"></i>Once the recruiter
                                        proposes a time, it will appear here. Keep an eye on the chat!
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>
                            <% } else if ("Request".equals(activeApp.getStatus())) { %>
                            <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="border-radius: 12px;">
                                <div class="grading-card-header d-flex justify-content-between align-items-center">
                                    <h6 class="m-0"><i class="fa-solid fa-hourglass-half me-2"></i>Awaiting Student</h6>
                                    <span class="status-badge status-request">Request</span>
                                </div>
                                <div class="card-body p-4 border border-top-0 highlight-box text-center"
                                     style="border-color: #eef2f5 !important; border-radius: 0 0 12px 12px;">
                                    <div class="mb-3 text-primary opacity-75">
                                        <i class="fa-solid fa-paper-plane fa-3x"></i>
                                    </div>
                                    <p class="text-muted small px-3">
                                        This interview was requested by you. Management options will become available
                                        once the student accepts the discussion.
                                    </p>
                                </div>
                            </div>
                            <% } else { %>
                            <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="border-radius: 12px;">
                                <%-- Header with Blue Gradient --%>
                                <div class="grading-card-header d-flex justify-content-between align-items-center">
                                    <h6 class="m-0"><i class="fa-solid fa-gears me-2"></i>Management</h6>
                                    <span class="status-badge status-<%= activeApp.getStatus().toLowerCase() %>">
                                        <%= activeApp.getStatus() %>
                                    </span>
                                </div>

                                <%-- Body with Gray Background (#f2f4f7) --%>
                                <div class="card-body p-4 border border-top-0 highlight-box"
                                     style="border-color: #eef2f5 !important; border-radius: 0 0 12px 12px;">
                                    <div id="formErrorAlert" class="alert alert-danger d-none border-0 small mb-3 py-2">
                                        <i class="fa-solid fa-circle-exclamation me-2"></i> <span>Please fill all required fields.</span>
                                    </div>

                                    <form id="managementForm" action="InternshipApplications" method="POST"
                                          onsubmit="return validateManagementForm(this)">
                                        <input type="hidden" name="action" value="updateStatus">
                                        <input type="hidden" name="id" value="<%= activeApp.getId() %>">

                                        <div class="mb-3">
                                            <label class="form-label-custom">Interview Date</label>
                                            <input type="datetime-local"
                                                   name="interviewDate"
                                                   id="dateInput"
                                                   class="form-control"
                                                   style="background-color: white;"
                                                   min="<%= java.time.LocalDate.now().plusDays(1).toString() %>T00:00"
                                                   max="<%= interviewMaxDate %>T23:59"
                                                   data-interview-max="<%= interviewMaxDate %>"
                                                   value="<%= (activeApp.getInterview() != null) ? activeApp.getInterview().toString() : "" %>">

                                            <div class="invalid-feedback-custom" id="dateFeedback">
                                                Interviews must be scheduled for tomorrow or later, up until the period cutoff.
                                            </div>
                                        </div>

                                        <div class="mb-3">
                                            <label class="form-label-custom">Location</label>
                                            <input type="text" name="location" id="locInput" class="form-control"
                                                   style="background-color: white;"
                                                   value="<%= (activeApp.getInterviewLocation() != null) ? activeApp.getInterviewLocation() : "" %>"
                                                   placeholder="Not yet specified">
                                            <div class="invalid-feedback-custom" id="locFeedback">A location is required
                                                for interviews.
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
                                                <% if ("Interview".equals(activeApp.getStatus())) { %>
                                                <option value="Accepted" <%= !interviewHasPassed ? "disabled" : "" %> <%= "Accepted".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                    Accepted <%= !interviewHasPassed ? "(Locked)" : "" %>
                                                </option>
                                                <% } %>
                                                <option value="Rejected" <%= "Rejected".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                    Rejected
                                                </option>
                                            </select>
                                        </div>

                                        <button type="button" onclick="handleManagementUpdate()"
                                                class="btn btn-update-status w-100 shadow-sm">
                                            <i class="fa-solid fa-rotate me-2"></i> Update Application
                                        </button>
                                    </form>
                                </div>
                            </div>

                            <div class="modal fade" id="decisionModal" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-sm">
                                    <div class="modal-content border-0 shadow-lg">
                                        <div class="modal-header border-0 pb-0 justify-content-center pt-4">
                                            <div class="position-relative">
                                                <img id="modalStudentImg" src=""
                                                     class="rounded-circle border shadow-sm"
                                                     style="width: 80px; height: 80px; object-fit: cover;">
                                                <div id="modalIconBadge"
                                                     class="position-absolute bottom-0 end-0 rounded-circle d-flex align-items-center justify-content-center shadow-sm"
                                                     style="width: 30px; height: 30px; border: 2px solid white;">
                                                    <i id="modalIcon" class="fa-solid fa-sm text-white"></i>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-body text-center p-4">
                                            <h5 id="modalTitle" class="fw-bold mb-2">Title</h5>
                                            <div class="modal-body text-center p-4">
                                                <p class="text-muted small mb-0">
                                                    Are you sure you want to <span id="modalActionText">action</span>
                                                    <strong id="modalStudentName"></strong>
                                                    for the <strong id="modalPositionTitle" class="text-dark"></strong>
                                                    position?
                                                </p>
                                            </div>
                                        </div>
                                        <div class="modal-footer border-0 p-3 pt-0">
                                            <button type="button" class="btn btn-light btn-sm flex-fill fw-bold"
                                                    data-bs-dismiss="modal">Cancel
                                            </button>
                                            <a href="#" id="modalConfirmBtn" class="btn btn-sm flex-fill fw-bold">Confirm</a>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<% if (isHired) { %>
<%-- A. RECRUITER MODAL: Write Feedback --%>
<% if (!"Student".equals(role) && activeApp.getGrade() == null) { %>
<div class="modal fade" id="evaluationModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header grading-card-header">
                <h5 class="modal-title fw-bold m-0"><i class="fa-solid fa-file-signature me-2"></i>Internship Evaluation
                </h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form action="InternshipApplications" method="POST" id="gradingForm" onsubmit="syncGrade()">
                <input type="hidden" name="action" value="gradeInternship">
                <input type="hidden" name="id" value="<%= activeApp.getId() %>">
                <input type="hidden" name="grade" id="hiddenModalGrade">

                <div class="modal-body p-4 bg-light">
                    <div class="row g-3 mb-4">
                        <div class="col-md-7">
                            <div class="d-flex align-items-center gap-3 p-3 bg-white rounded-3 shadow-sm border h-100">
                                <div class="text-center">
                                    <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= activeApp.getStudentId() %>&targetRole=Student"
                                         onerror="this.src='https://ui-avatars.com/api/?name=<%= activeApp.getStudentName() %>&background=0E2B58&color=fff';"
                                         class="rounded-circle border shadow-sm mb-2"
                                         style="width: 65px; height: 65px; object-fit: cover;">
                                    <div class="badge bg-primary-subtle text-primary border border-primary-subtle d-block small"
                                         style="font-size: 0.6rem;">EVALUATE STUDENT
                                    </div>
                                </div>
                                <div>
                                    <h5 class="fw-bold mb-0 text-dark"><%= activeApp.getStudentName() %>
                                    </h5>
                                    <p class="text-muted small mb-0">Internal academic record review</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-5">
                            <div class="d-flex flex-column justify-content-center align-items-center p-3 bg-white rounded-3 shadow-sm border h-100">
                                <span class="text-muted small fw-bold text-uppercase mb-1" style="letter-spacing: 1px;">Selected Grade</span>
                                <div class="d-flex align-items-baseline gap-1">
                                    <span id="modalGradeDisplay"
                                          class="display-6 fw-bold text-primary"><%= activeApp.getGrade() != null ? activeApp.getGrade() : "--" %></span>
                                    <span class="h4 text-muted opacity-50">/ 10</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <label class="form-label-custom m-0">Qualitative Feedback</label>
                        <a onclick="copyFeedback('evalTextarea')" class="copy-btn-utility">
                            <i class="fa-regular fa-copy me-1"></i>Copy Text
                        </a>
                    </div>
                    <textarea id="evalTextarea" name="feedback" class="form-control feedback-area"
                              placeholder="Describe in detail how the student performed..."
                              style="min-height: 250px; height: 250px !important;"><%= activeApp.getFeedback() != null ? activeApp.getFeedback() : "" %></textarea>
                </div>
                <div class="modal-footer bg-white border-top p-4">
                    <button type="submit" class="btn btn-brand-gradient w-100">
                        <i class="fa-solid fa-cloud-arrow-up"></i> Finalize Evaluation & Complete
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<%-- B. View Feedback --%>
<% if ("Student".equals(role) || activeApp.getGrade() != null) { %>
<div class="modal fade" id="viewFeedbackModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header grading-card-header">
                <h5 class="modal-title fw-bold m-0"><i class="fa-solid fa-quote-left me-2"></i>Internship Feedback</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-4 bg-light">
                <div class="row g-3 mb-4">
                    <div class="col-md-7">
                        <%-- Logic: If I am a Student, show Company. Otherwise, show Student. --%>
                        <%
                            boolean isUserStudent = "Student".equals(role);
                            Long targetId = isUserStudent ? activeApp.getCompanyId() : activeApp.getStudentId();
                            String targetRole = isUserStudent ? "Company" : "Student";
                            String targetName = isUserStudent ? activeApp.getCompanyName() : activeApp.getStudentName();
                            String subText = isUserStudent ? "Company Reviewer" : "Evaluated Intern";

                            // UI Logic: Companies get square logos, Students get circular PFPs
                            String imgClass = isUserStudent ? "rounded-3 bg-white p-1" : "rounded-circle";
                            String imgFit = isUserStudent ? "contain" : "cover";
                        %>
                        <div class="d-flex align-items-center gap-3 p-3 bg-white rounded-3 shadow-sm border-start border-primary border-4 h-100">
                            <%
                                // Logic to determine fallback colors based on the targetRole defined earlier in this block
                                String fbColors = "Student".equals(targetRole)
                                        ? "&background=0E2B58&color=fff"
                                        : "&background=F8F9FA&color=0E2B58";
                                String finalFallback = "https://ui-avatars.com/api/?name=" + targetName.replace(" ", "+") + fbColors;
                            %>
                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= targetId %>&targetRole=<%= targetRole %>"
                                 onerror="this.src='<%= finalFallback %>';"
                                 class="<%= imgClass %> border shadow-sm"
                                 style="width: 65px; height: 65px; object-fit: <%= imgFit %>; padding: 5px;">
                            <div>
                                <h6 class="fw-bold mb-0 text-dark"><%= targetName %>
                                </h6>
                                <div class="badge bg-primary-subtle text-primary small"><%= subText %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-5">
                        <div class="d-flex flex-column justify-content-center align-items-center p-3 bg-white rounded-3 shadow-sm border h-100">
                            <span class="text-muted small fw-bold text-uppercase mb-1" style="letter-spacing: 1px;">Final Grade</span>
                            <div class="d-flex align-items-baseline gap-1">
                                <span class="display-6 fw-bold text-success"><%= activeApp.getGrade() %></span>
                                <span class="h4 text-muted opacity-50">/ 10</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-end mb-2">
                    <a onclick="copyFeedback('feedbackDisplay')" class="copy-btn-utility">
                        <i class="fa-regular fa-copy me-1"></i>Copy Feedback
                    </a>
                </div>
                <div id="feedbackDisplay" class="p-4 bg-white border rounded-3 shadow-sm"
                     style="min-height: 250px; white-space: pre-wrap; line-height: 1.8; color: #334155;"><%=(activeApp.getFeedback() != null) ? activeApp.getFeedback().trim() : "No qualitative feedback provided."%>
                </div>
            </div>
            <div class="modal-footer bg-white border-0">
                <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
<% } %>
<% } %>

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

        scrollToLatestMessage();
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

        if (newStatus === 'Interview') {
            const selectedDate = new Date(dateInput.value);
            const minDate = new Date(dateInput.getAttribute('min'));
            const maxDate = new Date(dateInput.getAttribute('max'));

            if (selectedDate < minDate) {
                dateInput.classList.add('is-invalid');
                const dFeed = document.getElementById('dateFeedback');
                dFeed.innerText = "Interviews must be scheduled at least 1 day in advance.";
                dFeed.style.display = 'block';
                return false;
            }

            if (dateInput.getAttribute('max') && selectedDate > maxDate) {
                dateInput.classList.add('is-invalid');
                const dFeed = document.getElementById('dateFeedback');
                dFeed.innerText = "This date is too close to the end of the application period.";
                dFeed.style.display = 'block';
                return false;
            }
        }

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
    (function () {
        const appId = <%= activeApp.getId() %>;
        // Construct the WebSocket URL (ws:// for http, wss:// for https)
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const wsUrl = protocol + "//" + window.location.host + "<%= request.getContextPath() %>/chat-socket/" + appId;

        const chatSocket = new WebSocket(wsUrl);

        chatSocket.onmessage = function (event) {
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
        chatSocket.onclose = function () {
            console.log("ChatSocket closed. Real-time updates disabled until refresh.");
        };
    })();
    <% } %>

    let isToastActive = false; // Global flag to prevent spam

    function copyFeedback(elementId) {
        const btn = event.currentTarget;
        const element = document.getElementById(elementId);
        if (!element) return;

        // 1. Prevent new toast if one is already visible
        if (isToastActive) return;

        let textToCopy = (element.tagName === "TEXTAREA") ? element.value : element.innerText;

        navigator.clipboard.writeText(textToCopy).then(() => {
            isToastActive = true;

            // 2. Create the popup
            const toast = document.createElement("div");
            toast.className = "copy-toast";
            toast.innerHTML = '<i class="fa-solid fa-check-circle me-2"></i>Content copied to clipboard!';
            document.body.appendChild(toast);

            if (btn) btn.classList.add('disabled-link');
            // 3. Cleanup logic
            setTimeout(() => {
                toast.style.opacity = "0";
                toast.style.transition = "opacity 0.5s ease";

                // Wait for fade animation to finish before allowing next toast
                setTimeout(() => {
                    toast.remove();
                    isToastActive = false;
                    if (btn) btn.classList.remove('disabled-link');
                }, 500);
            }, 2000);
        });
    }

    function openEvaluationModal() {
        const gradeInput = document.getElementById('sidebarGradeInput');
        const errorMsg = document.getElementById('gradeValidationMessage');

        // 1. Check if grade is empty or out of bounds
        if (!gradeInput.value || gradeInput.value < 0 || gradeInput.value > 10) {
            errorMsg.classList.remove('d-none');
            gradeInput.classList.add('is-invalid');
            return;
        }

        // 2. Hide error if valid
        errorMsg.classList.add('d-none');
        gradeInput.classList.remove('is-invalid');

        // 3. Update the text inside the modal header dynamically
        document.getElementById('modalGradeDisplay').innerText = gradeInput.value;

        // 4. Update the hidden input for form submission
        document.getElementById('hiddenModalGrade').value = gradeInput.value;

        // 5. Trigger Bootstrap Modal manually
        const myModal = new bootstrap.Modal(document.getElementById('evaluationModal'));
        myModal.show();
    }

    // Ensure the hidden grade is synced once more on final form submit
    function syncGrade() {
        const sidebarVal = document.getElementById('sidebarGradeInput').value;
        document.getElementById('hiddenModalGrade').value = sidebarVal;
    }

    document.querySelector('input[name="message"]').addEventListener('input', function () {
        const sendBtn = document.getElementById('sendBtn');
        if (this.value.trim().length > 0) {
            sendBtn.classList.add('visible');
        } else {
            sendBtn.classList.remove('visible');
        }
    });

    function scrollToLatestMessage() {
        const chatContainer = document.querySelector('.chat-messages');
        if (chatContainer) {
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }
    }

    function handleManagementUpdate() {
        const statusSelect = document.getElementById('statusSelect');
        const selectedStatus = statusSelect.value;
        const form = document.getElementById('managementForm');

        if (!form) {
            console.error("Management form not found!");
            return;
        }

        // 1. For Discussion or Interview: Submit standard POST
        if (selectedStatus === 'Discussion' || selectedStatus === 'Interview') {
            if (validateManagementForm(form)) {
                form.submit();
            }
            return;
        }

        // 2. For Accepted or Rejected: Trigger the modal
        if (selectedStatus === 'Accepted' || selectedStatus === 'Rejected') {
            const appId = "<%= activeApp != null ? activeApp.getId() : "" %>";
            const studentId = "<%= activeApp != null ? activeApp.getStudentId() : "" %>";
            const studentName = "<%= activeApp != null ? activeApp.getStudentName().replace("'", "\\'") : "" %>";
            const positionTitle = "<%= activeApp != null ? activeApp.getPositionTitle().replace("'", "\\'") : "" %>";

            if (!appId) {
                alert("Application data missing. Please refresh the page.");
                return;
            }

            confirmAction(appId, studentId, studentName, positionTitle, selectedStatus);
        }
    }

    function confirmAction(appId, studentId, studentName, positionTitle, status) {
        const isAccept = status === 'Accepted';
        const modalElement = document.getElementById('decisionModal');

        // UI Updates
        document.getElementById('modalStudentName').innerText = studentName;
        document.getElementById('modalPositionTitle').innerText = positionTitle;

        const actionText = document.getElementById('modalActionText');
        if (isAccept) {
            actionText.innerText = "accept";
            actionText.className = "fw-bold text-success";
        } else {
            actionText.innerText = "reject";
            actionText.className = "fw-bold text-danger";
        }

        const contextPath = '<%= request.getContextPath() %>';
        const pfpUrl = contextPath + "/ProfilePicture?id=" + studentId + "&targetRole=Student";
        const imgEl = document.getElementById('modalStudentImg');
        imgEl.src = pfpUrl;
        imgEl.onerror = function () {
            this.src = "https://ui-avatars.com/api/?name=" + studentName.replace(/ /g, '+') + "&background=0E2B58&color=fff";
        };

        const btn = document.getElementById('modalConfirmBtn');
        const badge = document.getElementById('modalIconBadge');
        const icon = document.getElementById('modalIcon');

        if (isAccept) {
            document.getElementById('modalTitle').innerText = "Accept Student?";
            btn.className = "btn btn-success btn-sm flex-fill fw-bold";
            btn.innerText = "Accept & Hire";
            badge.style.backgroundColor = "#198754";
            icon.className = "fa-solid fa-check text-white";
        } else {
            document.getElementById('modalTitle').innerText = "Reject Candidate?";
            btn.className = "btn btn-danger btn-sm flex-fill fw-bold";
            btn.innerText = "Confirm Rejection";
            badge.style.backgroundColor = "#dc3545";
            icon.className = "fa-solid fa-xmark text-white";
        }

        btn.removeAttribute('href'); // Force it not to act as a link
        btn.onclick = function (e) {
            e.preventDefault();
            const form = document.getElementById('managementForm');
            // Manually set the status in the main form before submitting
            document.getElementById('statusSelect').value = status;
            form.submit();
        };

        const modalInstance = new bootstrap.Modal(modalElement);
        modalInstance.show();
    }
</script>
</body>
</html>