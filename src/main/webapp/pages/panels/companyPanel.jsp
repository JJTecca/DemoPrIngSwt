<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.*" %>
<%
    // 1. Retrieve Data
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");
    UserAccountDto userAccount = (UserAccountDto) request.getAttribute("userAccount");
    List<InternshipPositionDto> myPositions = (List<InternshipPositionDto>) request.getAttribute("myPositions");
    List<InternshipApplicationDto> applications = (List<InternshipApplicationDto>) request.getAttribute("applications");

    if (company == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }

    // --- Profile Completion Calculation ---
    int completionScore = 0;
    if (company.getName() != null && !company.getName().trim().isEmpty()) completionScore += 20;
    if (company.getWebsite() != null && !company.getWebsite().trim().isEmpty() && !company.getWebsite().equals("N/A"))
        completionScore += 20;
    if (company.getCompDescription() != null && !company.getCompDescription().trim().isEmpty()) completionScore += 20;
    if (company.getBiography() != null && !company.getBiography().trim().isEmpty()) completionScore += 20;
    if (company.hasProfilePic()) completionScore += 20;

    String completionText = "Needs Attention";
    String completionBarClass = "bg-danger";
    String completionTextColor = "text-danger";

    if (completionScore == 100) {
        completionText = "Complete";
        completionBarClass = "bg-success";
        completionTextColor = "text-success";
    } else if (completionScore > 75) {
        completionText = "Excellent";
        completionBarClass = "bg-success";
        completionTextColor = "text-success";
    } else if (completionScore >= 50) {
        completionText = "Good";
        completionBarClass = "bg-warning";
        completionTextColor = "text-warning";
    }

    int activePositionsCount = (myPositions != null) ? myPositions.size() : 0;
    int totalAppsCount = (applications != null) ? applications.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Company Dashboard - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        /* --- Layout & Stats --- */
        .stat-card {
            background: white;
            border: none;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s;
            overflow: hidden;
            position: relative;
            height: 100%;
            padding: 1.5rem;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
        }

        .card-blue::before {
            background-color: var(--brand-blue);
        }

        .card-teal::before {
            background-color: #008080;
        }

        .card-red::before {
            background-color: var(--ulbs-red);
        }

        .stat-value {
            font-size: 1.8rem;
            font-weight: 800;
            color: var(--brand-blue-dark);
            margin-bottom: 0;
        }

        .stat-label {
            color: #888;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }

        .stat-icon {
            position: absolute;
            right: 20px;
            bottom: 20px;
            font-size: 2.5rem;
            opacity: 0.15;
            color: black;
            pointer-events: none;
        }

        /* --- Header Fixes --- */
        .header-stat::after {
            pointer-events: none;
            z-index: 1;
        }

        .header-stat .col-md-3 {
            position: relative;
            z-index: 10;
        }

        /* --- Profile Overview Styling --- */
        .info-label {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #999;
            font-weight: 700;
            display: block;
            margin-bottom: 2px;
        }

        .info-value {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--brand-blue-dark);
        }

        .profile-action-zone {
            background-color: #f8f9fa;
            border-left: 1px solid #eee;
        }

        /* --- Lists & Tables --- */
        .applications-scroll-area {
            max-height: 810px; /* Balanced height for the dashboard */
            overflow: visible !important;
            position: relative;
        }

        .scrollable-list {
            max-height: 400px;
            overflow-y: auto;
            border-bottom-left-radius: 8px;
            border-bottom-right-radius: 8px;
        }

        .position-item {
            padding: 1rem;
            border-bottom: 1px solid #f0f0f0;
            transition: 0.2s;
        }

        .position-item:hover {
            background-color: #fafafa;
        }

        .position-title {
            font-weight: 600;
            color: var(--brand-blue-dark);
            display: block;
            font-size: 0.95rem;
        }

        .position-meta {
            font-size: 0.8rem;
            color: #777;
        }

        .btn-outline-primary.rounded-pill {
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            border-width: 1.5px;
            font-weight: 600;
        }

        .btn-outline-primary.rounded-pill:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(13, 110, 253, 0.15) !important;
            background-color: var(--brand-blue);
            color: white;
        }

        .btn-outline-primary.rounded-pill:hover i {
            transform: scale(1.1);
            transition: transform 0.2s ease;
        }

        /* Restored Chat Button Style */
        .btn-chat {
            background-color: #e3f2fd;
            color: #0d47a1;
            border: 1px solid #bbdefb;
            font-size: 0.85rem;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
        }

        .btn-chat:hover {
            background-color: #0d47a1;
            color: white;
            border-color: #0d47a1;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(13, 110, 253, 0.2);
        }

        .btn-chat:hover i {
            transform: scale(1.1);
            transition: transform 0.2s ease;
        }

        .btn-action {
            text-align: left;
            padding: 1rem;
            border: 1px solid #eee;
            background: white;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            color: var(--brand-blue);
            font-weight: 600;
            text-decoration: none;
            display: block;
            width: 100%;
        }

        .btn-action:hover {
            background: var(--brand-blue);
            color: white !important;
            transform: translateX(5px);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .student-avatar-small {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid #eee;
        }

        .student-link {
            text-decoration: none;
            color: inherit;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            transition: color 0.2s;
        }

        .student-link:hover {
            color: var(--brand-blue);
        }

        .card-header .btn-primary:hover {
            background-color: var(--brand-blue-dark) !important;
            transform: scale(1.1);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }

        .btn-manage-eye {
            background-color: #f8f9fa;
            color: #6c757d;
            border: 1px solid #e9ecef;
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: 0.2s;
            border-radius: 50%; /* Ensuring it's a perfect circle */
        }

        .btn-manage-eye:hover {
            background-color: var(--brand-blue);
            color: white;
            transform: scale(1.1);
        }

        .applicant-scroll {
            max-height: 350px;
            overflow-y: auto;
        }

        .applicant-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
            border-radius: 8px;
        }

        .applicant-item:hover {
            background-color: #f8f9fa;
        }

        .applicant-pfp {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid #ddd;
        }

        /* Ensure the badge inside the modal matches the small style */
        .x-small {
            font-size: 0.65rem;
        }

        /* --- High Contrast Application Status Badges --- */
        .status-badge {
            font-size: 0.72rem;
            padding: 0.4em 0.9em;
            border-radius: 50px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
            border-width: 1px;
            border-style: solid;
        }

        /* Discussion: Deep Purple / Lavender */
        .status-discussion {
            background-color: #f3e5f5 !important;
            color: #6a1b9a !important;
            border-color: #e1bee7 !important;
        }

        /* Request: Royal Indigo (Company Led) */
        .status-request {
            background-color: #e8eaf6 !important;
            color: #283593 !important;
            border-color: #c5cae9 !important;
        }

        /* Pending: Warning Yellow */
        .status-pending {
            background-color: #fff3cd !important;
            color: #856404 !important;
            border-color: #ffeeba !important;
        }

        /* Interview: Info Blue (Cyan) */
        .status-interview {
            background-color: #e0f7fa !important;
            color: #006064 !important;
            border-color: #b2ebf2 !important;
        }

        /* Accepted: Success Green */
        .status-accepted {
            background-color: #d1e7dd !important;
            color: #0f5132 !important;
            border-color: #badbcc !important;
        }

        /* Rejected: Danger Red */
        .status-rejected {
            background-color: #f8d7da !important;
            color: #842029 !important;
            border-color: #f5c2c7 !important;
        }

        /* Dropdown specific border overrides (Cleanup) */
        .status-pending, .status-interview, .status-accepted, .status-rejected, .status-discussion, .status-request {
            border-left-width: 1px !important; /* Reverts the 4px left-only border */
        }

        /* --- Position Status Badges --- */
        .pos-status-badge {
            font-size: 0.65rem;
            padding: 2px 8px;
            border-radius: 4px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
            margin-top: 4px;
        }

        /* Pending: Warning/Yellow (Waiting for Admin) */
        .pos-status-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }

        /* Open: Success/Green (Visible to Students) */
        .pos-status-open {
            background-color: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
        }

        /* Closed/Filled: Dark/Gray */
        .pos-status-closed {
            background-color: #e2e3e5;
            color: #41464b;
            border: 1px solid #d3d3d4;
        }

        /* Specific state for locked chat */
        .btn-chat.disabled {
            background-color: #f8f9fa;
            color: #adb5bd;
            border-color: #e9ecef;
            cursor: not-allowed;
            pointer-events: none;
        }

        /* --- High-Contrast Gradient Filter Button --- */
        #appFilterBtn {
            height: 38px;
            font-size: 0.85rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white !important;
            border: none;
            box-shadow: 0 4px 10px rgba(14, 43, 88, 0.2);
            transition: all 0.3s ease;
        }

        #appFilterBtn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(14, 43, 88, 0.3);
            filter: brightness(1.1);
        }

        /* --- Gradient Status Selectors --- */
        .status-dropdown-btn {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border: 1px solid #dee2e6;
            color: var(--brand-blue-dark);
            font-weight: 700;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        }

        .grade-internship {
            color: #0d6efd !important; /* Matches your brand blue or primary */
        }

        .grade-internship i.fa-star {
            color: #ffc107; /* Gold star */
        }

        .status-dropdown-btn:hover {
            background: white;
            border-color: var(--brand-blue);
            color: var(--brand-blue);
            transform: translateY(-1px);
        }

        /* Prevents the responsive table wrapper from clipping the dropdown menu */
        .table-responsive {
            overflow: visible !important;
            /* This prevents Bootstrap from forcing a scroll-container logic on the table */
            display: block;
        }

        .custom-card {
            overflow: visible !important;
        }

        /* Ensures table headers stay below the dropdown when scrolling */
        thead.sticky-top {
            z-index: 10 !important;
        }

        /* Forced elevation for the status dropdown to ensure it clears all other UI elements */
        .status-dropdown-btn + .dropdown-menu {
            z-index: 1070 !important;
            position: absolute;
        }

        .filter-active {
            background-color: var(--brand-blue) !important;
            color: white !important;
        }

        .main-content {
            overflow: visible !important;
        }

        /* Fixes both the App Filter and the Status Dropdowns */
        #appFilterBtn + .dropdown-menu {
            /* Ensure it is above the sticky header and other cards */
            z-index: 9999 !important;
            position: absolute;
        }

        /* Specifically for the filter at the top to prevent it hiding if header is small */
        .card-header {
            z-index: 20 !important;
            position: relative;
        }

        /* Sidebar Capacity Badge */
        .capacity-badge-sidebar {
            font-size: 0.65rem;
            background-color: #f8f9fa;
            color: #666;
            border: 1px solid #e9ecef;
            padding: 1px 6px;
            border-radius: 4px;
            font-weight: 700;
            margin-right: 8px;
        }

        .capacity-full-sidebar {
            background-color: #fff5f5;
            color: #e03131;
            border-color: #ffc9c9;
        }

        /* Modal Info Bar Fix */
        .modal-info-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
            flex-wrap: nowrap;
            gap: 10px;
        }

        .modal-info-item {
            white-space: nowrap;
            flex: 1;
            text-align: center;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <jsp:include page="../blocks/companySidebar.jsp"/>

        <div class="col-md-9 col-lg-10 main-content">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h1 class="h2 page-title">Welcome, <%= company.getName() %>!</h1>
                    <p class="text-muted mb-0"><i class="fa-solid fa-industry me-1"></i> Company Dashboard</p>
                </div>
                <div class="d-none d-md-block">
                    <span class="badge bg-light text-dark border">
                        <i class="fa-regular fa-clock me-1"></i> <%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date()) %>
                    </span>
                </div>
            </div>

            <div class="row mb-4 g-3">
                <div class="col-md-4">
                    <div class="stat-card card-blue"><h2 class="stat-value"><%= activePositionsCount %>
                    </h2><span class="stat-label">Active Positions</span><i class="fa-solid fa-briefcase stat-icon"></i>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card card-teal"><h2 class="stat-value"><%= totalAppsCount %>
                    </h2><span class="stat-label">Total Applications</span><i
                            class="fa-solid fa-file-contract stat-icon"></i></div>
                </div>
                <div class="col-md-4">
                    <% String activeChats = request.getAttribute("activeChats").toString();%>
                    <div class="stat-card card-red"><h2 class="stat-value"><%= activeChats %></h2><span
                            class="stat-label">Active Chats</span><i class="fa-regular fa-comment-dots stat-icon"></i>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card custom-card mb-4 border-0 shadow-sm overflow-hidden">
                        <div class="row g-0">
                            <div class="col-md-9 p-4">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div style="flex: 1;">
                                        <h5 class="fw-bold mb-1">Company Profile Overview</h5>
                                        <p class="text-muted small mb-0">
                                            <%= company.getCompDescription() != null ? company.getCompDescription() : "Complete your profile to attract more candidates." %>
                                        </p>
                                    </div>

                                    <div class="text-end ms-3">
                                        <div class="mb-1">
                                            <i class="fa-solid fa-circle-question text-muted small me-1"
                                               data-bs-toggle="tooltip"
                                               data-bs-placement="left"
                                               title="This number will be visible to accepted students in the chat header."></i>
                                            <span class="info-label d-inline">Phone Number</span>
                                        </div>

                                        <div class="d-flex align-items-center justify-content-end mb-1">
                                            <span class="info-value me-2">
                                                <%= (company.getPhoneNumber() != null && !company.getPhoneNumber().isEmpty()) ? company.getPhoneNumber() : "Not Set" %>
                                            </span>
                                            <a href="#" class="text-primary small text-decoration-none"
                                               data-bs-toggle="modal" data-bs-target="#editPhoneModal" title="Edit Phone">
                                                <i class="fa-solid fa-pen-to-square"></i>
                                            </a>
                                        </div>

                                        <div>
                                            <span class="badge bg-light text-muted border" style="font-size: 0.65rem;">
                                                <i class="fa-solid fa-lock me-1"></i>PRIVATE
                                            </span>
                                        </div>
                                    </div>
                                </div>

                                <div class="row g-3 mt-4">
                                    <div class="col-sm-4">
                                        <span class="info-label">Account</span>
                                        <span class="info-value text-truncate d-block"><%= userAccount.getEmail() %></span>
                                        <span class="badge bg-light text-muted border ms-1" style="font-size: 0.65rem; vertical-align: middle;">
                                            <i class="fa-solid fa-lock me-1"></i>Private
                                        </span>
                                    </div>
                                    <div class="col-sm-4">
                                        <span class="info-label">Contact</span>
                                        <span class="info-value text-truncate d-block">
                                            <%= (company.getContactEmail() != null && !company.getContactEmail().isEmpty()) ? company.getContactEmail() : "Not Set" %>
                                        </span>
                                    </div>
                                    <div class="col-sm-4">
                                        <span class="info-label">Website</span>
                                        <a href="<%= company.getWebsite() %>" target="_blank"
                                           class="info-value text-decoration-none text-primary d-block text-truncate">
                                            <%= company.getWebsite() != null ? company.getWebsite() : "Not Set" %>
                                        </a>
                                    </div>
                                </div>

                                <div class="mt-4">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <span class="small fw-bold text-muted">Profile Progress</span>
                                        <span class="small fw-bold <%= completionTextColor %>"><%= completionText %> (<%= completionScore %>%)</span>
                                    </div>
                                    <div class="progress" style="height: 8px; border-radius: 10px;">
                                        <div class="progress-bar <%= completionBarClass %>" style="width: <%= completionScore %>%"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-3 p-4 profile-action-zone d-flex flex-column align-items-center justify-content-center">
                                <div class="mb-3 opacity-25 d-none d-md-block"><i
                                        class="fa-solid fa-address-card fa-3x"></i></div>
                                <a href="${pageContext.request.contextPath}/CompanyProfile"
                                   class="btn btn-outline-primary btn-sm w-100 rounded-pill shadow-sm"><i
                                        class="fa-solid fa-pen-to-square me-1"></i> Edit Profile</a>
                            </div>
                        </div>
                    </div>

                    <div class="card custom-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span class="fw-bold"><i
                                    class="fa-solid fa-user-check me-2"></i> Received Applications</span>
                            <div class="d-flex align-items-center gap-2">
                                <div class="dropdown">
                                    <button id="appFilterBtn"
                                            class="btn btn-sm btn-outline-primary dropdown-toggle rounded-pill px-3"
                                            type="button" data-bs-toggle="dropdown">
                                        <i class="fa-solid fa-filter me-1"></i> Filter: <span id="currentFilterLabel">Hide Rejected</span>
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                                        <li><a class="dropdown-item filter-opt" data-filter="All" href="#">Show All</a>
                                        </li>
                                        <li><a class="dropdown-item filter-opt active" data-filter="HideRejected"
                                               href="#">Hide Rejected (Default)</a></li>
                                        <li>
                                            <hr class="dropdown-divider">
                                        </li>
                                        <li><a class="dropdown-item filter-opt" data-filter="Pending"
                                               href="#">Pending</a></li>
                                        <li><a class="dropdown-item filter-opt" data-filter="Discussion" href="#">Discussion</a>
                                        </li>
                                        <li><a class="dropdown-item filter-opt" data-filter="Interview" href="#">Interview</a>
                                        </li>
                                        <li><a class="dropdown-item filter-opt" data-filter="Accepted"
                                               href="#">Accepted</a></li>
                                        <li><a class="dropdown-item filter-opt" data-filter="Rejected" href="#">Rejected
                                            Only</a></li>
                                        <li><a class="dropdown-item filter-opt" data-filter="Request" href="#">Interview
                                            Requests</a></li>
                                    </ul>
                                </div>
                                <span class="badge bg-light text-primary border"><%= totalAppsCount %> Total</span>
                            </div>
                        </div>
                        <div class="card-body p-0">
                            <% if (applications != null && !applications.isEmpty()) { %>
                            <div class="applications-scroll-area">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-light sticky-top" style="z-index: 5; top: 0;">
                                        <tr>
                                            <th class="ps-4">Candidate</th>
                                            <th>Position</th>
                                            <th style="min-width: 150px;">
                                                <div class="dropdown">
                                                    <a class="text-decoration-none text-muted dropdown-toggle fw-bold small"
                                                       href="#" role="button" data-bs-toggle="dropdown">
                                                        <i class="fa-solid fa-graduation-cap me-1"></i> <span
                                                            id="gradeColumnLabel">Study Grade</span>
                                                    </a>
                                                    <ul class="dropdown-menu shadow border-0">
                                                        <li><a class="dropdown-item small toggle-grade"
                                                               data-type="study" href="#">Study Grade</a></li>
                                                        <li><a class="dropdown-item small toggle-grade"
                                                               data-type="internship" href="#">Internship Grade</a></li>
                                                    </ul>
                                                </div>
                                            </th>
                                            <th>Status</th>
                                            <th class="text-end pe-4">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <%
                                            for (InternshipApplicationDto app : applications) {
                                                String currentStatus = app.getStatus();
                                                boolean isRejected = "Rejected".equals(currentStatus);
                                                boolean isAccepted = "Accepted".equals(currentStatus);

                                                // Define Badge Colors for the Status Button
                                                String badgeClass = "status-pending";
                                                if (isAccepted) badgeClass = "status-accepted";
                                                else if ("Interview".equals(currentStatus))
                                                    badgeClass = "status-interview";
                                                else if ("Rejected".equals(currentStatus))
                                                    badgeClass = "status-rejected";
                                                else if ("Discussion".equals(currentStatus))
                                                    badgeClass = "status-discussion";
                                                else if ("Request".equals(currentStatus)) badgeClass = "status-request";
                                        %>
                                        <tr class="app-row" data-status="<%= currentStatus %>">
                                            <td class="ps-4">
                                                <a href="StudentProfile?id=<%= app.getStudentId() %>"
                                                   class="student-link">
                                                    <img src="<%= request.getContextPath() + "/ProfilePicture?id=" + app.getStudentId() + "&targetRole=Student" %>"
                                                         onerror="this.src='https://ui-avatars.com/api/?name=<%= app.getStudentName().replace(" ", "+") %>&background=0E2B58&color=fff';"
                                                         class="student-avatar-small">
                                                    <div><%= app.getStudentName() %>
                                                    </div>
                                                </a>
                                            </td>
                                            <td class="small text-muted fw-bold"><%= app.getPositionTitle() %>
                                            </td>

                                            <%-- Dual-Grade Column (Faculty Style) --%>
                                            <td class="fw-bold text-muted small">
                                                <%-- Study Grade is always visible (based on student's visibility settings handled in DTO) --%>
                                                <span class="grade-val grade-study">
                                                <% if (!app.isStudyGradeAvailable()) { %>
                                                   N/A
                                                <% } else { %>
                                                   <%= app.getStudyGradeFormatted() %>
                                                <% } %>
                                                </span>
                                                <%-- Internship Grade Privacy Check --%>
                                                <span class="grade-val grade-internship d-none">
                                                <% if (isAccepted) { %>
                                                <span class="text-primary">
                                                   <i class="fa-solid fa-star me-1"></i><%= app.getInternshipGradeFormatted() %>
                                                </span>
                                                <% } else { %>
                                                <span class="text-muted opacity-75 italic" style="font-size: 0.65rem;">
                                                   <i class="fa-solid fa-lock me-1"></i>Not Accepted
                                                </span>
                                                <% } %>
                                                </span>
                                            </td>

                                            <td>
                                                <% if (isAccepted) { %>
                                                <%-- Normal size, unclickable button for Accepted status --%>
                                                <div class="status-badge status-dropdown-btn status-accepted text-center"
                                                     style="cursor: default; opacity: 0.9; width: fit-content;">
                                                    <i class="fa-solid fa-check-double me-1"></i> Accepted
                                                </div>
                                                <% } else { %>
                                                <%-- Dropdown for all other statuses --%>
                                                <div class="dropdown">
                                                    <button class="status-badge status-dropdown-btn dropdown-toggle <%= badgeClass %>"
                                                            type="button" data-bs-toggle="dropdown"
                                                            aria-expanded="false">
                                                        <%= currentStatus %>
                                                    </button>
                                                    <ul class="dropdown-menu shadow border-0">
                                                        <li><h6 class="dropdown-header small">Move to State</h6></li>

                                                        <% if ("Pending".equals(currentStatus) || "Discussion".equals(currentStatus)) { %>
                                                        <li><a class="dropdown-item small"
                                                               href="InternshipApplications?id=<%= app.getId() %>&action=updateStatus&status=Rejected">Reject</a>
                                                        </li>
                                                        <% } else if ("Interview".equals(currentStatus)) { %>
                                                        <li><a class="dropdown-item small text-success fw-bold"
                                                               href="InternshipApplications?id=<%= app.getId() %>&action=updateStatus&status=Accepted">Accept
                                                            Student</a></li>
                                                        <li><a class="dropdown-item small"
                                                               href="InternshipApplications?id=<%= app.getId() %>&action=updateStatus&status=Rejected">Reject</a>
                                                        </li>
                                                        <% } else if ("Rejected".equals(currentStatus)) { %>
                                                        <%-- NEW: Check if the student is already accepted globally before allowing restore --%>
                                                        <% if (!"Accepted".equalsIgnoreCase(app.getStudentStatus())) { %>
                                                        <li><a class="dropdown-item small"
                                                               href="InternshipApplications?id=<%= app.getId() %>&action=updateStatus&status=Pending">Restore
                                                            to Pending</a></li>
                                                        <% } else { %>
                                                        <li><h6 class="dropdown-header x-small text-danger">Cannot
                                                            Restore: Student Hired Elsewhere</h6></li>
                                                        <% } %>
                                                        <% } %>
                                                    </ul>
                                                </div>
                                                <% } %>
                                            </td>
                                            <td class="text-end pe-4">
                                                <%
                                                    boolean isRequestedState = "Request".equals(currentStatus);
                                                    if (!app.isChatInitiated() && !isRejected && !isRequestedState) {
                                                %>
                                                <%-- TRIGGER MODAL FOR INITIAL CHAT (Standard flow) --%>
                                                <button class="btn btn-sm btn-chat rounded-pill px-3"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#initiateChatModal<%= app.getId() %>">
                                                    <i class="fa-regular fa-comments me-1"></i> Chat
                                                </button>
                                                <% } else if (isRequestedState) { %>
                                                <%-- DISABLED CHAT FOR REQUESTED STATE --%>
                                                <button class="btn btn-sm btn-chat disabled rounded-pill px-3"
                                                        style="opacity: 0.6; cursor: not-allowed;"
                                                        title="Waiting for student to accept the interview request">
                                                    <i class="fa-solid fa-hourglass-start me-1"></i> Requested
                                                </button>
                                                <% } else { %>
                                                <%-- DIRECT LINK FOR EXISTING CHAT --%>
                                                <button class="btn btn-sm btn-chat rounded-pill px-3 <%= isRejected ? "disabled" : "" %>"
                                                        <%= isRejected ? "disabled" : "" %>
                                                        onclick="window.location.href='InternshipApplications?id=<%= app.getId() %>'">
                                                    <i class="fa-regular fa-comments me-1"></i> Chat
                                                </button>
                                                <% } %>
                                            </td>
                                            <div class="modal fade" id="initiateChatModal<%= app.getId() %>"
                                                 tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog modal-dialog-centered">
                                                    <div class="modal-content border-0 shadow-lg">
                                                        <div class="modal-header bg-light border-0">
                                                            <h5 class="modal-title fw-bold">Start Conversation</h5>
                                                            <button type="button" class="btn-close"
                                                                    data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <form action="SendMessage" method="POST">
                                                            <input type="hidden" name="appId"
                                                                   value="<%= app.getId() %>">
                                                            <%-- Optional: flag to help servlet identify this is the first message --%>
                                                            <input type="hidden" name="isInitial" value="true">

                                                            <div class="modal-body p-4">
                                                                <div class="d-flex align-items-center mb-4">
                                                                    <%-- Profile Picture Logic with ULBS Blue Fallback --%>
                                                                    <%
                                                                        String studentPfp = request.getContextPath() + "/ProfilePicture?id=" + app.getStudentId() + "&targetRole=Student";
                                                                        String studentFallback = "https://ui-avatars.com/api/?name=" + app.getStudentName().replace(" ", "+") + "&background=0E2B58&color=fff";
                                                                    %>
                                                                    <img src="<%= studentPfp %>"
                                                                         onerror="this.onerror=null;this.src='<%= studentFallback %>';"
                                                                         class="rounded-circle me-3 shadow-sm"
                                                                         style="width: 50px; height: 50px; object-fit: cover; border: 2px solid #fff;">
                                                                    <div>
                                                                        <h6 class="fw-bold mb-0"><%= app.getStudentName() %>
                                                                        </h6>
                                                                        <span class="text-muted small">Candidate for <%= app.getPositionTitle() %></span>
                                                                    </div>
                                                                </div>

                                                                <div class="mb-3">
                                                                    <label class="form-label small fw-bold text-muted text-uppercase">Your
                                                                        Message</label>
                                                                    <textarea name="message"
                                                                              class="form-control border-0 bg-light p-3"
                                                                              rows="4"
                                                                              placeholder="Type your first message to start the discussion..."
                                                                              required></textarea>
                                                                </div>

                                                                <div class="alert alert-info border-0 py-2 small mb-0">
                                                                    <i class="fa-solid fa-circle-info me-2"></i> This
                                                                    will move the application to
                                                                    <strong>Discussion</strong> status.
                                                                </div>
                                                            </div>
                                                            <div class="modal-footer border-0 pt-0">
                                                                <button type="button" class="btn btn-light btn-sm px-3"
                                                                        data-bs-dismiss="modal">Cancel
                                                                </button>
                                                                <button type="submit"
                                                                        class="btn btn-primary btn-sm px-4 fw-bold">Send
                                                                    Message
                                                                </button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>
                                        </tr>
                                        <% } %>
                                        <tr id="noResultsRow" style="display: none;">
                                            <td colspan="5" class="text-center py-5">
                                                <div class="opacity-25 mb-3">
                                                    <i class="fa-solid fa-filter-circle-xmark fa-3x text-muted"></i>
                                                </div>
                                                <h5 class="fw-bold text-muted mb-1" id="noResultsHeader">No matches</h5>
                                                <p class="text-muted small mb-0" id="noResultsMessage">Try changing your
                                                    filter settings.</p>
                                            </td>
                                        </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <% } else { %>
                            <div class="text-center py-5"><p class="text-muted">No applications received yet.</p></div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card custom-card mb-4">
                        <div class="card-header">
                            <i class="fa-solid fa-bolt me-2"></i> Quick Actions
                        </div>
                        <div class="card-body p-0">
                            <div class="d-grid gap-0">
                                <a href="${pageContext.request.contextPath}/PostPosition"
                                   class="btn btn-action rounded-0 border-bottom-0 border-start-0 border-end-0">
                                    <i class="fa-solid fa-plus-circle me-2"></i> Post New Internship
                                </a>
                                <!-- Request Interview Button -->
                                <a href="${pageContext.request.contextPath}/RequestInterview"
                                   class="btn btn-action rounded-0 border-bottom-0 border-start-0 border-end-0">
                                    <i class="fa-solid fa-calendar-check me-2"></i> Request Interview
                                </a>
                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= request.getAttribute("facultyId") %>"
                                   class="btn btn-action rounded-0 border-bottom-0 border-start-0 border-end-0">
                                    <i class="fa-regular fa-envelope me-2"></i> Contact Faculty
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="card custom-card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span class="fw-bold"><i class="fa-solid fa-list-ul me-2"></i> Your Positions</span>
                            <a href="${pageContext.request.contextPath}/PostPosition"
                               class="btn btn-sm btn-primary rounded-circle d-flex align-items-center justify-content-center"
                               style="width: 28px; height: 28px; transition: all 0.3s ease; border: none;"
                               title="Post New Position">
                                <i class="fa-solid fa-plus" style="font-size: 0.8rem;"></i>
                            </a>
                        </div>
                        <div class="scrollable-list">
                            <% if (myPositions != null && !myPositions.isEmpty()) { %>
                            <% for (InternshipPositionDto pos : myPositions) { %>
                            <div class="position-item d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="position-title"><%= pos.getTitle() %></span>
                                    <div class="d-flex align-items-center gap-2">
                                        <%
                                            String status = pos.getStatus(); // Assumes getStatus() returns "Open", "Pending", etc.
                                            String posBadgeClass = "pos-status-pending";
                                            boolean isFull = pos.getAcceptedCount() >= pos.getMaxSpots();
                                            if ("Open".equalsIgnoreCase(status)) posBadgeClass = "pos-status-open";
                                            else if ("Closed".equalsIgnoreCase(status))
                                                posBadgeClass = "pos-status-closed";
                                        %>
                                        <span class="pos-status-badge <%= posBadgeClass %>">
                                          <i class="fa-solid <%= "Open".equalsIgnoreCase(status) ? "fa-globe" : "fa-clock-rotate-left" %> me-1"></i>
                                          <%= status %>
                                        </span>
                                        <span class="position-meta">
                                            <i class="fa-regular fa-calendar ms-1"></i>
                                         <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "N/A" %>
                                        </span>
                                    </div>
                                </div>
                                <div class="d-flex align-items-center">
                                    <span class="capacity-badge-sidebar <%= isFull ? "capacity-full-sidebar" : "" %>">
                                    <%= pos.getAcceptedCount() %>/<%= pos.getMaxSpots() %>
                                    </span>
                                    <button class="btn-manage-eye" data-bs-toggle="modal"
                                            data-bs-target="#applyModal<%= pos.getId() %>" title="View Details">
                                        <i class="fa-solid fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="modal fade" id="applyModal<%= pos.getId() %>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-scrollable">
                                    <div class="modal-content border-0">
                                        <div class="modal-header border-0 pb-0">
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body p-5 pt-0">
                                            <div class="text-center mb-4">
                                                <div class="mb-2">
                                                    <span class="pos-status-badge <%= posBadgeClass %>"
                                                          style="font-size: 0.75rem; padding: 4px 12px;">
                                                      <%= status %> Status
                                                    </span>
                                                </div>
                                                <h3 class="fw-bold"><%= pos.getTitle() %>
                                                </h3>
                                                <p class="text-muted"><%= company.getName() %>
                                                </p>
                                            </div>

                                            <div class="row">
                                                <div class="col-md-7">
                                                    <h6 class="fw-bold text-uppercase text-muted small">Description</h6>
                                                    <p class="small text-secondary"><%= pos.getDescription() %>
                                                    </p>
                                                    <h6 class="fw-bold text-uppercase text-muted small mt-4">
                                                        Requirements</h6>
                                                    <p class="small text-secondary"><%= pos.getRequirements() != null ? pos.getRequirements() : "No specific requirements." %>
                                                    </p>
                                                </div>

                                                <div class="col-md-5 border-start">
                                                    <h6 class="fw-bold text-uppercase text-muted small mb-3"><i
                                                            class="fa-solid fa-user-graduate me-2"></i>Candidates</h6>
                                                    <div class="applicant-scroll">
                                                        <% if (pos.getApplicants() != null && !pos.getApplicants().isEmpty()) { %>
                                                        <% for (InternshipApplicationDto app : pos.getApplicants()) { %>
                                                        <div class="applicant-item">
                                                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= app.getStudentId() %>&targetRole=Student"
                                                                 onerror="this.src='https://ui-avatars.com/api/?name=<%= app.getStudentName() %>&background=0E2B58&color=fff';"
                                                                 class="applicant-pfp">
                                                            <div class="overflow-hidden">
                                                                <a href="${pageContext.request.contextPath}/StudentProfile?id=<%= app.getStudentId() %>"
                                                                   class="text-decoration-none text-dark fw-bold small d-block text-truncate">
                                                                    <%= app.getStudentName() %>
                                                                </a>
                                                                <span class="badge bg-light text-dark x-small"
                                                                      style="font-size: 0.65rem;"><%= app.getStatus() %></span>
                                                            </div>
                                                        </div>
                                                        <% } %>
                                                        <% } else { %>
                                                        <div class="text-center py-4 text-muted small">No applications
                                                            yet.
                                                        </div>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="alert alert-light border mt-4 m-0 p-2">
                                                <div class="modal-info-bar">
                                                    <div class="modal-info-item small">
                                                        <i class="fa-solid fa-calendar-day me-1 text-primary"></i>
                                                        <strong>Deadline:</strong> <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %>
                                                    </div>
                                                    <div class="modal-info-item small border-start border-end">
                                                        <i class="fa-solid fa-users me-1 text-primary"></i>
                                                        <strong>Applications:</strong> <%= (pos.getApplicationsCount() != null ? pos.getApplicationsCount() : 0) %>
                                                    </div>
                                                    <div class="modal-info-item small">
                                                        <i class="fa-solid fa-user-check me-1 text-success"></i>
                                                        <strong>Capacity:</strong>
                                                        <span class="<%= (pos.getAcceptedCount() >= pos.getMaxSpots()) ? "text-danger fw-bold" : "" %>">
                                                        <%= pos.getAcceptedCount() %> / <%= pos.getMaxSpots() %>
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer border-0 justify-content-center pb-4">
                                            <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">
                                                Close
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="p-4 text-center text-muted small">No positions posted yet.</div>
                            <% } %>
                        </div>
                    </div>
                    <jsp:include page="../blocks/activitySidebar.jsp"/>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editPhoneModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 pb-0">
                <h6 class="modal-title fw-bold text-muted text-uppercase small">Update Phone Number</h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyDashboard" method="POST" id="phoneForm">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label small fw-bold">Romanian Number (e.g. 0722...)</label>
                        <input type="text" name="phoneNumber" id="phoneInput"
                               class="form-control bg-light border-0"
                               placeholder="07XXXXXXXX"
                               value="<%= (company.getPhoneNumber() != null) ? company.getPhoneNumber() : "" %>"
                               required
                               pattern="^(02|03|07)\d{8}$"
                               title="Please enter a valid 10-digit Romanian phone number starting with 02, 03, or 07.">
                        <div class="invalid-feedback x-small">Invalid RO number format.</div>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" class="btn btn-light btn-sm px-3" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm px-4 fw-bold">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function () {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });

        const phoneInput = document.getElementById('phoneInput');
        const phoneForm = document.getElementById('phoneForm');

        phoneInput.addEventListener('input', function () {
            // Force numbers only
            this.value = this.value.replace(/[^0-9]/g, '');

            // Visual feedback
            const isValid = /^(02|03|07)\d{8}$/.test(this.value);
            if (this.value.length > 0) {
                this.classList.toggle('is-invalid', !isValid);
                this.classList.toggle('is-valid', isValid);
            }
        });

        // --- 1. Application Filtering Logic ---
        const filterOptions = document.querySelectorAll('.filter-opt');
        const appRows = document.querySelectorAll('.app-row');
        const filterLabel = document.getElementById('currentFilterLabel');

        function applyFilter(filterType) {
            let visibleCount = 0;
            const noResultsRow = document.getElementById('noResultsRow');
            const noResultsHeader = document.getElementById('noResultsHeader');
            const noResultsMessage = document.getElementById('noResultsMessage');

            // Filter the rows
            appRows.forEach(row => {
                const status = row.getAttribute('data-status');
                let isVisible = false;

                if (filterType === 'All') {
                    isVisible = true;
                } else if (filterType === 'HideRejected') {
                    isVisible = (status !== 'Rejected');
                } else {
                    isVisible = (status === filterType);
                }

                row.style.display = isVisible ? '' : 'none';
                if (isVisible) visibleCount++;
            });

            // Handle Context-Aware Messages
            if (visibleCount === 0) {
                noResultsRow.style.display = '';

                let headerText = "Filtered Out";
                let messageText = "No applications match this specific status.";

                switch (filterType) {
                    case 'Pending':
                        headerText = "All Caught Up!";
                        messageText = "You have no new pending applications to review.";
                        break;
                    case 'Discussion':
                        headerText = "No Active Discussions";
                        messageText = "No students are currently in the 'Discussion' phase.";
                        break;
                    case 'Request':
                        headerText = "No Sent Requests";
                        messageText = "You have no pending interview requests yet.";
                        break;
                    case 'Interview':
                        headerText = "No Interviews Found";
                        messageText = "You don't have any students marked for an 'Interview'.";
                        break;
                    case 'Accepted':
                        headerText = "No Accepted Students";
                        messageText = "Finalized hires will appear here once accepted.";
                        break;
                    case 'Rejected':
                        headerText = "Clean Slate";
                        messageText = "You haven't rejected any applications yet.";
                        break;
                    case 'HideRejected':
                        headerText = "No Active Applications";
                        messageText = "All applications are currently hidden by your filter.";
                        break;
                }

                noResultsHeader.innerText = headerText;
                noResultsMessage.innerText = messageText;
            } else {
                noResultsRow.style.display = 'none';
            }
        }

        filterOptions.forEach(opt => {
            opt.addEventListener('click', function (e) {
                e.preventDefault();
                filterOptions.forEach(o => o.classList.remove('active'));
                this.classList.add('active');
                filterLabel.innerText = this.innerText;
                applyFilter(this.getAttribute('data-filter'));
            });
        });

        // --- 2. Grade Toggling Logic ---
        const gradeToggleOpts = document.querySelectorAll('.toggle-grade');
        const gradeLabel = document.getElementById('gradeColumnLabel');

        gradeToggleOpts.forEach(opt => {
            opt.addEventListener('click', function (e) {
                e.preventDefault();
                const type = this.getAttribute('data-type');

                // Update Header Label
                gradeLabel.innerText = (type === 'study') ? 'Study Grade' : 'Internship Grade';

                // Toggle Visibility Spans
                document.querySelectorAll('.grade-study').forEach(el => {
                    el.classList.toggle('d-none', type !== 'study');
                });
                document.querySelectorAll('.grade-internship').forEach(el => {
                    el.classList.toggle('d-none', type !== 'internship');
                });

                // Optional: Update active state in the dropdown menu
                gradeToggleOpts.forEach(o => o.classList.remove('active'));
                this.classList.add('active');
            });
        });

        // --- 3. Initial Run ---
        applyFilter('HideRejected');
    });
</script>
</body>
</html>