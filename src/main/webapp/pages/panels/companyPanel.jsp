<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.*" %>
<%
    // 1. Retrieve Data
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");
    UserAccountDto userAccount = (UserAccountDto) request.getAttribute("userAccount");

    // 2. Retrieve Lists (NOW CORRECTLY TYPED AS DTOs)
    List<AccountActivityDto> activities = (List<AccountActivityDto>) request.getAttribute("activities");

    // FIX: Changed from InternshipPosition (Entity) to InternshipPositionDto
    List<InternshipPositionDto> myPositions = (List<InternshipPositionDto>) request.getAttribute("myPositions");

    List<InternshipApplicationDto> applications = (List<InternshipApplicationDto>) request.getAttribute("applications");

    // Session Data
    String userEmail = (String) session.getAttribute("userEmail");
    String userRole = (String) session.getAttribute("userRole");

    if (company == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
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

    <style>
        :root {
            --brand-blue: #0E2B58;
            --brand-blue-dark: #071a38;
            --ulbs-red: #A30B0B;
            --bg-light: #f4f7f6;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Segoe UI', Roboto, "Helvetica Neue", Arial, sans-serif;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* --- Sidebar --- */
        .sidebar-container {
            background-color: white;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
            min-height: calc(100vh - 85px);
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
        }

        .page-title {
            color: var(--brand-blue-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        /* --- Stats Cards --- */
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
            opacity: 0.05;
            color: black;
        }

        /* --- Custom Cards & Lists --- */
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
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        /* Scrollable List Container */
        .scrollable-list {
            padding: 0;
            max-height: 350px;
            overflow-y: auto;
        }

        .scrollable-list::-webkit-scrollbar {
            width: 6px;
        }

        .scrollable-list::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 4px;
        }

        .scrollable-list::-webkit-scrollbar-thumb {
            background: var(--brand-blue);
            border-radius: 4px;
        }

        /* Position Item Style */
        .position-item {
            padding: 1rem;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
        }

        .position-item:last-child {
            border-bottom: none;
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

        /* Activity Timeline Items */
        .timeline-item {
            padding: 10px 15px;
            border-left: 2px solid var(--ulbs-red);
            margin: 15px;
            position: relative;
        }

        .timeline-item::before {
            content: "";
            position: absolute;
            left: -6px;
            top: 15px;
            width: 10px;
            height: 10px;
            background: white;
            border: 2px solid var(--ulbs-red);
            border-radius: 50%;
        }

        /* Student Application Table */
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

        .btn-chat:hover {
            background-color: #bbdefb;
        }

        /* Status Badges */
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

        <div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
            <h5 class="sidebar-title">
                <i class="fa-solid fa-building me-2"></i> Company Portal
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link active" href="${pageContext.request.contextPath}/CompanyDashboard">
                    <i class="fa-solid fa-table-columns"></i> Dashboard
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/CompanyProfile">
                    <i class="fa-regular fa-id-card"></i> Company Profile
                </a>
                <a class="nav-link" href="#">
                    <i class="fa-solid fa-user-friends"></i> Enrolled Interns
                </a>
                <a class="nav-link" href="#">
                    <i class="fa-regular fa-comments"></i> Chats
                </a>
                <a class="nav-link" href="#">
                    <i class="fa-solid fa-briefcase"></i> Positions
                </a>

                <div class="mt-5 border-top pt-3">
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
                    <h1 class="h2 page-title">Welcome, <%= company.getName() %>!</h1>
                    <p class="text-muted mb-0">
                        <i class="fa-solid fa-globe me-1"></i> <%= company.getWebsite() %>
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
                                <div class="col-md-8">
                                    <h5 class="fw-bold text-dark">Company Profile</h5>
                                    <p class="text-muted small"><%= company.getCompDescription() %>
                                    </p>
                                </div>
                                <div class="col-md-4 text-end">
                                    <button class="btn btn-outline-primary btn-sm">
                                        <i class="fa-solid fa-pen-to-square me-1"></i> Edit Details
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="card custom-card">
                        <div class="card-header">
                            <span><i class="fa-solid fa-user-check me-2"></i> Received Applications</span>
                            <span class="badge bg-light text-primary border"><%= totalAppsCount %> Pending</span>
                        </div>
                        <div class="card-body p-0">
                            <% if (applications != null && !applications.isEmpty()) { %>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="bg-light">
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
                                        String avatarUrl = "https://ui-avatars.com/api/?name=Student+" + app.getStudentId() + "&background=random&size=100";
                                    %>
                                    <tr>
                                        <td class="ps-4">
                                            <a href="<%= profileLink %>" class="student-link">
                                                <img src="<%= avatarUrl %>" alt="Avatar" class="student-avatar-small">
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
                            <% } else { %>
                            <div class="text-center py-5">
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

                    <div class="card custom-card">
                        <div class="card-header">
                            <i class="fa-solid fa-clock-rotate-left me-2"></i> Account Activity
                        </div>
                        <div class="scrollable-list">
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
                                    <%= activity.getActionTime() != null ?
                                            activity.getActionTime().toString().substring(0, 16) : "Just now" %>
                                </div>
                            </div>
                            <% } %>
                            <% } else { %>
                            <div class="text-center py-4 text-muted small">
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>