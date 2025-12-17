<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.StudentInfoDto" %>
<%@ page import="com.internshipapp.common.UserAccountDto" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.*" %>
<%
    // 1. Retrieve Data passed from Servlet
    StudentInfoDto student = (StudentInfoDto) request.getAttribute("student");

    // 2. Session Data to determine permissions
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    // 3. Security Check: Is the viewer the owner of this profile?
    boolean isOwner = false;
    if (sessionEmail != null && student != null && sessionEmail.equals(student.getUserEmail())) {
        isOwner = true;
    }
    // Admin override
    if ("Admin".equals(sessionRole)) {
        isOwner = true;
    }

    if (student == null) {
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


    // Default PFP URL
    String defaultAvatarUrl = "https://ui-avatars.com/api/?name=" + student.getFirstName() + "+" + student.getLastName() + "&background=0E2B58&color=fff&size=200";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= student.getFullName() %> - Profile</title>
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

        /* --- Profile Header Card --- */
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

        /* --- Profile Picture Area --- */
        .profile-img-container {
            width: 150px;
            height: 150px;
            margin: 0 auto 1rem auto;
            position: relative;
            border-radius: 50%;
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
            background-color: #eee;
            overflow: hidden;
        }

        .profile-img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

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
        }

        .profile-img-container:hover .profile-img-overlay {
            opacity: 1;
        }

        .profile-img-overlay i {
            color: white;
            font-size: 1.2rem;
        }

        /* FIX: Delete Button CSS changed to look exactly like the top version of the bottom overlay */
        .btn-delete-pfp {
            /* Reset to act as a top overlay bar */
            width: 100%;
            height: 30px;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            position: absolute;
            top: 0; /* Fixed to the TOP edge */
            left: 0;
            right: 0;

            /* Styling */
            background: rgba(163, 11, 11, 0.9); /* Red overlay */
            color: white;
            box-shadow: none;
            border-radius: 0;
            border: none;

            cursor: pointer;
            transition: all 0.2s;
            opacity: 0;
            z-index: 10;
        }

        /* Style for the trash icon inside the delete button */
        .btn-delete-pfp i {
            color: white;
            font-size: 0.9rem;
            margin-right: 5px; /* Added spacing to make text more readable */
        }

        .profile-img-container:hover .btn-delete-pfp {
            opacity: 1; /* Show on hover */
        }

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

        /* --- CV Container --- */
        .cv-container {
            border: 2px dashed #ccc;
            border-radius: 12px;
            padding: 2rem;
            text-align: center;
            background-color: #fafafa;
            transition: all 0.3s;
            position: relative;
        }

        .cv-container:hover {
            border-color: var(--brand-blue);
            background-color: #f0f7ff;
        }

        .cv-icon {
            font-size: 3rem;
            color: var(--brand-blue);
            margin-bottom: 1rem;
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

        .btn-outline-brand {
            border: 2px solid var(--brand-blue);
            color: var(--brand-blue);
            background: transparent;
            font-weight: 600;
        }

        .btn-outline-brand:hover {
            background: var(--brand-blue);
            color: white;
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
                <a class="nav-link active" href="${pageContext.request.contextPath}/StudentProfile">
                    <i class="fa-regular fa-id-card"></i> My Profile
                </a>
                <a class="nav-link" href="${pageContext.request.contextPath}/InternshipPositions">
                    <i class="fa-solid fa-briefcase"></i> Internships
                </a>
                <a class="nav-link" href="#">
                    <i class="fa-solid fa-calendar-check"></i> Schedule
                </a>
            </div>
            <% } else if ("Company".equals(sessionRole)) { %>
            <h5 class="sidebar-title">
                <i class="fa-solid fa-building me-2"></i> Company Portal
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="<%= dashboardUrl %>">
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
                            <% if (student.hasProfilePic()) { %>
                            <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= student.getId() %>&targetRole=Student&t=<%= System.currentTimeMillis() %>"
                                 alt="Profile Picture" class="profile-img">

                            <% if (isOwner) { %>
                            <%-- The Delete button is styled as a top overlay --%>
                            <button type="button"
                                    class="btn-delete-pfp"
                                    title="Delete Profile Picture"
                                    data-bs-toggle="modal" data-bs-target="#deletePfpModal">
                                <i class="fa-solid fa-trash-can"></i>
                            </button>
                            <% } %>
                            <% } else { %>
                            <img src="<%= defaultAvatarUrl %>"
                                 alt="Profile Picture" class="profile-img">
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

                        <h3 class="fw-bold text-dark mb-1"><%= student.getFullName() %>
                        </h3>
                        <p class="text-muted mb-3">Student
                        </p>

                        <div class="mb-4">
                            <span class="badge rounded-pill bg-primary px-3 py-2">
                                <%= student.getStatus() %>
                            </span>
                            <% if (student.getEnrolled()) { %>
                            <span class="badge rounded-pill bg-success px-3 py-2 ms-1">Enrolled</span>
                            <% } else { %>
                            <span class="badge rounded-pill bg-danger px-3 py-2 ms-1">Not Enrolled</span>
                            <% } %>
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
                                <% if (student.getBiography() != null && !student.getBiography().trim().isEmpty()) { %>
                                <%= student.getBiography() %>
                                <% } else { %>
                                <p class="text-muted small fst-italic mb-0">
                                    <% if (isOwner) { %>
                                    Add a short bio to attract companies.
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
                            <a href="mailto:<%= student.getUserEmail() %>" class="btn btn-brand">
                                <i class="fa-solid fa-envelope me-2"></i> Contact Student
                            </a>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-lg-8">

                    <div class="profile-card p-4 mb-4">
                        <h5 class="fw-bold mb-4" style="color: var(--brand-blue);">
                            <i class="fa-solid fa-user-graduate me-2"></i> Academic Information
                        </h5>

                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <div class="info-label">Email Address</div>
                                    <div class="info-value"><%= student.getUserEmail() %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <div class="info-label">Username</div>
                                    <div class="info-value"><%= student.getUsername() %>
                                    </div>
                                </div>
                            </div>

                            <div class="col-12">
                                <hr class="text-muted opacity-25 m-0">
                            </div>

                            <div class="col-md-4">
                                <div class="mb-3">
                                    <div class="info-label">Study Year</div>
                                    <div class="info-value">Year <%= student.getStudyYear() %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <div class="info-label">Last Year Grade</div>
                                    <div class="info-value"><%= student.getGradeFormatted() %>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="mb-3">
                                    <div class="info-label">Faculty</div>
                                    <div class="info-value">Engineering</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold m-0" style="color: var(--brand-blue);">
                                <i class="fa-solid fa-file-pdf me-2"></i> Curriculum Vitae
                            </h5>
                            <% if (student.hasCv()) { %>
                            <span class="badge bg-success">CV Available</span>
                            <% } else { %>
                            <span class="badge bg-warning text-dark">Missing CV</span>
                            <% } %>
                        </div>

                        <div class="cv-container">
                            <% if (student.hasCv()) { %>
                            <i class="fa-regular fa-file-pdf cv-icon text-danger"></i>
                            <h5 class="fw-bold text-dark">Student_CV.pdf</h5>
                            <p class="text-muted small mb-4">Uploaded</p>

                            <div class="d-flex justify-content-center gap-3">
                                <a href="${pageContext.request.contextPath}/DownloadCV?id=<%= student.getId() %>"
                                   class="btn btn-brand px-4">
                                    <i class="fa-solid fa-download me-2"></i> Download
                                </a>

                                <% if (isOwner) { %>
                                <button type="button" class="btn btn-outline-danger px-4"
                                        data-bs-toggle="modal" data-bs-target="#deleteCvModal">
                                    <i class="fa-solid fa-trash"></i> Delete
                                </button>
                                <% } %>
                            </div>
                            <% } else { %>
                            <i class="fa-solid fa-cloud-arrow-up cv-icon opacity-50"></i>
                            <h5 class="fw-bold text-dark">No CV Uploaded</h5>

                            <% if (isOwner) { %>
                            <p class="text-muted small mb-4">
                                Upload your CV to let companies see your qualifications. <br>
                                Accepted formats: PDF only (Max 5MB).
                            </p>

                            <button class="btn btn-outline-brand px-4" data-bs-toggle="modal"
                                    data-bs-target="#uploadCvModal">
                                <i class="fa-solid fa-plus me-2"></i> Upload CV
                            </button>
                            <% } else { %>
                            <p class="text-muted small mb-4">
                                This student has not yet uploaded their Curriculum Vitae.
                            </p>
                            <button class="btn btn-secondary px-4" disabled>
                                No Document Available
                            </button>
                            <% } %>

                            <% } %>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<% if (isOwner) { %>

<div class="modal fade" id="editBioModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-user-pen me-2"></i> Edit Biography</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/StudentProfile" method="POST">
                <input type="hidden" name="action" value="update_bio">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Your Biography (Max 255 Characters)</label>
                        <textarea name="biography" class="form-control" rows="5" maxlength="255"><%= student.getBiography() != null ? student.getBiography() : "" %></textarea>
                        <div class="form-text">Write a concise summary of your skills and career goals.</div>
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

<div class="modal fade" id="uploadCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold">Upload Curriculum Vitae</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/UploadCV" method="POST" enctype="multipart/form-data">
                <div class="modal-body">
                    <% if (student.hasCv()) { %>
                    <div class="alert alert-info small d-flex align-items-center" role="alert">
                        <i class="fa-solid fa-circle-info me-2"></i>
                        This action will replace your current CV.
                    </div>
                    <% } %>
                    <div class="mb-3">
                        <label class="form-label">Select PDF File</label>
                        <input type="file" name="cvFile" class="form-control" accept=".pdf" required>
                        <div class="form-text">Accepted format: PDF only. Max size: 5MB.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-brand">
                        <i class="fa-solid fa-cloud-arrow-up me-2"></i> Upload
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-trash-can me-2"></i> Confirm CV Deletion</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <p class="mb-0">Are you sure you want to permanently delete your CV? This cannot be undone.</p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <a href="${pageContext.request.contextPath}/DeleteCV" class="btn btn-danger btn-sm">
                    Delete Permanently
                </a>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="deletePfpModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-danger text-white">
                <h5 class="modal-title fw-bold"><i class="fa-solid fa-trash-can me-2"></i> Confirm Photo Deletion</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center">
                <p class="mb-0">Are you sure you want to remove your profile photo?</p>
            </div>
            <div class="modal-footer justify-content-center">
                <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                <a href="${pageContext.request.contextPath}/DeleteProfilePicture" class="btn btn-danger btn-sm">
                    Remove Photo
                </a>
            </div>
        </div>
    </div>
</div>

<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>