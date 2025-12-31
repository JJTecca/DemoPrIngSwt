<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.*" %>
<%
    // 1. Retrieve Data from Servlet
    UserAccountDto userAccount = (UserAccountDto) request.getAttribute("userAccount");
    CompanyInfoDto facultyDept = (CompanyInfoDto) request.getAttribute("facultyDept");

    List<StudentInfoDto> allStudents = (List<StudentInfoDto>) request.getAttribute("allStudents");
    if (allStudents == null) allStudents = new ArrayList<>();

    List<InternshipPositionDto> tutoringPositions = (List<InternshipPositionDto>) request.getAttribute("tutoringPositions");
    if (tutoringPositions == null) tutoringPositions = new ArrayList<>();

    if (userAccount == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }

    // 2. Stats
    long availableCount = allStudents.stream()
            .filter(s -> "Available".equalsIgnoreCase(s.getStatus()))
            .count();

    long acceptedCount = allStudents.stream()
            .filter(s -> "Accepted".equalsIgnoreCase(s.getStatus()))
            .count();
    int activeTutoringCount = tutoringPositions.size();

    // 3. Profile Completion Calculation (Matching Company Logic)
    int completionScore = 0;
    if (facultyDept != null) {
        if (facultyDept.getName() != null && !facultyDept.getName().trim().isEmpty()) completionScore += 20;
        if (facultyDept.getWebsite() != null && !facultyDept.getWebsite().trim().isEmpty() && !facultyDept.getWebsite().equals("N/A"))
            completionScore += 20;
        if (facultyDept.getCompDescription() != null && !facultyDept.getCompDescription().trim().isEmpty())
            completionScore += 20;
        if (facultyDept.getBiography() != null && !facultyDept.getBiography().trim().isEmpty()) completionScore += 20;
        if (facultyDept.hasProfilePic()) completionScore += 20;
    }

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
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Faculty Dashboard - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">
    <style>
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
            opacity: 0.2;
            color: black;
        }

        .main-scroll-area {
            height: 665px;
            overflow-y: auto;
            position: relative;
        }

        .tutoring-scroll-list {
            height: 360px;
            overflow-y: auto;
            position: relative;
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

        .status-badge {
            font-size: 0.75rem;
            padding: 0.3em 0.7em;
            border-radius: 50px;
            font-weight: 600;
        }

        .status-accepted {
            background-color: #d1e7dd;
            color: #0f5132;
        }

        .status-pending {
            background-color: #fff3cd;
            color: #856404;
        }

        .status-interview {
            background-color: #cff4fc;
            color: #055160;
        }

        .status-rejected {
            background-color: #f8d7da;
            color: #721c24;
        }

        .btn-plus-transition {
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            border: none;
        }

        .btn-plus-transition:hover {
            background-color: var(--brand-blue-dark) !important;
            transform: scale(1.15);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
            color: white;
        }

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

        .btn-zinc-utility {
            background-color: #f1f3f5;
            color: #495057;
            border: 1px solid #ced4da;
            font-weight: 600;
        }

        .btn-zinc-utility:hover {
            background-color: #e9ecef;
            color: #212529;
        }

        .btn-import-standout {
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white;
            border: none;
            font-weight: 700;
            padding: 0.5rem 1.25rem;
            border-radius: 50px;
            box-shadow: 0 4px 12px rgba(14, 43, 88, 0.2);
            transition: all 0.3s ease;
            text-decoration: none;
            font-size: 0.85rem;
        }

        .btn-import-standout:hover {
            transform: scale(1.05);
            color: white;
        }

        .profile-progress {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--brand-blue-dark);
            margin-bottom: 0.5rem;
        }

        .position-item {
            padding: 1rem;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
        }

        .position-item:hover {
            background-color: #fafafa;
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

        .pos-status-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }

        .pos-status-open {
            background-color: #d1e7dd;
            color: #0f5132;
            border: 1px solid #badbcc;
        }

        .pos-status-closed {
            background-color: #e2e3e5;
            color: #41464b;
            border: 1px solid #d3d3d4;
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
            border-radius: 50%;
        }

        .btn-manage-eye:hover {
            background-color: var(--brand-blue);
            color: white;
            transform: scale(1.1);
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <jsp:include page="../blocks/facultySidebar.jsp"/>

        <div class="col-md-9 col-lg-10 main-content">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h1 class="h2 page-title">Welcome, <%= userAccount.getUsername() %>!</h1>
                    <p class="text-muted mb-0"><i class="fa-solid fa-building-columns me-1"></i> Faculty Panel</p>
                </div>
                <div class="d-none d-md-block text-end">
                    <span class="badge bg-light text-dark border">
                        <i class="fa-regular fa-clock me-1"></i> <%= new java.text.SimpleDateFormat("MMMM dd, yyyy").format(new java.util.Date()) %>
                    </span>
                </div>
            </div>

            <%-- Stats Row --%>
            <div class="row mb-4 g-3">
                <div class="col-md-4">
                    <div class="stat-card card-blue">
                        <div class="d-flex justify-content-between">
                            <div><h2 class="stat-value"><%= availableCount %>
                            </h2><span class="stat-label">Available Students</span></div>
                            <i class="fa-solid fa-user-graduate stat-icon"></i></div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card card-teal">
                        <div class="d-flex justify-content-between">
                            <div><h2 class="stat-value"><%= acceptedCount %>
                            </h2><span class="stat-label">Accepted Students</span></div>
                            <i class="fa-solid fa-file-signature stat-icon"></i></div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card card-red">
                        <div class="d-flex justify-content-between">
                            <div><h2 class="stat-value"><%= activeTutoringCount %>
                            </h2><span class="stat-label">Tutoring Positions</span></div>
                            <i class="fa-solid fa-chalkboard-user stat-icon"></i></div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="card shadow-sm border-0 mb-4 overflow-hidden" style="background-color: #f8faff; border: 1px solid #e1e9f4 !important;">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-9">
                                    <div class="d-flex align-items-center mb-2">
                                        <h5 class="fw-bold text-dark m-0">Department Profile Overview</h5>
                                        <span class="badge ms-2" style="background-color: #e8f0fe; color: #1967d2; font-size: 0.7rem; border: 1px solid #c2d7fa;">
                                <i class="fa-solid fa-shield-check me-1"></i> FACULTY ADMIN
                            </span>
                                    </div>

                                    <p class="text-muted small mb-3">
                                        <%= (facultyDept != null && facultyDept.getCompDescription() != null && !facultyDept.getCompDescription().isEmpty())
                                                ? facultyDept.getCompDescription() : "Set a short description in your profile." %>
                                    </p>

                                    <div class="row g-3 mb-3">
                                        <div class="col-md-5">
                                            <div class="info-label">Official Name</div>
                                            <div class="info-value fw-bold text-truncate">
                                                <%= (facultyDept != null && facultyDept.getName() != null) ? facultyDept.getName() : "Faculty of Engineering" %>
                                            </div>
                                        </div>
                                        <div class="col-md-7">
                                            <div class="info-label">
                                                Account Email
                                                <span class="ms-1 text-danger" title="This email is only visible to authenticated staff members.">
                                        <i class="fa-solid fa-lock" style="font-size: 0.75rem;"></i>
                                        <small style="text-transform: none; font-weight: 500;">Private / Internal</small>
                                    </span>
                                            </div>
                                            <div class="info-value text-truncate d-flex align-items-center">
                                                <%= userAccount.getEmail() %>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="profile-progress d-flex justify-content-between align-items-center">
                                        <span class="small fw-bold text-muted">Profile Completion:</span>
                                        <span class="fw-bold small <%= completionTextColor %>">
                                <%= completionText %> (<%= completionScore %>%)
                            </span>
                                    </div>
                                    <div class="progress" style="height: 10px; background-color: #e9ecef;">
                                        <div class="progress-bar <%= completionBarClass %>" style="width: <%= completionScore %>%"></div>
                                    </div>
                                </div>

                                <div class="col-md-3 text-end d-flex flex-column justify-content-center border-start ps-4">
                                    <div class="mb-3 d-none d-md-block">
                                        <i class="fa-solid fa-user-gear fa-3x text-light-emphasis opacity-25"></i>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/CompanyProfile" class="btn btn-brand btn-sm">
                                        <i class="fa-solid fa-sliders me-1"></i> Configure
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Student Roster --%>
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                            <span class="fw-bold text-dark"><i class="fa-solid fa-users me-2"></i> Student Roster</span>
                            <a href="${pageContext.request.contextPath}/ImportStudents" class="btn-import-standout">
                                <i class="fa-solid fa-file-import me-2"></i> Import Students
                            </a>
                        </div>
                        <div class="card-body p-0">
                            <div class="main-scroll-area">
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="bg-light sticky-top" style="z-index: 5;">
                                        <tr>
                                            <th class="ps-4">Student</th>
                                            <th>Status</th>
                                            <th>Study Grade</th>
                                            <th class="text-end pe-4">Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <% if (!allStudents.isEmpty()) {
                                            for (StudentInfoDto student : allStudents) {
                                                String pfp = request.getContextPath() + "/ProfilePicture?id=" + student.getId() + "&targetRole=Student";
                                                String fb = "https://ui-avatars.com/api/?name=" + student.getFullName() + "&background=0E2B58&color=fff";
                                        %>
                                        <tr>
                                            <td class="ps-4">
                                                <a href="StudentProfile?id=<%= student.getId() %>" class="student-link">
                                                    <img src="<%= pfp %>"
                                                         onerror="this.onerror=null;this.src='<%= fb %>';"
                                                         class="student-avatar-small">
                                                    <div><%= student.getFullName() %>
                                                    </div>
                                                </a>
                                            </td>
                                            <td>
                                                <%
                                                    String statusValue = (student.getStatus() != null) ? student.getStatus() : "Pending";
                                                    String statusClass = "status-pending";
                                                    if ("Accepted".equalsIgnoreCase(statusValue) || "Enrolled".equalsIgnoreCase(statusValue))
                                                        statusClass = "status-accepted";
                                                    else if ("Interview".equalsIgnoreCase(statusValue))
                                                        statusClass = "status-interview";
                                                    else if ("Rejected".equalsIgnoreCase(statusValue))
                                                        statusClass = "status-rejected";
                                                %>
                                                <span class="status-badge <%= statusClass %>"><%= statusValue %></span>
                                            </td>
                                            <td class="fw-bold text-muted small"><%= student.getGradeFormatted() %>
                                            </td>
                                            <td class="text-end pe-4">
                                                <button class="btn btn-sm btn-chat rounded-pill px-3"
                                                        onclick="alert('Chat with <%= student.getFullName() %>')">
                                                    <i class="fa-regular fa-comments me-1"></i> Chat
                                                </button>
                                            </td>
                                        </tr>
                                        <% }
                                        } else { %>
                                        <tr>
                                            <td colspan="4" class="text-center py-5 text-muted">No students found.</td>
                                        </tr>
                                        <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Right Column --%>
                <div class="col-lg-4">
                    <div class="card shadow-sm border-0 mb-4">
                        <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                            <h6 class="fw-bold m-0"><i class="fa-solid fa-list-ul me-2"></i> Tutoring Positions</h6>
                            <a href="${pageContext.request.contextPath}/PostPosition"
                               class="btn btn-sm btn-primary rounded-circle d-flex align-items-center justify-content-center btn-plus-transition"
                               style="width: 25px; height: 25px; padding: 0;"
                               title="Post New Position">
                                <i class="fa-solid fa-plus" style="font-size: 0.75rem;"></i>
                            </a>
                        </div>
                        <div class="tutoring-scroll-list">
                            <% if (!tutoringPositions.isEmpty()) {
                                for (InternshipPositionDto pos : tutoringPositions) { %>
                            <div class="position-item d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="position-title small fw-bold"><%= pos.getTitle() %></span>
                                    <div class="d-flex align-items-center gap-2 mt-1">
                                        <%
                                            String status = pos.getStatus();
                                            String posBadgeClass = "pos-status-pending";
                                            if ("Open".equalsIgnoreCase(status)) posBadgeClass = "pos-status-open";
                                            else if ("Closed".equalsIgnoreCase(status)) posBadgeClass = "pos-status-closed";
                                        %>
                                        <span class="pos-status-badge <%= posBadgeClass %>">
                                          <%= status %>
                                        </span>
                                        <span class="text-muted" style="font-size: 0.75rem;">
                                         <i class="fa-regular fa-calendar me-1"></i>
                                         <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "N/A" %>
                                         </span>
                                    </div>
                                </div>
                                <button class="btn-manage-eye" data-bs-toggle="modal" data-bs-target="#applyModal<%= pos.getId() %>">
                                    <i class="fa-solid fa-eye"></i>
                                </button>
                            </div>

                            <%-- POPUP: Exact structure from internshipPositions.jsp --%>
                            <div class="modal fade" id="applyModal<%= pos.getId() %>" tabindex="-1" aria-hidden="true">
                                <div class="modal-dialog modal-lg modal-dialog-scrollable">
                                    <div class="modal-content border-0 shadow-lg">
                                        <div class="modal-header border-0 pb-0">
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body p-5 pt-0">
                                            <div class="text-center mb-4">
                                                <div class="mb-2">
                                                  <span class="pos-status-badge <%= posBadgeClass %>" style="font-size: 0.75rem; padding: 4px 12px;">
                                                    <%= status %> Position
                                                  </span>
                                                </div>
                                                <h3 class="fw-bold"><%= pos.getTitle() %></h3>
                                                <p class="text-muted"><%= (facultyDept != null) ? facultyDept.getName() : "Faculty Dept" %></p>
                                            </div>

                                            <div class="row">
                                                <div class="col-md-7">
                                                    <h6 class="fw-bold text-uppercase text-muted small">Description</h6>
                                                    <p class="small text-secondary"><%= pos.getDescription() %></p>
                                                    <h6 class="fw-bold text-uppercase text-muted small mt-4">Requirements</h6>
                                                    <p class="small text-secondary"><%= pos.getRequirements() != null ? pos.getRequirements() : "No specific requirements." %></p>
                                                </div>

                                                <div class="col-md-5 border-start">
                                                    <h6 class="fw-bold text-uppercase text-muted small mb-3"><i class="fa-solid fa-user-graduate me-2"></i>Candidates</h6>
                                                    <div class="applicant-scroll">
                                                        <% if (pos.getApplicants() != null && !pos.getApplicants().isEmpty()) { %>
                                                        <% for (com.internshipapp.common.InternshipApplicationDto app : pos.getApplicants()) { %>
                                                        <div class="applicant-item">
                                                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= app.getStudentId() %>&targetRole=Student"
                                                                 onerror="this.src='https://ui-avatars.com/api/?name=<%= app.getStudentName() %>&background=random';"
                                                                 class="applicant-pfp">
                                                            <div class="overflow-hidden">
                                                                <a href="${pageContext.request.contextPath}/StudentProfile?id=<%= app.getStudentId() %>"
                                                                   class="text-decoration-none text-dark fw-bold small d-block text-truncate">
                                                                    <%= app.getStudentName() %>
                                                                </a>
                                                                <span class="badge bg-light text-dark x-small" style="font-size: 0.65rem;"><%= app.getStatus() %></span>
                                                            </div>
                                                        </div>
                                                        <% } %>
                                                        <% } else { %>
                                                        <div class="text-center py-4 text-muted small">No applications yet.</div>
                                                        <% } %>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="alert alert-light border mt-4 m-0">
                                                <div class="d-flex justify-content-between small">
                                                    <span><i class="fa-solid fa-circle-info me-2 text-primary"></i> <strong>Deadline:</strong> <%= pos.getDeadline() %></span>
                                                    <span><i class="fa-solid fa-users me-2 text-primary"></i> <strong>Applications:</strong> <%= (pos.getApplicationsCount() != null ? pos.getApplicationsCount() : 0) %></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="modal-footer border-0 justify-content-center pb-4">
                                            <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Close</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% }
                            } else { %>
                            <div class="text-center py-5 d-flex flex-column align-items-center">
                                <i class="fa-regular fa-folder-open fa-3x text-muted opacity-25 mb-3"></i>
                                <p class="text-muted small">No tutoring positions <br> posted yet.</p>
                            </div>
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