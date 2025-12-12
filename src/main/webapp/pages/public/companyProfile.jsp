<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.CompanyInfoDto" %>
<%@ page import="com.internshipapp.common.InternshipPositionDto" %>
<%@ page import="java.util.List" %>
<%
    // 1. Retrieve Data (DTOs only)
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");
    List<InternshipPositionDto> positions = (List<InternshipPositionDto>) request.getAttribute("positions");

    // 2. Session Data
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    // 3. Security Check: Is the viewer the owner?
    boolean isOwner = false;
    if ("Company".equals(sessionRole)) {
        // If viewing via /CompanyProfile without ID, it's the owner (handled by Servlet logic)
        if (request.getParameter("id") == null) {
            isOwner = true;
        }
    }
    if ("Admin".equals(sessionRole)) {
        isOwner = true;
    }

    if (company == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= company.getName() %> - Profile</title>
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

        /* Sidebar Styling */
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

        /* Profile Card */
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

        /* Company Logo Area */
        .profile-img-container {
            width: 150px;
            height: 150px;
            margin: 0 auto 1rem auto;
            position: relative;
            border-radius: 12px; /* Square with rounded corners for companies */
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
            background-color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .profile-img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            padding: 10px;
        }

        /* Overlay for upload */
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
        }

        .profile-img-container:hover .profile-img-overlay {
            opacity: 1;
        }

        .profile-img-overlay i {
            color: white;
            font-size: 1.2rem;
        }

        /* Info & Badges */
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

        /* Position List Item */
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
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">

        <div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
            <% if ("Company".equals(sessionRole)) { %>
            <h5 class="sidebar-title"><i class="fa-solid fa-building me-2"></i> Company Portal</h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="CompanyDashboard"><i class="fa-solid fa-table-columns"></i> Dashboard</a>
                <a class="nav-link active" href="CompanyProfile"><i class="fa-regular fa-id-card"></i> Company
                    Profile</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-user-friends"></i> Enrolled Interns</a>
                <a class="nav-link" href="#"><i class="fa-regular fa-comments"></i> Chats</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-briefcase"></i> Positions</a>
                <div class="mt-5 border-top pt-3">
                    <form action="${pageContext.request.contextPath}/Logout" method="post" class="d-inline">
                        <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start"><i
                                class="fa-solid fa-right-from-bracket"></i> Logout
                        </button>
                    </form>
                </div>
            </div>
            <% } else { %>
            <h5 class="sidebar-title"><i class="fa-solid fa-graduation-cap me-2"></i> Student Portal</h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="Students"><i class="fa-solid fa-table-columns"></i> Dashboard</a>
                <a class="nav-link" href="StudentProfile"><i class="fa-regular fa-id-card"></i> My Profile</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-briefcase"></i> Internships</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-file-contract"></i> Applications</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-calendar-check"></i> Schedule</a>
                <div class="mt-5 border-top pt-3">
                    <form action="${pageContext.request.contextPath}/Logout" method="post" class="d-inline">
                        <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start"><i
                                class="fa-solid fa-right-from-bracket"></i> Logout
                        </button>
                    </form>
                </div>
            </div>
            <% } %>
        </div>

        <div class="col-md-9 col-lg-10 main-content">

            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="profile-card p-4 text-center h-100">

                        <div class="profile-img-container">
                            <img src="https://ui-avatars.com/api/?name=<%= company.getName() %>&background=ffffff&color=0E2B58&size=200&font-size=0.3"
                                 alt="Company Logo" class="profile-img">

                            <% if (isOwner) { %>
                            <label for="logoUpload" class="profile-img-overlay">
                                <i class="fa-solid fa-camera"></i>
                            </label>
                            <form action="UploadCompanyLogo" method="POST" enctype="multipart/form-data"
                                  style="display:none;">
                                <input type="file" id="logoUpload" name="file" onchange="this.form.submit()">
                            </form>
                            <% } %>
                        </div>

                        <h3 class="fw-bold text-dark mb-1"><%= company.getName() %>
                        </h3>
                        <p class="text-muted mb-3"><%= company.getShortName() %>
                        </p>

                        <div class="mb-4">
                            <a href="<%= company.getWebsite() %>" target="_blank"
                               class="badge rounded-pill bg-light text-primary border px-3 py-2 text-decoration-none">
                                <i class="fa-solid fa-globe me-1"></i> Visit Website
                            </a>
                        </div>

                        <hr class="my-4 text-muted opacity-25">

                        <% if (isOwner) { %>
                        <div class="d-grid gap-3">
                            <button class="btn btn-outline-secondary" data-bs-toggle="modal"
                                    data-bs-target="#changePasswordModal">
                                <i class="fa-solid fa-key me-2"></i> Change Password
                            </button>

                            <button class="btn btn-outline-brand" data-bs-toggle="modal" data-bs-target="#deptRepModal">
                                <i class="fa-solid fa-user-tie me-2"></i> Change Dept. Representative
                            </button>

                            <button class="btn btn-brand">
                                <i class="fa-solid fa-pen-to-square me-2"></i> Edit Profile Info
                            </button>
                        </div>
                        <% } else { %>
                        <div class="d-grid gap-2">
                            <button class="btn btn-brand" onclick="alert('Feature coming soon!')">
                                <i class="fa-solid fa-paper-plane me-2"></i> Apply to Position
                            </button>
                        </div>
                        <% } %>
                    </div>
                </div>

                <div class="col-lg-8">

                    <div class="profile-card p-4 mb-4">
                        <h5 class="fw-bold mb-3" style="color: var(--brand-blue);">
                            <i class="fa-regular fa-building me-2"></i> About Us
                        </h5>
                        <p class="text-muted mb-4">
                            <%= company.getCompDescription() %>
                        </p>

                        <div class="row g-3">
                            <div class="col-md-6">
                                <div class="info-label">Active Positions</div>
                                <div class="info-value"><%= (positions != null) ? positions.size() : 0 %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-label">Total Applicants</div>
                                <div class="info-value"><%= (company.getStudentsApplied() != null) ? company.getStudentsApplied() : "0" %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold m-0" style="color: var(--brand-blue);">
                                <i class="fa-solid fa-briefcase me-2"></i> Open Internships
                            </h5>
                        </div>

                        <% if (positions != null && !positions.isEmpty()) { %>
                        <div class="list-group list-group-flush">
                            <% for (InternshipPositionDto pos : positions) { %>
                            <div class="position-item d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="fw-bold text-dark"><%= pos.getTitle() %>
                                    </div>
                                    <div class="small text-muted">
                                        <i class="fa-regular fa-clock me-1"></i>
                                        Deadline: <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "N/A" %>
                                        <span class="mx-2">•</span>
                                        <i class="fa-solid fa-users me-1"></i> <%= pos.getMaxSpots() %> Spots
                                    </div>
                                </div>

                                <% if (!isOwner) { %>
                                <button class="btn btn-sm btn-outline-brand rounded-pill px-3">View Details</button>
                                <% } else { %>
                                <span class="badge bg-light text-dark border">Active</span>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <% } else { %>
                        <div class="text-center py-5 text-muted">
                            <i class="fa-regular fa-folder-open fa-2x mb-3 opacity-25"></i>
                            <p>No active positions at the moment.</p>
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
<div class="modal fade" id="changePasswordModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold">Change Password</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="ChangePassword" method="POST">
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

<div class="modal fade" id="deptRepModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light">
                <h5 class="modal-title fw-bold">Department Representative</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="ChangeDeptRep" method="POST">
                <div class="modal-body">
                    <p class="text-muted small">Update the department representative managing your internships.</p>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Select New Representative</label>
                        <select name="newRepId" class="form-select">
                            <option value="1">Prof. Ion Popescu (Computer Science)</option>
                            <option value="2">Prof. Maria Ionescu (Electrical Eng)</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-brand">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>