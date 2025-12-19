<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.*" %>
<%
    // 1. Retrieve Data
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");
    UserAccountDto userAccount = (UserAccountDto) request.getAttribute("userAccount");
    List<AccountActivityDto> activities = (List<AccountActivityDto>) request.getAttribute("activities");
    List<InternshipPositionDto> myPositions = (List<InternshipPositionDto>) request.getAttribute("myPositions");
    List<InternshipApplicationDto> applications = (List<InternshipApplicationDto>) request.getAttribute("applications");

    // Session Data
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    if (company == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }

    // --- Profile Completion Calculation ---
    int completionScore = 0;
    if (company.getName() != null && !company.getName().trim().isEmpty()) completionScore += 20;
    if (company.getWebsite() != null && !company.getWebsite().trim().isEmpty() && !company.getWebsite().equals("N/A")) completionScore += 20;
    if (company.getCompDescription() != null && !company.getCompDescription().trim().isEmpty()) completionScore += 20;
    if (company.getBiography() != null && !company.getBiography().trim().isEmpty()) completionScore += 20;
    if (company.hasProfilePic()) completionScore += 20;

    // --- Determine Color Schemes ---
    String completionText;
    String completionBarClass;
    String completionTextColor;

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
    } else {
        completionText = "Needs Attention";
        completionBarClass = "bg-danger";
        completionTextColor = "text-danger";
    }

    // Calculate simple stats
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
        /* --- Stat Cards (Unique to Dashboard) --- */
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
            opacity: 0.3;
            color: black;
        }

        /* --- Application Table & Candidates --- */
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

        .btn-chat {
            background-color: #e3f2fd;
            color: #0d47a1;
            border: 1px solid #bbdefb;
            font-size: 0.85rem;
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

        .scrollable-list {
            /* Set height to fit roughly 1.5 - 2 items */
            height: 160px;
            overflow-y: auto;
            position: relative;
            border-bottom-left-radius: 8px;
            border-bottom-right-radius: 8px;
        }

        /* Custom Scrollbar for the Positions List */
        .scrollable-list::-webkit-scrollbar {
            width: 5px;
        }

        .scrollable-list::-webkit-scrollbar-track {
            background: #f8f9fa;
        }

        .scrollable-list::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 10px;
        }

        .scrollable-list::-webkit-scrollbar-thumb:hover {
            background: var(--brand-blue);
        }

        /* --- Positions Mini-List --- */
        .position-item {
            padding: 1rem;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
        }

        .position-item:hover {
            background-color: #fafafa;
        }

        .position-title {
            font-weight: 600;
            color: var(--brand-blue-dark);
            display: block;
        }

        .position-meta {
            font-size: 0.85rem;
            color: #777;
        }

        .profile-progress {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--brand-blue-dark);
            margin-bottom: 0.5rem;
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
                    <p class="text-muted mb-0">
                        <i class="fa-solid fa-industry me-1"></i> Company
                    </p>
                </div>
                <div class="d-none d-md-block text-end">
                    <span class="badge bg-light text-dark border">
                        <i class="fa-regular fa-clock me-1"></i> <%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date()) %>
                    </span>
                </div>
            </div>

            <div class="row mb-4 g-3">
                <div class="col-md-4">
                    <div class="stat-card card-blue">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value"><%= activePositionsCount %>
                                </h2>
                                <span class="stat-label">Active Positions</span>
                            </div>
                            <i class="fa-solid fa-briefcase stat-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card card-teal">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value"><%= totalAppsCount %>
                                </h2>
                                <span class="stat-label">Total Applications</span>
                            </div>
                            <i class="fa-solid fa-file-contract stat-icon"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card card-red">
                        <div class="d-flex justify-content-between">
                            <div>
                                <h2 class="stat-value">0</h2> <span class="stat-label">New Messages</span>
                            </div>
                            <i class="fa-regular fa-comment-dots stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">

                <div class="col-lg-8">

                    <div class="card custom-card mb-4">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-9">
                                    <h5 class="fw-bold text-dark mb-2">Company Profile Overview</h5>

                                    <p class="text-muted small mb-3">
                                        <%= company.getCompDescription() != null ? company.getCompDescription() : "Set a short description in your profile." %>
                                    </p>

                                    <div class="row g-2 mb-3">
                                        <div class="col-sm-6">
                                            <p class="text-muted small mb-0">
                                                <i class="fa-solid fa-envelope me-1 text-secondary"></i>
                                                <span class="fw-bold">Email:</span> <%= userAccount.getEmail() %>
                                            </p>
                                        </div>

                                        <div class="col-sm-6">
                                            <p class="text-muted small mb-0">
                                                <i class="fa-solid fa-link me-1 text-secondary"></i>
                                                <span class="fw-bold">Website:</span>
                                                <a href="<%= company.getWebsite() %>" target="_blank" class="text-decoration-none">
                                                    <%= company.getWebsite() != null ? company.getWebsite() : "Not Set" %>
                                                </a>
                                            </p>
                                        </div>
                                    </div>

                                    <div class="profile-progress d-flex justify-content-between align-items-center">
                                        <span>Profile Completion:</span>
                                        <span class="fw-bold <%= completionTextColor %>">
                                            <%= completionText %> (<%= completionScore %>%)
                                        </span>
                                    </div>
                                    <div class="progress mb-3" role="progressbar" aria-label="Profile Completion" aria-valuenow="<%= completionScore %>" aria-valuemin="0" aria-valuemax="100" style="height: 10px;">
                                        <div class="progress-bar <%= completionBarClass %>" style="width: <%= completionScore %>%"></div>
                                    </div>

                                </div>
                                <div class="col-md-3 text-end d-flex flex-column justify-content-center">
                                    <a href="${pageContext.request.contextPath}/CompanyProfile" class="btn btn-outline-primary btn-sm mt-3 mt-md-0">
                                        <i class="fa-solid fa-pen-to-square me-1"></i> Edit Profile
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card custom-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <span><i class="fa-solid fa-user-check me-2"></i> Received Applications</span>
                            <span class="badge bg-light text-primary border"><%= totalAppsCount %> Pending</span>
                        </div>
                        <div class="card-body p-0">
                            <% if (applications != null && !applications.isEmpty()) { %>
                            <%-- This wrapper controls the 400px height and vertical scrolling --%>
                            <div class="applications-scroll-area" style="height: 400px; overflow-y: auto; position: relative;">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <%-- sticky-top keeps the header visible while you scroll --%>
                                        <thead class="bg-light sticky-top" style="z-index: 5; top: 0;">
                                        <tr>
                                            <th class="ps-4">Candidate</th>
                                            <th>Position Applied</th>
                                            <th>Status</th>
                                            <th class="text-end pe-4">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <% for (InternshipApplicationDto app : applications) {
                                            String badgeClass = "status-pending";
                                            if ("Accepted".equals(app.getStatus())) badgeClass = "status-accepted";
                                            else if ("Interview".equals(app.getStatus())) badgeClass = "status-interview";

                                            String profileLink = "StudentProfile?id=" + app.getStudentId();

                                            // DYNAMIC PROFILE PICTURE LOGIC:
                                            // 1. Path to your ProfilePicture servlet
                                            String pfpUrl = request.getContextPath() + "/ProfilePicture?id=" + app.getStudentId() + "&targetRole=Student";
                                            // 2. UI-Avatar fallback if the student doesn't have a picture
                                            String fallbackUrl = "https://ui-avatars.com/api/?name=Student+" + app.getStudentId() + "&background=0E2B58&color=fff";
                                        %>
                                        <tr>
                                            <td class="ps-4">
                                                <a href="<%= profileLink %>" class="student-link">
                                                    <%-- onerror handles the fallback if the servlet returns a 404 or broken image --%>
                                                    <img src="<%= pfpUrl %>"
                                                         onerror="this.onerror=null;this.src='<%= fallbackUrl %>';"
                                                         alt="Avatar" class="student-avatar-small">
                                                    <div>
                                                        Student #<%= app.getStudentId() %>
                                                    </div>
                                                </a>
                                            </td>
                                            <td class="small text-muted fw-bold">
                                                <%= app.getPositionTitle() %>
                                            </td>
                                            <td>
                                                <span class="status-badge <%= badgeClass %>"><%= app.getStatus() %></span>
                                            </td>
                                            <td class="text-end pe-4">
                                                <button class="btn btn-sm btn-chat rounded-pill px-3"
                                                        onclick="alert('Opening chat with Student #<%= app.getStudentId() %>')">
                                                    <i class="fa-regular fa-comments me-1"></i> Chat
                                                </button>
                                            </td>
                                        </tr>
                                        <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <% } else { %>
                            <%-- Matches the 400px height for empty states to keep the layout consistent --%>
                            <div class="text-center py-5 d-flex flex-column justify-content-center" style="height: 500px;">
                                <i class="fa-regular fa-folder-open fa-3x text-muted opacity-25 mb-3"></i>
                                <p class="text-muted">No applications received yet.</p>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">

                    <div class="card custom-card">
                        <div class="card-header">
                            <span><i class="fa-solid fa-list-ul me-2"></i> Your Positions</span>
                            <button class="btn btn-sm btn-primary rounded-circle"
                                    style="width: 30px; height: 30px; padding: 0;">
                                <i class="fa-solid fa-plus"></i>
                            </button>
                        </div>
                        <div class="scrollable-list">
                            <% if (myPositions != null && !myPositions.isEmpty()) { %>
                            <% for (InternshipPositionDto pos : myPositions) { %>
                            <div class="position-item d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="position-title">
                                        <%= pos.getTitle() %>
                                    </span>
                                    <span class="position-meta">
                                        <i class="fa-regular fa-calendar me-1"></i>
                                        Deadline: <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "N/A" %>
                                    </span>
                                </div>
                                <button class="btn btn-sm btn-outline-secondary" title="Manage Details">
                                    <i class="fa-solid fa-gear"></i>
                                </button>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="p-4 text-center text-muted small">
                                No positions posted yet.
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <jsp:include page="../blocks/activitySidebar.jsp" />
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>