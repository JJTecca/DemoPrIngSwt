<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.CompanyInfoDto" %>
<%@ page import="com.internshipapp.common.InternshipPositionDto" %>
<%@ page import="java.util.*" %>
<%
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");
    List<InternshipPositionDto> myPositions = (List<InternshipPositionDto>) request.getAttribute("myPositions");
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    // Dynamic label logic
    boolean isFaculty = "Faculty".equals(sessionRole);
    String mainLabel = isFaculty ? "Faculty" : "Company";
    String deptLabel = isFaculty ? "Department" : "Company";
    String positionLabel = isFaculty ? "Tutoring Positions" : "Internship Positions";
    String postBtnLabel = isFaculty ? "New Tutoring Post" : "Post Internship";

    boolean isOwner = (sessionEmail != null && company != null && sessionEmail.equals(company.getUserEmail())) || "Admin".equals(sessionRole);
    if (company == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String avatarUrl = "https://ui-avatars.com/api/?name=" + company.getName() + "&background=0E2B58&color=fff&size=200";
    if (myPositions == null) myPositions = Collections.emptyList();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= company.getName() %> - <%= mainLabel %> Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        /* Existing CSS maintained */
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

        .profile-img-container {
            width: 150px;
            height: 150px;
            margin: 0 auto 1rem auto;
            position: relative;
            border-radius: 8px;
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
            background-color: #eee;
            overflow: hidden;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .profile-img {
            width: 100%;
            height: 100%;
            object-fit: contain;
            padding: 10px;
            display: block;
        }

        .profile-img-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            height: 45px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 25px;
            transition: all 0.3s ease;
            opacity: 0;
            z-index: 5;
            background: transparent;
        }

        .profile-img-container:hover .profile-img-overlay {
            opacity: 1;
        }

        .overlay-item {
            color: white;
            font-size: 1.4rem;
            cursor: pointer;
            transition: transform 0.2s, color 0.2s;
            border: none;
            background: transparent;
            padding: 0;
            text-shadow: 0 2px 10px rgba(0, 0, 0, 0.8);
        }

        .upload-side:hover {
            color: #4facfe;
            transform: scale(1.2);
        }

        .delete-side:hover {
            color: #ff4b2b;
            transform: scale(1.2);
        }

        .positions-scroll-wrapper::-webkit-scrollbar {
            width: 6px;
        }

        .positions-scroll-wrapper::-webkit-scrollbar-track {
            background: #f8f9fa;
        }

        .positions-scroll-wrapper::-webkit-scrollbar-thumb {
            background: #ccc;
            border-radius: 10px;
        }

        .positions-scroll-wrapper::-webkit-scrollbar-thumb:hover {
            background: var(--brand-blue);
        }

        .info-label {
            font-weight: 600;
            color: #666;
            font-size: 0.9rem;
            text-transform: uppercase;
        }

        .info-value {
            font-size: 1.05rem;
            color: var(--brand-blue-dark);
            font-weight: 500;
        }

        .position-list-item {
            padding: 1rem;
            border-bottom: 1px solid #f0f0f0;
            transition: background 0.2s;
        }

        .position-list-item:hover {
            background-color: #fafafa;
        }

        .btn-gray-modern {
            background-color: #f1f3f5;
            color: #475467;
            border: 1px solid #ced4da;
            font-weight: 600;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(16, 24, 40, 0.05);
        }

        .btn-gray-modern:hover {
            background-color: #e9ecef;
            color: #1d2939;
            border-color: #adb5bd;
            transform: translateY(-1px);
        }

        .btn-brand {
            background: var(--brand-blue);
            color: white;
            border: none;
            font-weight: 600;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(14, 43, 88, 0.2);
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .btn-brand:hover {
            background-color: var(--brand-blue-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(14, 43, 88, 0.3);
            color: white;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <% if ("Student".equals(sessionRole)) { %>
        <jsp:include page="../blocks/studentSidebar.jsp"/>
        <% } else if ("Company".equals(sessionRole)) { %>
        <jsp:include page="../blocks/companySidebar.jsp"/>
        <% } else if ("Admin".equals(sessionRole)) { %>
        <jsp:include page="../blocks/adminSidebar.jsp"/>
        <% } else if ("Faculty".equals(sessionRole)) { %>
        <jsp:include page="../blocks/facultySidebar.jsp"/>
        <% } %>

        <div class="col-md-9 col-lg-10 main-content">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="profile-card p-4 text-center h-100">
                        <div class="profile-img-container">
                            <img src="<%= company.hasProfilePic() ? request.getContextPath() + "/ProfilePicture?id=" + company.getId() + "&targetRole=Company&t=" + System.currentTimeMillis() : avatarUrl %>"
                                 class="profile-img">
                            <% if (isOwner) { %>
                            <div class="profile-img-overlay">
                                <label for="pfpUpload" class="overlay-item upload-side m-0" title="Upload Logo"><i
                                        class="fa-solid fa-camera"></i></label>
                                <% if (company.hasProfilePic()) { %>
                                <button type="button" class="overlay-item delete-side" title="Delete Logo"
                                        data-bs-toggle="modal" data-bs-target="#deleteCompanyPfpModal"><i
                                        class="fa-solid fa-trash-can"></i></button>
                                <% } %>
                            </div>
                            <form action="${pageContext.request.contextPath}/UploadProfilePicture" method="POST"
                                  enctype="multipart/form-data" style="display:none;"><input type="file" id="pfpUpload"
                                                                                             name="file"
                                                                                             onchange="this.form.submit()"
                                                                                             accept="image/*"></form>
                            <% } %>
                        </div>

                        <h3 class="fw-bold text-dark mb-1"><%= company.getName() %>
                        </h3>
                        <p class="text-muted small"><%= company.getWebsite() != null ? company.getWebsite() : "No website listed" %>
                        </p>

                        <div class="mb-4">
                            <span class="badge rounded-pill bg-primary px-3 py-2">Short Name: <%= company.getShortName() %></span>
                            <% if (isOwner) { %>
                            <button class="btn btn-sm btn-link p-0 ms-1" data-bs-toggle="modal"
                                    data-bs-target="#editShortNameModal"><i class="fa-solid fa-pen-to-square"></i>
                            </button>
                            <% } %>
                        </div>

                        <div class="text-start mb-4">
                            <h6 class="text-uppercase text-muted small fw-bold mb-2">Biography <% if (isOwner) { %>
                                <button class="btn btn-sm btn-link p-0 float-end" data-bs-toggle="modal"
                                        data-bs-target="#editBioModal"><i class="fa-solid fa-pen fa-xs"></i></button>
                                <% } %></h6>
                            <div class="text-dark small"><%= company.getBiography() != null ? company.getBiography() : "No biography provided." %>
                            </div>
                        </div>

                        <div class="d-grid gap-2 mt-auto">
                            <% if (isOwner) { %>
                            <button class="btn btn-gray-modern btn-sm px-3" data-bs-toggle="modal"
                                    data-bs-target="#changePasswordModal">Change Password
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="profile-card p-4 mb-4">
                        <h5 class="fw-bold mb-4 text-primary"><i
                                class="<%= isFaculty ? "fa-solid fa-building-columns" : "fa-solid fa-globe" %> me-2"></i> <%= deptLabel %>
                            Info</h5>
                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="info-label">Contact Email <% if (isOwner) { %><i
                                        class="fa-solid fa-pen ms-1 small" style="cursor:pointer" data-bs-toggle="modal"
                                        data-bs-target="#editContactEmailModal"></i><% } %></div>
                                <div class="info-value"><%= (company.getContactEmail() != null && !company.getContactEmail().isEmpty()) ? company.getContactEmail() : "N/A" %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-label">Website <% if (isOwner) { %><i
                                        class="fa-solid fa-pen ms-1 small" style="cursor:pointer" data-bs-toggle="modal"
                                        data-bs-target="#editWebsiteModal"></i><% } %></div>
                                <div class="info-value"><a href="<%= company.getWebsite() %>"
                                                           target="_blank"><%= company.getWebsite() != null ? company.getWebsite() : "N/A" %>
                                </a></div>
                            </div>
                            <div class="col-md-12">
                                <div class="info-label"><%= deptLabel %> Description<% if (isOwner) { %><i
                                        class="fa-solid fa-pen ms-1 small" style="cursor:pointer" data-bs-toggle="modal"
                                        data-bs-target="#editDescModal"></i><% } %></div>
                                <div class="info-value"><%= company.getCompDescription() != null ? company.getCompDescription() : "No description set." %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card p-4">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="fw-bold m-0 text-primary">
                                <i class="<%= isFaculty ? "fa-solid fa-chalkboard-user" : "fa-solid fa-briefcase" %> me-2"></i> <%= positionLabel %>
                            </h5>
                            <% if (isOwner) { %>
                            <button class="btn btn-sm btn-brand" data-bs-toggle="modal"
                                    data-bs-target="#postPositionModal"><%= postBtnLabel %>
                            </button>
                            <% } %>
                        </div>

                        <div class="positions-scroll-wrapper"
                             style="max-height: 300px; overflow-y: auto; overflow-x: hidden;">
                            <div class="list-group list-group-flush">
                                <% if (myPositions != null && !myPositions.isEmpty()) { %>
                                <% for (InternshipPositionDto pos : myPositions) { %>
                                <div class="position-list-item d-flex justify-content-between align-items-center">
                                    <div>
                                        <div class="fw-bold"><%= pos.getTitle() %>
                                        </div>
                                        <div class="small text-muted">Deadline: <%= pos.getDeadline() %>
                                        </div>
                                    </div>
                                    <span class="badge bg-light text-primary border"><%= pos.getMaxSpots() %> Spots</span>
                                </div>
                                <% } %>
                                <% } else { %>
                                <div class="text-center py-5 d-flex flex-column align-items-center">
                                    <i class="fa-regular fa-folder-open fa-3x text-muted opacity-25 mb-3"></i>
                                    <p class="text-muted small">No <%= positionLabel.toLowerCase() %> found.</p>
                                </div>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<%-- CRUD MODALS --%>
<% if (isOwner) { %>

<div class="modal fade" id="editContactEmailModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Edit Contact Email</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST">
                <input type="hidden" name="action" value="update_contact_email">
                <div class="modal-body">
                    <input type="email" name="contactEmail" class="form-control"
                           value="<%= company.getContactEmail() != null ? company.getContactEmail() : "" %>" required>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editWebsiteModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Edit URL</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST"><input type="hidden"
                                                                                                  name="action"
                                                                                                  value="update_website">
                <div class="modal-body"><input type="url" name="website" class="form-control"
                                               value="<%= company.getWebsite() %>" required></div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editBioModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Edit Biography</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST"><input type="hidden"
                                                                                                  name="action"
                                                                                                  value="update_biography">
                <div class="modal-body"><textarea name="biography" class="form-control" rows="5"
                                                  maxlength="255"><%= company.getBiography() %></textarea></div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editShortNameModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Short Reference</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST"><input type="hidden"
                                                                                                  name="action"
                                                                                                  value="update_shortname">
                <div class="modal-body"><input type="text" name="shortName" class="form-control" maxlength="10"
                                               value="<%= company.getShortName() %>" required></div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="editDescModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-md">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Edit <%= deptLabel %> Description</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/CompanyProfile" method="POST"><input type="hidden"
                                                                                                  name="action"
                                                                                                  value="update_description">
                <div class="modal-body"><input type="text" name="compDescription" class="form-control" maxlength="100"
                                               value="<%= company.getCompDescription() %>" required></div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteCompanyPfpModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content text-center">
            <div class="modal-body p-4"><i class="fa-solid fa-trash-can fa-3x text-danger mb-3"></i>
                <p>Remove image?</p>
                <div class="d-flex gap-2 justify-content-center mt-3">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <a href="${pageContext.request.contextPath}/DeleteProfilePicture" class="btn btn-danger btn-sm">Confirm</a>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="changePasswordModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Update Password</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/ChangePassword" method="POST">
                <div class="modal-body"><input type="password" name="oldPassword" class="form-control mb-3"
                                               placeholder="Current Password" required><input type="password"
                                                                                              name="newPassword"
                                                                                              class="form-control mb-3"
                                                                                              placeholder="New Password"
                                                                                              required><input
                        type="password" name="confirmPassword" class="form-control" placeholder="Confirm New Password"
                        required></div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Update</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="postPositionModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Post New Role</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center py-5"><i class="fa-solid fa-tools fa-2x text-muted mb-3"></i>
                <p class="text-muted">Post creation form coming soon.</p></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>