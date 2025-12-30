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
            height: 790px; /* Balanced height for the dashboard */
            overflow-y: auto;
        }

        .scrollable-list {
            height: 400px;
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

        /* --- Buttons & Transitions --- */
        .btn-manage-gear {
            background-color: #f8f9fa;
            color: #6c757d;
            border: 1px solid #e9ecef;
            width: 32px;
            height: 32px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: 0.2s;
        }

        .btn-manage-gear:hover {
            background-color: var(--brand-blue);
            color: white;
            transform: rotate(45deg);
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
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
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
        }

        .status-badge {
            font-size: 0.75rem;
            padding: 0.3em 0.7em;
            border-radius: 50px;
            font-weight: 600;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }

        .status-interview {
            background-color: #cff4fc;
            color: #055160;
        }

        .status-accepted {
            background-color: #d1e7dd;
            color: #0f5132;
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
                    <div class="stat-card card-red"><h2 class="stat-value">0</h2><span
                            class="stat-label">New Messages</span><i class="fa-regular fa-comment-dots stat-icon"></i>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card custom-card mb-4 border-0 shadow-sm overflow-hidden">
                        <div class="row g-0">
                            <div class="col-md-9 p-4">
                                <h5 class="fw-bold mb-3">Company Profile Overview</h5>
                                <p class="text-muted small mb-4"><%= company.getCompDescription() != null ? company.getCompDescription() : "Complete your profile to attract more candidates." %>
                                </p>
                                <div class="row g-3">
                                    <div class="col-sm-4"><span class="info-label">Account</span><span
                                            class="info-value text-truncate d-block"><%= userAccount.getEmail() %></span>
                                        <span class="badge bg-light text-muted border ms-1"
                                              style="font-size: 0.65rem; vertical-align: middle;">
                                              <i class="fa-solid fa-lock me-1"></i>Private
                                        </span>
                                    </div>
                                    <div class="col-sm-4"><span class="info-label">Contact</span><span
                                            class="info-value text-truncate d-block"><%= (company.getContactEmail() != null && !company.getContactEmail().isEmpty()) ? company.getContactEmail() : "Not Set" %></span>
                                    </div>
                                    <div class="col-sm-4"><span class="info-label">Website</span><a
                                            href="<%= company.getWebsite() %>" target="_blank"
                                            class="info-value text-decoration-none text-primary d-block text-truncate"><%= company.getWebsite() != null ? company.getWebsite() : "Not Set" %>
                                    </a></div>
                                </div>
                                <div class="mt-4">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <span class="small fw-bold text-muted">Profile Progress</span>
                                        <span class="small fw-bold <%= completionTextColor %>"><%= completionText %> (<%= completionScore %>%)</span>
                                    </div>
                                    <div class="progress" style="height: 8px; border-radius: 10px;">
                                        <div class="progress-bar <%= completionBarClass %>"
                                             style="width: <%= completionScore %>%"></div>
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
                        <div class="card-header d-flex justify-content-between align-items-center"><span
                                class="fw-bold"><i class="fa-solid fa-user-check me-2"></i> Received Applications</span><span
                                class="badge bg-light text-primary border"><%= totalAppsCount %> Total</span></div>
                        <div class="card-body p-0">
                            <% if (applications != null && !applications.isEmpty()) { %>
                            <div class="applications-scroll-area">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-light sticky-top" style="z-index: 5; top: 0;">
                                        <tr>
                                            <th class="ps-4">Candidate</th>
                                            <th>Position</th>
                                            <th>Status</th>
                                            <th class="text-end pe-4">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <% for (InternshipApplicationDto app : applications) {
                                            String badgeClass = "status-pending";
                                            if ("Accepted".equals(app.getStatus())) badgeClass = "status-accepted";
                                            else if ("Interview".equals(app.getStatus()))
                                                badgeClass = "status-interview";
                                            String pfpUrl = request.getContextPath() + "/ProfilePicture?id=" + app.getStudentId() + "&targetRole=Student";
                                            String fallbackUrl = "https://ui-avatars.com/api/?name=" + app.getStudentName().replace(" ", "+") + "&background=0E2B58&color=fff";
                                        %>
                                        <tr>
                                            <td class="ps-4">
                                                <a href="StudentProfile?id=<%= app.getStudentId() %>"
                                                   class="student-link">
                                                    <img src="<%= pfpUrl %>"
                                                         onerror="this.onerror=null;this.src='<%= fallbackUrl %>';"
                                                         class="student-avatar-small">
                                                    <div><%= app.getStudentName() %>
                                                    </div>
                                                </a>
                                            </td>
                                            <td class="small text-muted fw-bold"><%= app.getPositionTitle() %>
                                            </td>
                                            <td><span
                                                    class="status-badge <%= badgeClass %>"><%= app.getStatus() %></span>
                                            </td>
                                            <td class="text-end pe-4">
                                                <button class="btn btn-sm btn-chat rounded-pill px-3"
                                                        onclick="alert('Chat with <%= app.getStudentName() %>')"><i
                                                        class="fa-regular fa-comments me-1"></i> Chat
                                                </button>
                                            </td>
                                        </tr>
                                        <% } %>
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
                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= request.getAttribute("facultyId") %>"
                                   class="btn btn-action rounded-0 border-bottom-0 border-start-0 border-end-0">
                                    <i class="fa-regular fa-envelope me-2"></i> Contact Faculty
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="card custom-card mb-4">
                        <div class="card-header d-flex justify-content-between align-items-center"><span
                                class="fw-bold"><i class="fa-solid fa-list-ul me-2"></i> Your Positions</span>
                            <button class="btn btn-sm btn-primary rounded-circle"
                                    style="width: 28px; height: 28px; padding: 0;"><i class="fa-solid fa-plus"></i>
                            </button>
                        </div>
                        <div class="scrollable-list">
                            <% if (myPositions != null && !myPositions.isEmpty()) { %>
                            <% for (InternshipPositionDto pos : myPositions) { %>
                            <div class="position-item d-flex justify-content-between align-items-center">
                                <div><span class="position-title"><%= pos.getTitle() %></span><span
                                        class="position-meta"><i
                                        class="fa-regular fa-calendar me-1"></i>Deadline: <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "N/A" %></span>
                                </div>
                                <button class="btn-manage-gear rounded-circle" title="Settings"><i
                                        class="fa-solid fa-gear"></i></button>
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

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>