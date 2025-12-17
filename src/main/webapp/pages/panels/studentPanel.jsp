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
    String userEmail = (String) session.getAttribute("userEmail");
    String userRole = (String) session.getAttribute("userRole");

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

    <style>
        :root {
            --brand-blue: #0E2B58;
            --brand-blue-dark: #071a38;
            --ulbs-red: #A30B0B;
            --bg-light: #f4f7f6;
        }

        html, body {
            height: auto;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Segoe UI', Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .container-fluid.flex-grow-1 {
            height: auto;
            min-height: auto;
            flex-grow: 1;
        }

        .row.h-100 {
            height: auto;
            flex-grow: 1;
        }

        .sidebar-container {
            background-color: white;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
            min-height: 100%;
        }

        .sidebar-title {
            color: var(--brand-blue);
            font-weight: 800;
            padding: 1.5rem 1rem;
            border-bottom: 1px solid #eee;
            margin-bottom: 1rem;
        }

        .nav-link {
            color: #555 !important;
            font-weight: 500;
            padding: 0.8rem 1.5rem;
            transition: all 0.3s;
            border-left: 4px solid transparent;
        }

        .nav-link:hover {
            background-color: #f8f9fa;
            color: var(--brand-blue) !important;
            border-left-color: var(--brand-blue);
        }

        .nav-link.active {
            background-color: rgba(14, 43, 88, 0.05);
            color: var(--brand-blue) !important;
            border-left-color: var(--ulbs-red);
            font-weight: 700;
        }

        .nav-link i {
            width: 25px;
            text-align: center;
            margin-right: 10px;
        }

        .main-content {
            padding: 2rem;
            min-height: 100vh;
        }

        .page-title {
            color: var(--brand-blue-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

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

        .activity-timeline {
            padding: 1rem;
            max-height: 350px;
            overflow-y: auto;
        }

        .timeline-item {
            border-left: 2px solid var(--ulbs-red);
            padding-left: 15px;
            margin-bottom: 15px;
            position: relative;
        }

        .timeline-item::before {
            content: "";
            position: absolute;
            left: -6px;
            top: 5px;
            width: 10px;
            height: 10px;
            background: white;
            border: 2px solid var(--ulbs-red);
            border-radius: 50%;
        }

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
            border-color: var(--brand-blue);
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

        /* --- NEW STYLES FOR TRANSITION AND HOVER --- */
        .position-title-link {
            font-weight: bold;
            color: var(--brand-blue-dark); /* Initial dark color */
            text-decoration: none;
            transition: color 0.3s ease; /* Smooth transition */
            display: inline-block;
        }
        .position-title-link:hover {
            color: var(--ulbs-red); /* Hover color */
            text-decoration: underline;
        }

        .company-link {
            font-weight: 600;
            color: #777; /* Set initial color to a neutral gray */
            text-decoration: none;
            transition: color 0.3s ease; /* Smooth transition */
        }

        .company-link:hover {
            color: var(--ulbs-red); /* Hover color */
        }
        /* ------------------------------------------- */
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row">

        <div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
            <h5 class="sidebar-title">
                <i class="fa-solid fa-graduation-cap me-2"></i> Student Portal
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link active" href="${pageContext.request.contextPath}/Students">
                    <i class="fa-solid fa-table-columns"></i> Dashboard
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/StudentProfile">
                    <i class="fa-regular fa-id-card"></i> My Profile
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/InternshipPositions">
                    <i class="fa-solid fa-briefcase"></i> Internships
                </a>
                <a class="nav-link" href="#">
                    <i class="fa-solid fa-calendar-check"></i> Schedule
                </a>

                <div class="mt-3 border-top pt-3">
                    <form action="${pageContext.request.contextPath}/Logout" method="post" class="d-inline">
                        <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start">
                            <i class="fa-solid fa-right-from-bracket"></i> Logout
                        </button>
                    </form>
                </div>
            </div>
        </div>

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
                                <span class="stat-label">Academic Status</span>
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
                    <div class="stat-card card-grade">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value"><%= student.getGradeFormatted() %>
                                </h2>
                                <span class="stat-label">Last Grade</span>
                            </div>
                            <i class="fa-solid fa-chart-line stat-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-3 col-6">
                    <div class="stat-card card-enroll">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value" style="font-size: 1.4rem;">
                                    <%= student.getEnrolled() ? "Enrolled" : "Not Enrolled" %>
                                </h2>
                                <span class="stat-label">Status</span>
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
                                        <span class="badge bg-primary text-white"><%= userRole %></span>
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

                    <div class="card custom-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span><i class="fa-solid fa-file-signature me-2"></i> My Internship Applications</span>
                            <% if (myApplications != null) { %>
                            <span class="badge bg-light text-primary border"><%= totalApplicationsCount %> total</span>
                            <% } %>
                        </div>
                        <div class="card-body p-0">
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
                                        if ("Pending".equals(app.getStatus())) badgeClass = "status-pending";
                                        else if ("Accepted".equals(app.getStatus())) badgeClass = "status-accepted";
                                        else if ("Rejected".equals(app.getStatus())) badgeClass = "status-rejected";
                                        else if ("Interview".equals(app.getStatus())) badgeClass = "status-interview";

                                        String appliedDate = app.getAppliedAt() != null ? app.getAppliedAt().toString().substring(0, 10) : "N/A";
                                        String deadlineDate = app.getDeadline() != null ? app.getDeadline().toString().substring(0, 10) : "Open";
                                    %>
                                    <tr>
                                        <td class="ps-4">
                                            <a href="#" class="position-title-link"
                                               data-bs-toggle="modal" data-bs-target="#detailsModal_<%= app.getId() %>">
                                                <%= app.getPositionTitle() %>
                                            </a>
                                            <div class="small">
                                                <i class="fa-regular fa-building me-1 text-muted"></i>
                                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= app.getInternshipPositionId() %>"
                                                   class="company-link text-decoration-none">
                                                    <%= app.getCompanyName() %>
                                                </a>
                                            </div>
                                        </td>
                                        <td class="small text-muted"><%= appliedDate %>
                                        </td>
                                        <td>
                                            <span class="status-badge <%= badgeClass %>"><%= app.getStatus() %></span>
                                        </td>
                                        <td>
                                            <% if (app.getGrade() != null) { %>
                                            <span class="fw-bold text-dark"><%= app.getGrade() %></span>
                                            <% } else { %>
                                            <span class="text-muted">-</span>
                                            <% } %>
                                        </td>
                                        <td class="text-end pe-4">
                                            <button type="button" class="btn btn-sm btn-outline-primary"
                                                    data-bs-toggle="modal"
                                                    data-bs-target="#detailsModal_<%= app.getId() %>"
                                                    title="View Details">
                                                <i class="fa-regular fa-eye"></i>
                                            </button>

                                            <div class="modal fade text-start" id="detailsModal_<%= app.getId() %>"
                                                 tabindex="-1" aria-hidden="true">
                                                <div class="modal-dialog">
                                                    <div class="modal-content">
                                                        <div class="modal-header bg-light">
                                                            <h5 class="modal-title fw-bold">Application Details</h5>
                                                            <button type="button" class="btn-close"
                                                                    data-bs-dismiss="modal"></button>
                                                        </div>
                                                        <div class="modal-body p-4">
                                                            <div class="text-center mb-4">
                                                                <h4 class="fw-bold text-primary mb-1"><%= app.getPositionTitle() %>
                                                                </h4>
                                                                <p class="text-muted fw-bold">
                                                                    <i class="fa-solid fa-building me-2"></i>
                                                                    <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= app.getInternshipPositionId() %>"
                                                                       class="company-link text-muted text-decoration-none">
                                                                        <%= app.getCompanyName() %>
                                                                    </a>
                                                                </p>
                                                                <span class="status-badge <%= badgeClass %>"><%= app.getStatus() %></span>
                                                            </div>
                                                            <div class="mb-3">
                                                                <small class="text-uppercase text-muted fw-bold">Applied
                                                                    On</small>
                                                                <div class="text-dark"><i
                                                                        class="fa-regular fa-calendar-check me-2"></i> <%= appliedDate %>
                                                                </div>
                                                            </div>
                                                            <div class="mb-3">
                                                                <small class="text-uppercase text-muted fw-bold">Description</small>
                                                                <div class="bg-light p-3 rounded text-secondary small"><%= app.getDescription() %>
                                                                </div>
                                                            </div>
                                                            <div class="mb-3">
                                                                <small class="text-uppercase text-muted fw-bold">Requirements</small>
                                                                <div class="bg-light p-3 rounded text-secondary small"><%= app.getRequirements() %>
                                                                </div>
                                                            </div>
                                                            <div class="alert alert-light border d-flex justify-content-between m-0">
                                                                <span class="small fw-bold text-muted">Deadline:</span>
                                                                <span class="fw-bold text-danger"><%= deadlineDate %></span>
                                                            </div>
                                                        </div>
                                                        <div class="modal-footer border-0">
                                                            <button type="button" class="btn btn-secondary btn-sm"
                                                                    data-bs-dismiss="modal">Close
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
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

                                <a href="#"
                                   class="btn btn-action rounded-0 border-bottom-0 border-start-0 border-end-0 text-start w-100">
                                    <i class="fa-regular fa-envelope me-2"></i> Contact Faculty
                                </a>
                            </div>
                        </div>
                    </div>

                    <div class="card custom-card">
                        <div class="card-header">
                            <i class="fa-solid fa-clock-rotate-left me-2"></i> Recent Activity
                        </div>
                        <div class="card-body activity-timeline">
                            <% if (activities != null && !activities.isEmpty()) { %>
                            <% for (AccountActivityDto activity : activities) { %>
                            <div class="timeline-item">
                                <%
                                    String rawAction = activity.getAction();
                                    String prettyAction = rawAction.replaceAll("(?<=[a-z])(?=[A-Z])", " ");
                                %>
                                <div class="fw-bold text-dark small"><%= prettyAction %>
                                </div>
                                <div class="text-muted" style="font-size: 0.75rem;">
                                    <i class="fa-regular fa-clock me-1"></i>
                                    <%= activity.getActionTime() != null ? activity.getActionTime().toString().substring(0, 16) : "Just now" %>
                                </div>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="text-center py-4 text-muted small">
                                <i class="fa-solid fa-bed fa-2x mb-2 opacity-25"></i>
                                <p>No recent activity found.</p>
                            </div>
                            <% } %>
                        </div>
                    </div>
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
                <p class="mb-0">Are you sure you want to **replace** your current CV with the new file?</p>
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
                <p class="mb-0">Are you sure you want to **permanently delete** your CV? This cannot be undone.</p>
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
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>