<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.StudentInfoDto" %>
<%@ page import="com.internshipapp.common.AccountActivityDto" %>
<%@ page import="com.internshipapp.common.UserAccountDto" %>
<%@ page import="com.internshipapp.common.InternshipApplicationDto" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // 1. Retrieve Data
    StudentInfoDto student = (StudentInfoDto) request.getAttribute("student");
    UserAccountDto userAccount = (UserAccountDto) request.getAttribute("userAccount");
    List<AccountActivityDto> activities = (List<AccountActivityDto>) request.getAttribute("activities");
    List<InternshipApplicationDto> myApplications = (List<InternshipApplicationDto>) request.getAttribute("myApplications");

    // Session Data
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }

    // --- Profile Completion Calculation (CV = 50% Weight) ---
    double completenessValue = 0;

    // Weighting: CV = 50%, Other 5 fields = 10% each
    double standardScore = 10.0; // 50% / 5 fields

    // 1. CV Uploaded (50% Weight)
    if (student.hasCv()) {
        completenessValue += 50.0;
    }

    // 2. First Name (10%)
    if (student.getFirstName() != null && !student.getFirstName().trim().isEmpty()) completenessValue += standardScore;
    // 3. Last Name (10%)
    if (student.getLastName() != null && !student.getLastName().trim().isEmpty()) completenessValue += standardScore;
    // 4. Study Year (10%)
    if (student.getStudyYear() != null) completenessValue += standardScore;
    // 5. Last Year Grade (10%)
    if (student.getLastYearGrade() != null) completenessValue += standardScore;
    // 6. Profile Picture Uploaded (10%)
    if (student.hasProfilePic()) completenessValue += standardScore;

    // Convert to integer percentage, capped at 100
    int completeness = (int) Math.round(Math.min(completenessValue, 100.0));

    // --- Determine Color Schemes (Consistent with Company Panel) ---
    String completionText;
    String completionBarClass;
    String completionTextColor;

    if (completeness == 100) {
        completionText = "Complete";
        completionBarClass = "bg-success";
        completionTextColor = "text-success";
    } else if (completeness > 75) {
        completionText = "Excellent";
        completionBarClass = "bg-success";
        completionTextColor = "text-success";
    } else if (completeness >= 50) {
        completionText = "Good";
        completionBarClass = "bg-warning";
        completionTextColor = "text-warning";
    } else {
        completionText = "Needs Attention";
        completionBarClass = "bg-danger";
        completionTextColor = "text-danger";
    }


    // Calculate simple stats
    int totalApplicationsCount = (myApplications != null) ? myApplications.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        /* --- Dashboard Specific Styles --- */
        .page-title {
            color: var(--brand-blue-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        /* --- Stat Cards --- */
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

        .card-status::before {
            background-color: var(--brand-blue);
        }

        .card-year::before {
            background-color: #008080;
        }

        .card-grade::before {
            background-color: var(--ulbs-red);
        }

        .card-enroll::before {
            background-color: #28a745;
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
            opacity: 0.3;
            color: var(--brand-blue-dark);
        }

        /* --- Dashboard Custom Cards --- */
        .custom-card {
            border: none;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border-radius: 8px;
            background: white;
            margin-bottom: 2rem;
        }

        .custom-card .card-header {
            background-color: white;
            border-bottom: 1px solid #eee;
            padding: 1.2rem;
            font-weight: 700;
            color: var(--brand-blue);
        }

        .info-list-item {
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
        }

        .info-list-item:last-child {
            border-bottom: none;
        }

        .info-label {
            color: #666;
            font-size: 0.9rem;
        }

        .info-value {
            color: var(--brand-blue-dark);
            font-weight: 600;
            text-align: right;
        }

        /* --- Action Buttons --- */
        .btn-action {
            text-align: left;
            padding: 1rem;
            border: 1px solid #eee;
            background: white;
            transition: all 0.2s;
            color: var(--brand-blue);
            font-weight: 600;
        }

        .btn-action:hover {
            background: var(--brand-blue);
            color: white;
            transform: translateX(5px);
        }

        .btn-brand {
            background-color: var(--brand-blue);
            color: white;
            border: none;
        }

        .btn-brand:hover {
            background-color: var(--brand-blue-dark);
            color: white;
        }

        /* --- Table Badges --- */
        .status-badge {
            font-size: 0.8rem;
            padding: 0.4em 0.8em;
            border-radius: 50px;
            font-weight: 600;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }

        .status-accepted {
            background-color: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
        }

        .status-rejected {
            background-color: #f8d7da;
            color: #842029;
            border: 1px solid #f5c2c7;
        }

        .status-interview {
            background-color: #cff4fc;
            color: #055160;
            border: 1px solid #b6effb;
        }

        .position-title-link {
            font-weight: bold;
            color: var(--brand-blue-dark);
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .position-title-link:hover {
            color: var(--ulbs-red);
            text-decoration: underline;
        }

        .company-link {
            font-weight: 600;
            color: #777;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .company-link:hover {
            color: var(--ulbs-red);
        }

        .applications-scroll-container {
            max-height: 400px; /* Adjust this value to your liking */
            overflow-y: auto;
        }

        /* Custom scrollbar for the table (matching the activity sidebar) */
        .applications-scroll-container::-webkit-scrollbar {
            width: 6px;
        }
        .applications-scroll-container::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }
        .applications-scroll-container::-webkit-scrollbar-thumb {
            background: var(--brand-blue);
            border-radius: 4px;
        }

        /* Upgrade the "Eye" button to Faculty Style */
        .btn-manage-eye {
            background-color: #f8f9fa;
            color: var(--brand-blue);
            border: 1px solid #e9ecef;
            width: 34px;
            height: 34px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
            border-radius: 8px;
        }

        .btn-manage-eye:hover {
            background-color: var(--brand-blue);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(14, 43, 88, 0.2);
        }

        /* Interview Response Buttons Styling */
        .interview-response-buttons {
            max-width: 200px;
        }

        .interview-response-buttons .btn-group {
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .interview-response-buttons .btn-outline-success {
            border-color: #28a745;
            color: #28a745;
            transition: all 0.3s ease;
        }

        .interview-response-buttons .btn-outline-success:hover {
            background-color: #28a745;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
        }

        .interview-response-buttons .btn-outline-danger {
            border-color: #dc3545;
            color: #dc3545;
            transition: all 0.3s ease;
        }

        .interview-response-buttons .btn-outline-danger:hover {
            background-color: #dc3545;
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
        }

        /* Enhanced status badges to match image */
        .status-badge {
            font-size: 0.75rem;
            padding: 0.4em 0.8em;
            border-radius: 50px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            white-space: nowrap;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }

        .status-accepted {
            background-color: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
        }

        .status-rejected {
            background-color: #f8d7da;
            color: #842029;
            border: 1px solid #f5c2c7;
        }

        .status-interview {
            background-color: #cff4fc;
            color: #055160;
            border: 1px solid #b6effb;
        }

        .status-discussion {
            background-color: #e7d7ff;
            color: #4a148c;
            border: 1px solid #d1c4e9;
        }

        /* Table styling to match image */
        .table td {
            vertical-align: middle;
            padding: 1rem 0.75rem;
        }

        .table th {
            font-weight: 600;
            color: #495057;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 2px solid #dee2e6;
            padding: 1rem 0.75rem;
        }

        .table-hover tbody tr:hover {
            background-color: rgba(14, 43, 88, 0.02);
        }

        /* Position title styling */
        .position-title-link {
            font-weight: 600;
            color: var(--brand-blue-dark);
            text-decoration: none;
            transition: color 0.3s ease;
            font-size: 0.95rem;
        }

        .position-title-link:hover {
            color: var(--ulbs-red);
            text-decoration: underline;
        }

        .company-link {
            color: #6c757d;
            text-decoration: none;
            font-size: 0.85rem;
            transition: color 0.3s ease;
        }

        .company-link:hover {
            color: var(--ulbs-red);
        }

        /* Card header enhancement */
        .card-header {
            background-color: #f8f9fa;
            border-bottom: 2px solid #e9ecef;
            padding: 1.25rem 1.5rem;
        }

        .card-header .badge {
            font-size: 0.75rem;
            padding: 0.35em 0.75em;
        }

        /* For better button styling */
        .btn-group .btn {
            padding: 0.5rem 1rem;
            font-weight: 600;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row">

        <jsp:include page="../blocks/studentSidebar.jsp"/>

        <div class="col-md-9 col-lg-10 main-content">

            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h1 class="h2 page-title">Welcome, <%= student.getFirstName() %>!</h1>
                    <p class="text-muted mb-0">
                        <i class="fa-solid fa-user-graduate me-1"></i>
                        Student <strong>
                    </strong> | Year <%= student.getStudyYear() %>
                    </p>
                </div>
                <div class="d-none d-md-block text-end">
                    <span class="badge bg-light text-dark border">
                        <i class="fa-regular fa-clock me-1"></i> <%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date()) %>
                    </span>
                </div>
            </div>

            <div class="row mb-4 g-3">
                <div class="col-md-3 col-6">
                    <div class="stat-card card-status">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value" style="font-size: 1.4rem;"><%= student.getStatus() %>
                                </h2>
                                <span class="stat-label">Status</span>
                            </div>
                            <i class="fa-solid fa-user-check stat-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card card-year">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value">Year <%= student.getStudyYear() %>
                                </h2>
                                <span class="stat-label">Current Year</span>
                            </div>
                            <i class="fa-solid fa-book-open stat-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <a href="${pageContext.request.contextPath}/StudentProfile" class="text-decoration-none">
                        <div class="stat-card card-grade">
                            <div class="d-flex justify-content-between">
                                <div>
                                    <h2 class="stat-value">
                                        <%= student.getGradeFormatted() %>
                                        <%-- Small icon indicator next to the big number --%>
                                        <span class="ms-1" style="font-size: 1rem;">
                                            <% if (student.getGradeVisibility()) { %>
                                                <i class="fa-solid fa-eye text-success opacity-25"></i>
                                            <% } else { %>
                                                <i class="fa-solid fa-eye-slash text-danger"></i>
                                            <% } %>
                                        </span>
                                    </h2>
                                    <span class="stat-label">Last Grade</span>

                                    <% if (!student.getGradeVisibility()) { %>
                                    <div class="text-danger fw-bold" style="font-size: 0.65rem; margin-top: 4px;">
                                        <i class="fa-solid fa-circle-info me-1"></i> HIDDEN FROM COMPANIES
                                    </div>
                                    <% } %>
                                </div>
                                <i class="fa-solid fa-chart-line stat-icon"></i>
                            </div>
                        </div>
                    </a>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card card-enroll">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value" style="font-size: 1.4rem;">
                                    <%= student.getEnrolled() ? "Enrolled" : "Not Enrolled" %>
                                </h2>
                                <span class="stat-label">Academic Status</span>
                            </div>
                            <i class="fa-solid fa-school stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">

                    <div class="card custom-card">
                        <div class="card-header">
                            <i class="fa-regular fa-id-badge me-2"></i> Student Profile
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted small fw-bold mb-3">Personal Details</h6>
                                    <div class="info-list-item">
                                        <span class="info-label">Full Name</span>
                                        <span class="info-value"><%= student.getFullName() %></span>
                                    </div>
                                    <div class="info-list-item">
                                        <span class="info-label">Email</span>
                                        <span class="info-value"><%= student.getUserEmail() != null ? student.getUserEmail() : "N/A" %></span>
                                    </div>
                                    <div class="info-list-item">
                                        <span class="info-label">Username</span>
                                        <span class="info-value"><%= userAccount != null ? userAccount.getUsername() : "N/A" %></span>
                                    </div>
                                </div>
                                <div class="col-md-6 mt-4 mt-md-0">
                                    <h6 class="text-uppercase text-muted small fw-bold mb-3">Academic & Account</h6>
                                    <div class="info-list-item">
                                        <span class="info-label">Account Role</span>
                                        <span class="badge bg-primary text-white"><%= sessionRole %></span>
                                    </div>
                                    <div class="info-list-item">
                                        <span class="info-label">CV Uploaded</span>
                                        <span class="badge <%= student.hasCv() ? "bg-success" : "bg-danger text-white" %>">
                                            <%= student.hasCv() ? "Yes" : "Missing" %>
                                        </span>
                                    </div>
                                    <div class="mt-4">
                                        <div class="d-flex justify-content-between small mb-1">
                                            <span class="text-muted">Profile Completion</span>
                                            <span class="fw-bold <%= completionTextColor %>"><%= completeness %>% (<%= completionText %>)</span>
                                        </div>
                                        <div class="progress" style="height: 6px;">
                                            <div class="progress-bar <%= completionBarClass %>" role="progressbar"
                                                 style="width: <%= completeness %>%;"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Updated Applications Table Section -->
                    <div class="card custom-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span><i class="fa-solid fa-file-signature me-2"></i> My Internship Applications</span>
                            <span class="badge bg-light text-dark border"><%= totalApplicationsCount %> Total</span>
                        </div>
                        <div class="card-body p-0">
                            <div class="applications-scroll-container">
                                <% if (myApplications != null && !myApplications.isEmpty()) { %>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-light">
                                        <tr>
                                            <th class="ps-4">Position / Company</th>
                                            <th>Applied Date</th>
                                            <th>Status</th>
                                            <th>Grade</th>
                                            <th class="text-end pe-4">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <% for (InternshipApplicationDto app : myApplications) {
                                            String badgeClass = "bg-secondary";
                                            String badgeIcon = "";
                                            if ("Pending".equals(app.getStatus())) {
                                                badgeClass = "status-pending";
                                                badgeIcon = "fa-clock";
                                            } else if ("Accepted".equals(app.getStatus())) {
                                                badgeClass = "status-accepted";
                                                badgeIcon = "fa-check-double";
                                            } else if ("Rejected".equals(app.getStatus())) {
                                                badgeClass = "status-rejected";
                                                badgeIcon = "fa-xmark";
                                            } else if ("Interview".equals(app.getStatus())) {
                                                badgeClass = "status-interview";
                                                badgeIcon = "fa-calendar-check";
                                            } else if ("Discussion".equals(app.getStatus())) {
                                                badgeClass = "status-discussion";
                                                badgeIcon = "fa-comments";
                                            }

                                            String appliedDate = app.getAppliedAt() != null ? app.getAppliedAt().toString().substring(0, 10) : "N/A";
                                            String deadlineDate = app.getDeadline() != null ? app.getDeadline().toString().substring(0, 10) : "Open";

                                            // Company Logo Logic
                                            String companyLogoUrl = request.getContextPath() + "/ProfilePicture?id=" + app.getCompanyId() + "&targetRole=Company";
                                            String companyFallback = "https://ui-avatars.com/api/?name=" + app.getCompanyName().replace(" ", "+") + "&background=F8F9FA&color=0E2B58&size=100";
                                        %>
                                        <tr class="application-row" data-id="<%= app.getId() %>" data-status="<%= app.getStatus() %>">
                                            <td class="ps-4">
                                                <div class="d-flex align-items-center gap-2">
                                                    <img src="<%= companyLogoUrl %>"
                                                         onerror="this.onerror=null;this.src='<%= companyFallback %>';"
                                                         class="student-avatar-small border"
                                                         style="width: 32px; height: 32px; border-radius: 4px; object-fit: contain; padding: 2px; background: white;">
                                                    <div>
                                                        <a href="#" class="position-title-link"
                                                           data-bs-toggle="modal"
                                                           data-bs-target="#detailsModal_<%= app.getId() %>">
                                                            <%= app.getPositionTitle() %>
                                                        </a>
                                                        <div class="small">
                                                            <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= app.getCompanyId() %>"
                                                               class="company-link text-decoration-none" style="font-size: 0.85rem;">
                                                                <%= app.getCompanyName() %>
                                                            </a>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="small text-muted"><%= appliedDate %></td>
                                            <td>
                            <span class="status-badge <%= badgeClass %>">
                                <i class="fa-solid <%= badgeIcon %> me-1"></i> <%= app.getStatus() %>
                            </span>

                                                <%-- Interview Response Buttons --%>
                                                <% if ("Interview".equals(app.getStatus())) { %>
                                                <div class="d-inline-flex gap-1 ms-2">
                                                    <button type="button"
                                                            class="btn btn-outline-success btn-sm px-2 py-1"
                                                            onclick="respondToInterview(<%= app.getId() %>, 'accept')"
                                                            title="Accept Interview"
                                                            style="font-size: 0.75rem; font-weight: 600;">
                                                        <i class="fa-solid fa-check"></i> Accept
                                                    </button>
                                                    <button type="button"
                                                            class="btn btn-outline-danger btn-sm px-2 py-1"
                                                            onclick="respondToInterview(<%= app.getId() %>, 'reject')"
                                                            title="Reject Interview"
                                                            style="font-size: 0.75rem; font-weight: 600;">
                                                        <i class="fa-solid fa-xmark"></i> Reject
                                                    </button>
                                                </div>
                                                <% } %>
                                            </td>
                                            <td>
                                                <% if (app.getGrade() != null) { %>
                                                <span class="fw-bold text-dark"><%= app.getGrade() %></span>
                                                <% } else { %>
                                                <span class="text-muted">-</span>
                                                <% } %>
                                            </td>
                                            <td class="text-end pe-4">
                                                <button type="button" class="btn-manage-eye"
                                                        data-bs-toggle="modal"
                                                        data-bs-target="#detailsModal_<%= app.getId() %>"
                                                        title="View Details">
                                                    <i class="fa-solid fa-eye"></i>
                                                </button>
                                            </td>
                                        </tr>
                                        <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                <% } else { %>
                                <div class="text-center py-5">
                                    <i class="fa-regular fa-folder-open fa-3x text-muted opacity-25 mb-3"></i>
                                    <p class="text-muted">You haven't applied to any internships yet.</p>
                                    <a href="${pageContext.request.contextPath}/InternshipPositions"
                                       class="btn btn-primary btn-sm mt-2">
                                        <i class="fa-solid fa-magnifying-glass me-2"></i> Browse Positions
                                    </a>
                                </div>
                                <% } %>
                            </div>
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
                                <a href="${pageContext.request.contextPath}/InternshipPositions"
                                   class="btn btn-action rounded-0 border-top-0 border-start-0 border-end-0 text-start w-100">
                                    <i class="fa-solid fa-magnifying-glass me-2"></i> Find Internships
                                </a>

                                <button type="button"
                                        class="btn btn-action rounded-0 border-start-0 border-end-0 text-start w-100"
                                        data-bs-toggle="modal" data-bs-target="#uploadCvModal">
                                    <i class="fa-solid <%= student.hasCv() ? "fa-file-arrow-up" : "fa-upload" %> me-2"></i> Update CV
                                </button>

                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= request.getAttribute("facultyId") %>"
                                   class="btn btn-action rounded-0 border-bottom-0 border-start-0 border-end-0 text-start w-100">
                                    <i class="fa-regular fa-envelope me-2"></i> Contact Faculty
                                </a>
                            </div>
                        </div>
                    </div>

                    <jsp:include page="../blocks/activitySidebar.jsp" />
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<div class="modal fade" id="uploadCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold">
                    <%= student.hasCv() ? "Manage Curriculum Vitae" : "Upload Curriculum Vitae" %>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">

                <% if (student.hasCv()) { %>
                <div class="text-center p-3 mb-4 bg-light border rounded">
                    <i class="fa-regular fa-file-pdf text-danger fa-3x mb-2"></i>
                    <h6 class="fw-bold text-dark mb-1">Current CV is Available</h6>
                    <p class="text-muted small mb-3">You can download your current CV or replace it below.</p>

                    <div class="d-flex justify-content-center gap-2">
                        <a href="${pageContext.request.contextPath}/DownloadCV?id=<%= student.getId() %>"
                           class="btn btn-sm btn-outline-primary bg-white">
                            <i class="fa-solid fa-download me-1"></i> Download
                        </a>
                        <button type="button" class="btn btn-sm btn-outline-danger bg-white"
                                data-bs-toggle="modal" data-bs-target="#confirmDeleteCvModal">
                            <i class="fa-solid fa-trash me-1"></i> Delete
                        </button>
                    </div>
                </div>
                <hr class="text-muted opacity-25">
                <p class="small fw-bold text-muted mb-2">Update / Replace File:</p>
                <% } %>

                <form id="cvUploadForm" action="${pageContext.request.contextPath}/UploadCV" method="POST" enctype="multipart/form-data">
                    <div class="mb-3">
                        <label class="form-label small text-muted text-uppercase fw-bold">Select PDF File</label>
                        <input type="file" name="cvFile" id="cvFileInput" class="form-control" accept=".pdf" required>
                        <div id="cvErrorLabel" class="text-danger small mt-1" style="display:none;">
                            Please select a CV file before proceeding.
                        </div>
                        <div class="form-text">Accepted format: PDF. Max size: 5MB.</div>
                    </div>

                    <div class="d-grid">
                        <button type="button" id="submitCvButton" class="btn btn-brand">
                            <i class="fa-solid fa-cloud-arrow-up me-2"></i>
                            <%= student.hasCv() ? "Replace CV" : "Upload CV" %>
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="confirmReplaceCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-triangle-exclamation me-2"></i> Confirm Replacement</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <p class="mb-0">Are you sure you want to replace your current CV with the new file?</p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-warning text-dark btn-sm" onclick="submitCvReplacement()">
                    Replace CV
                </button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="confirmDeleteCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-trash-can me-2"></i> Confirm Deletion</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <p class="mb-0">Are you sure you want to permanently delete your CV? This cannot be undone.</p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <a href="${pageContext.request.contextPath}/DeleteCV" class="btn btn-danger btn-sm" onclick="hideAllModals()">
                    Delete Permanently
                </a>
            </div>
        </div>
    </div>
</div>


<script>
    // Initialize modals for manual control/hiding
    var uploadModal, replaceConfirmModal, deleteConfirmModal;

    document.addEventListener('DOMContentLoaded', function() {
        // Initialize Bootstrap Modals
        uploadModal = new bootstrap.Modal(document.getElementById('uploadCvModal'), {});
        replaceConfirmModal = new bootstrap.Modal(document.getElementById('confirmReplaceCvModal'), {});
        deleteConfirmModal = new bootstrap.Modal(document.getElementById('confirmDeleteCvModal'), {});

        const hasCv = <%= student.hasCv() %>;
        const submitCvButton = document.getElementById('submitCvButton');
        const cvFileInput = document.getElementById('cvFileInput');
        const cvErrorLabel = document.getElementById('cvErrorLabel');

        if (submitCvButton) {
            submitCvButton.addEventListener('click', function() {
                // Check if a file is selected
                if (cvFileInput.files.length === 0) {
                    // Display red error label instead of alert()
                    cvErrorLabel.style.display = 'block';
                    // Re-add required class visually
                    cvFileInput.classList.add('is-invalid');
                    return;
                } else {
                    // Hide error label if validation passes
                    cvErrorLabel.style.display = 'none';
                    cvFileInput.classList.remove('is-invalid');
                }

                if (hasCv) {
                    // 1. Hide main upload modal
                    uploadModal.hide();
                    // 2. Show replacement confirmation modal
                    replaceConfirmModal.show();
                } else {
                    // If CV does not exist, submit the form directly
                    document.getElementById('cvUploadForm').submit();
                }
            });
        }
    });

    // Function executed upon confirmation of CV replacement
    function submitCvReplacement() {
        // 1. Hide all modals (crucial for clean redirect)
        hideAllModals();
        // 2. Submit the form (which triggers the server-side redirect)
        document.getElementById('cvUploadForm').submit();
    }

    // Helper function to hide all modals (used before redirects to prevent JS errors)
    function hideAllModals() {
        // Use hide() method safely
        if (uploadModal) uploadModal.hide();
        if (replaceConfirmModal) replaceConfirmModal.hide();
        if (deleteConfirmModal) deleteConfirmModal.hide();

        // This is necessary because hide() only sets classes, we ensure backdrop is gone before navigation
        document.body.classList.remove('modal-open');
        const backdrops = document.getElementsByClassName('modal-backdrop');
        while(backdrops.length > 0){
            backdrops[0].parentNode.removeChild(backdrops[0]);
        }

        function respondToInterview(applicationId, response) {
            const row = document.querySelector(`.application-row[data-id="${applicationId}"]`);
            const statusCell = row.querySelector('td:nth-child(3)');
            const currentStatus = row.getAttribute('data-status');

            // Verify it's still in interview status
            if (currentStatus !== 'Interview') {
                alert('This application is no longer in interview status.');
                return;
            }

            const action = response === 'accept' ? 'accept' : 'reject';
            const confirmMessage = response === 'accept'
                ? 'Are you sure you want to accept this internship offer? This action is final.'
                : 'Are you sure you want to reject this interview request?';

            if (!confirm(confirmMessage)) {
                return;
            }

            // Show loading state
            const responseButtons = statusCell.querySelector('.interview-response-buttons');
            const originalHTML = responseButtons.innerHTML;
            responseButtons.innerHTML = `
        <div class="text-center">
            <span class="spinner-border spinner-border-sm" role="status"></span>
            <span class="small ms-2">Processing...</span>
        </div>
    `;

            // Send AJAX request
            const xhr = new XMLHttpRequest();
            xhr.open('POST', '${pageContext.request.contextPath}/StudentInterviewResponse', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        const result = JSON.parse(xhr.responseText);
                        if (result.success) {
                            // Update UI
                            const newStatus = response === 'accept' ? 'Accepted' : 'Rejected';
                            const badgeClass = response === 'accept' ? 'status-accepted' : 'status-rejected';
                            const badgeIcon = response === 'accept' ? 'fa-check-double' : 'fa-xmark';

                            // Update status badge
                            const statusBadge = statusCell.querySelector('.status-badge');
                            statusBadge.className = `status-badge ${badgeClass}`;
                            statusBadge.innerHTML = `<i class="fa-solid ${badgeIcon} me-1"></i> ${newStatus}`;

                            // Remove response buttons
                            responseButtons.remove();

                            // Update row data attribute
                            row.setAttribute('data-status', newStatus);

                            // Show success message
                            showToast('Success', result.message, 'success');

                            // If accepted, reload page to reflect all status changes
                            if (response === 'accept') {
                                setTimeout(() => {
                                    location.reload();
                                }, 1500);
                            }
                        } else {
                            responseButtons.innerHTML = originalHTML;
                            showToast('Error', result.message, 'error');
                        }
                    } catch (e) {
                        responseButtons.innerHTML = originalHTML;
                        showToast('Error', 'Invalid server response', 'error');
                    }
                } else {
                    responseButtons.innerHTML = originalHTML;
                    showToast('Error', 'Server error: ' + xhr.status, 'error');
                }
            };

            xhr.onerror = function() {
                responseButtons.innerHTML = originalHTML;
                showToast('Error', 'Network error', 'error');
            };

            xhr.send(`applicationId=${applicationId}&response=${response}`);
        }

// Helper function to show toast notifications
        function showToast(title, message, type) {
            // Remove any existing toasts
            const existingToasts = document.querySelectorAll('.custom-toast');
            existingToasts.forEach(toast => toast.remove());

            // Create toast
            const toastHtml = `
        <div class="custom-toast position-fixed" style="top: 20px; right: 20px; z-index: 9999; min-width: 300px;">
            <div class="toast show" role="alert">
                <div class="toast-header ${type == 'success' ? 'bg-success text-white' : 'bg-danger text-white'}">
                    <strong class="me-auto">${title}</strong>
                    <button type="button" class="btn-close btn-close-white" onclick="this.closest('.custom-toast').remove()"></button>
                </div>
                <div class="toast-body">
                    ${message}
                </div>
            </div>
        </div>
    `;

            document.body.insertAdjacentHTML('beforeend', toastHtml);

            // Auto-remove after 5 seconds
            setTimeout(() => {
                const toast = document.querySelector('.custom-toast');
                if (toast) toast.remove();
            }, 5000);
        }


    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>