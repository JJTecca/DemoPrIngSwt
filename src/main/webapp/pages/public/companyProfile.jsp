<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.CompanyInfoDto" %>
<%@ page import="com.internshipapp.common.InternshipPositionDto" %>
<%@ page import="java.util.*" %>
<%
    // 1. Retrieve Data passed from Servlet
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");
    List<InternshipPositionDto> myPositions = (List<InternshipPositionDto>) request.getAttribute("myPositions");

    // 2. Session Data to determine permissions
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    // 3. Security Check: Is the viewer the owner of this profile?
    boolean isOwner = false;
    // Check if the company email matches the session email
    if (sessionEmail != null && company != null && sessionEmail.equals(company.getUserEmail())) {
        isOwner = true;
    }
    // Admin override
    if ("Admin".equals(sessionRole)) {
        isOwner = true;
    }

    if (company == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    // --- Dashboard Link Determination ---
    String dashboardUrl;
    if ("Student".equals(sessionRole)) {
        dashboardUrl = request.getContextPath() + "/Students";
    } else if ("Company".equals(sessionRole)) {
        dashboardUrl = request.getContextPath() + "/CompanyDashboard";
    } else if ("Admin".equals(sessionRole)) {
        dashboardUrl = request.getContextPath() + "/AdminDashboard";
    } else {
        dashboardUrl = request.getContextPath() + "/index.jsp";
    }


    // Default logo URL based on company name
    String avatarUrl = "https://ui-avatars.com/api/?name=" + company.getName() + "&background=0E2B58&color=fff&size=200";

    // Safety check for myPositions
    if (myPositions == null) {
        myPositions = Collections.emptyList();
    }

    // --- Data Calculation & Safety Check ---
    int postedPositionsCount = myPositions.size();

    // The DTO fields openedPositions and studentsApplied should ideally contain counts.
    int studentsAppliedCount = 0;
    try {
        if (company.getStudentsApplied() != null) {
            studentsAppliedCount = Integer.parseInt(company.getStudentsApplied().trim());
        }
    } catch (NumberFormatException e) {
        studentsAppliedCount = 0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= company.getName() %> - Company Profile</title>
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

        /* --- Sidebar & Layout --- */
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
        }

        /* --- Profile Card --- */
        .profile-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: none;
            overflow: hidden;
            position: relative;
        }

        .profile-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 6px;
            background: linear-gradient(90deg, var(--brand-blue) 0%, var(--ulbs-red) 100%);
        }

        /* --- Logo Area --- */
        .profile-img-container {
            width: 150px;
            height: 150px;
            margin: 0 auto 1rem auto;
            position: relative;
            border-radius: 8px; /* Square logo border for company */
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
            background-color: #eee;
            overflow: hidden;
        }

        .profile-img {
            width: 100%;
            height: 100%;
            object-fit: contain; /* Use contain for logos */
            padding: 10px;
        }

        /* PFP Overlays (Bottom for Upload/Change) */
        .profile-img-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(14, 43, 88, 0.8);
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
            opacity: 0;
            z-index: 5;
            border-bottom-left-radius: 8px; /* Match container radius */
            border-bottom-right-radius: 8px;
        }

        .profile-img-container:hover .profile-img-overlay {
            opacity: 1;
        }

        .profile-img-overlay i {
            color: white;
            font-size: 1.2rem;
        }

        /* NEW: Delete Button as Top Overlay */
        .btn-delete-pfp {
            /* Positioning */
            width: 100%;
            height: 30px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            position: absolute;
            top: 0;
            left: 0;
            right: 0;

            /* Styling */
            background: rgba(163, 11, 11, 0.9); /* Red overlay */
            color: white;
            box-shadow: none;
            border: none;

            /* Match top corners of container */
            border-top-left-radius: 8px;
            border-top-right-radius: 8px;

            cursor: pointer;
            transition: all 0.2s;
            opacity: 0;
            z-index: 10;
            font-size: 0.9rem;
        }

        .btn-delete-pfp i {
            color: white;
            font-size: 0.9rem;
            margin-right: 5px;
        }

        .profile-img-container:hover .btn-delete-pfp {
            opacity: 1;
        }
        /* --- End New Delete Styles --- */


        /* --- Info Sections --- */
        .info-label {
            font-weight: 600;
            color: #666;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .info-value {
            font-size: 1.05rem;
            color: var(--brand-blue-dark);
            font-weight: 500;
        }

        /* --- Positions List --- */
        .position-list-item {
            padding: 1rem;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
        }

        .position-list-item:hover {
            background-color: #f8f9fa;
        }

        .position-list-item:last-child {
            border-bottom: none;
        }

        /* --- Buttons --- */
        .btn-brand {
            background-color: var(--brand-blue);
            color: white;
            border: none;
        }

        .btn-brand:hover {
            background-color: var(--brand-blue-dark);
            color: white;
        }

        /* Modal specific styling (optional, but good practice) */
        .modal-footer .btn-brand {
            background-color: var(--brand-blue);
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">

        <div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
            <% if ("Student".equals(sessionRole)) { %>
            <h5 class="sidebar-title">
                <i class="fa-solid fa-graduation-cap me-2"></i> Student Portal
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="<%= dashboardUrl %>">
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
            </div>
            <% } else if ("Admin".equals(sessionRole)) { %>
            <h5 class="sidebar-title">
                <i class="fa-solid fa-shield-halved me-2"></i> Admin Portal
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="<%= dashboardUrl %>">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>
                <a class="nav-link" href="#users">
                    <i class="fa-solid fa-users"></i> Manage Users
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/InternshipPositions">
                    <i class="fa-solid fa-briefcase"></i> Manage Internships
                </a>
                <a class="nav-link" href="#reports">
                    <i class="fa-solid fa-file-pdf"></i> Reports
                </a>
            </div>
            <% } else { %>
            <h5 class="sidebar-title">
                <i class="fa-solid fa-building me-2"></i> Company Portal
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="<%= dashboardUrl %>">
                    <i class="fa-solid fa-table-columns"></i> Dashboard
                </a>
                <a class="nav-link active" href="${pageContext.request.contextPath}/CompanyProfile">
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
            </div>
            <% } %>

            <div class="mt-3 border-top pt-3">
                <form action="${pageContext.request.contextPath}/Logout" method="post" class="d-inline">
                    <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start">
                        <i class="fa-solid fa-right-from-bracket"></i> Logout
                    </button>
                </form>
            </div>
        </div>

        <div class="col-md-9 col-lg-10 main-content">

            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="profile-card p-4 text-center h-100">

                        <div class="profile-img-container">
                            <% if (company.hasProfilePic()) { %>
                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= company.getId() %>&targetRole=Company&t=<%= System.currentTimeMillis() %>"
                                 alt="Company Logo" class="profile-img">

                            <% if (isOwner) { %>
                            <%-- NEW DELETE BUTTON AS TOP OVERLAY --%>
                            <button type="button"
                                    class="btn-delete-pfp"
                                    title="Delete Company Logo"
                                    data-bs-toggle="modal" data-bs-target="#deleteCompanyPfpModal">
                                <i class="fa-solid fa-trash-can"></i>
                            </button>
                            <% } %>

                            <% } else { %>
                            <img src="<%= avatarUrl %>" alt="Default Logo" class="profile-img">
                            <% } %>

                            <% if (isOwner) { %>
                            <label for="pfpUpload" class="profile-img-overlay">
                                <i class="fa-solid fa-camera"></i>
                            </label>
                            <form action="${pageContext.request.contextPath}/UploadProfilePicture" method="POST"
                                  enctype="multipart/form-data" style="display:none;">
                                <input type="file" id="pfpUpload" name="file" onchange="this.form.submit()"
                                       accept="image/*">
                            </form>
                            <% } %>
                        </div>
                        <h3 class="fw-bold text-dark mb-1"><%= company.getName() %>
                        </h3>
                        <p class="text-muted mb-3"><%= company.getWebsite() != null ? company.getWebsite() : "Website not listed" %>
                        </p>

                        <div class="mb-4">
                            <span class="badge rounded-pill bg-primary px-3 py-2">
                                Short Name: <%= company.getShortName() != null ? company.getShortName() : "N/A" %>
                            </span>
                        </div>

                        <hr class="my-4 text-muted opacity-25">

                        <div class="text-start mb-4 position-relative">
                            <h6 class="text-uppercase text-muted small fw-bold mb-2">
                                Biography
                                <% if (isOwner) { %>
                                <button type="button" class="btn btn-sm btn-outline-primary p-0 px-1 float-end"
                                        data-bs-toggle="modal" data-bs-target="#editBioModal" title="Edit Biography">
                                    <i class="fa-solid fa-pen fa-xs"></i>
                                </button>
                                <% } %>
                            </h6>
                            <div class="text-dark small text-break">
                                <% if (company.getBiography() != null && !company.getBiography().trim().isEmpty()) { %>
                                <%= company.getBiography() %>
                                <% } else { %>
                                <p class="text-muted small fst-italic mb-0">
                                    <% if (isOwner) { %>
                                    Add a description to attract top students.
                                    <% } else { %>
                                    No public biography provided.
                                    <% } %>
                                </p>
                                <% } %>
                            </div>
                        </div>
                        <hr class="my-4 text-muted opacity-25">
                        <% if (isOwner) { %>
                        <div class="d-grid gap-3">
                            <button class="btn btn-outline-secondary" data-bs-toggle="modal"
                                    data-bs-target="#changePasswordModal">
                                <i class="fa-solid fa-key me-2"></i> Change Password
                            </button>
                        </div>
                        <% } else { %>
                        <div class="d-grid gap-2">
                            <a href="mailto:<%= company.getUserEmail() %>" class="btn btn-brand">
                                <i class="fa-solid fa-envelope me-2"></i> Contact Company
                            </a>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-lg-8">

                    <div class="profile-card p-4 mb-4">
                        <h5 class="fw-bold mb-4" style="color: var(--brand-blue);">
                            <i class="fa-solid fa-globe me-2"></i> General Company Information
                        </h5>

                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <div class="info-label">Email Address</div>
                                    <div class="info-value"><%= company.getUserEmail() != null ? company.getUserEmail() : "N/A" %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <div class="info-label">Website
                                        <% if (isOwner) { %>
                                        <button type="button" class="btn btn-sm btn-outline-primary p-0 px-1 ms-2"
                                                data-bs-toggle="modal" data-bs-target="#editWebsiteModal" title="Edit Website URL">
                                            <i class="fa-solid fa-pen fa-xs"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                    <div class="info-value">
                                        <a href="<%= company.getWebsite() %>" target="_blank" class="text-decoration-none">
                                            <%= company.getWebsite() != null ? company.getWebsite() : "N/A" %>
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12">
                                <hr class="text-muted opacity-25 m-0">
                            </div>

                            <div class="col-md-4">
                                <div class="mb-3">
                                    <div class="info-label">Total Positions Listed</div>
                                    <div class="info-value"><%= postedPositionsCount %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <div class="info-label">Applications Received</div>
                                    <div class="info-value"><%= studentsAppliedCount %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <div class="info-label">Short Description
                                        <% if (isOwner) { %>
                                        <button type="button" class="btn btn-sm btn-outline-primary p-0 px-1 ms-2"
                                                data-bs-toggle="modal" data-bs-target="#editDescModal" title="Edit Short Description">
                                            <i class="fa-solid fa-pen fa-xs"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                    <div class="info-value"><%= company.getCompDescription() != null ? company.getCompDescription() : "N/A" %>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold m-0" style="color: var(--brand-blue);">
                                <i class="fa-solid fa-briefcase me-2"></i> Current Internship Positions
                            </h5>
                            <% if (isOwner) { %>
                            <button class="btn btn-sm btn-brand" data-bs-toggle="modal" data-bs-target="#postPositionModal">
                                <i class="fa-solid fa-plus me-1"></i> Post New Position
                            </button>
                            <% } %>
                        </div>

                        <% if (!myPositions.isEmpty()) { %>
                        <div class="list-group list-group-flush border-top border-bottom">
                            <% for (InternshipPositionDto pos : myPositions) { %>
                            <div class="position-list-item d-flex justify-content-between align-items-center">
                                <div>
                                    <span class="fw-bold text-dark"><%= pos.getTitle() %></span>
                                    <div class="small text-muted">
                                        <i class="fa-regular fa-clock me-1"></i> Deadline:
                                        <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %>
                                    </div>
                                </div>
                                <div>
                                    <span class="badge bg-light text-primary border me-3">
                                        <%= pos.getMaxSpots() %> Spots
                                    </span>
                                    <button class="btn btn-sm btn-outline-primary">Details</button>
                                </div>
                            </div>
                            <% } %>
                        </div>
                        <% } else { %>
                        <div class="text-center p-5 border rounded">
                            <i class="fa-regular fa-folder-open fa-3x text-muted opacity-25 mb-3"></i>
                            <p class="text-muted mb-0">No active positions posted yet.</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<% if (isOwner) { %>

<div class="modal fade" id="editWebsiteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-globe me-2"></i> Edit Website</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST">
                <input type="hidden" name="action" value="update_website">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Company Website URL</label>
                        <input type="url" name="website" class="form-control"
                               value="<%= company.getWebsite() != null ? company.getWebsite() : "https://" %>" required>
                        <div class="form-text">e.g., https://www.yourcompany.com</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-brand">Save Website</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editBioModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-user-pen me-2"></i> Edit Biography</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST">
                <input type="hidden" name="action" value="update_biography">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Company Biography (Max 255 Characters)</label>
                        <textarea name="biography" class="form-control" rows="5" maxlength="255"><%= company.getBiography() != null ? company.getBiography() : "" %></textarea>
                        <div class="form-text">A detailed description of your company for student applicants.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-brand">Save Biography</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editDescModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-pen-to-square me-2"></i> Edit Short Description</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST">
                <input type="hidden" name="action" value="update_description">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Short Description (Max 50 Characters)</label>
                        <input type="text" name="compDescription" class="form-control" maxlength="50"
                               value="<%= company.getCompDescription() != null ? company.getCompDescription() : "" %>" required>
                        <div class="form-text">A brief, catchy summary.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-brand">Save Description</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteCompanyPfpModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-triangle-exclamation me-2"></i> Confirm Deletion</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <p class="mb-0">Are you sure you want to remove your company logo?</p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <a href="${pageContext.request.contextPath}/DeleteProfilePicture" class="btn btn-danger btn-sm">Remove Logo</a>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="changePasswordModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold">Change Password</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/ChangePassword" method="POST">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Current Password</label>
                        <input type="password" name="oldPassword" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">New Password</label>
                        <input type="password" name="newPassword" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Confirm New Password</label>
                        <input type="password" name="confirmPassword" class="form-control" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-brand">Update Password</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="postPositionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-plus me-2"></i> Post New Internship</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small">Future form implementation for creating a new internship position will go here.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>