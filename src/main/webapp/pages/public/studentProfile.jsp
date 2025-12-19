<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.StudentInfoDto" %>
<%@ page import="com.internshipapp.common.UserAccountDto" %>
<%@ page import="java.util.*" %>
<%
    StudentInfoDto student = (StudentInfoDto) request.getAttribute("student");
    String sessionEmail = (String) session.getAttribute("userEmail");
    String sessionRole = (String) session.getAttribute("userRole");

    boolean isOwner = (sessionEmail != null && student != null && sessionEmail.equals(student.getUserEmail())) || "Admin".equals(sessionRole);

    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
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
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
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
            border-radius: 50%;
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
            object-fit: cover;
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

        .profile-img-overlay:not(:has(.delete-side)) {
            gap: 0;
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

        .cv-container {
            border: 2px dashed #ccc;
            border-radius: 12px;
            padding: 2rem;
            text-align: center;
            background-color: #fafafa;
            transition: all 0.3s;
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

        .btn-brand {
            background: var(--brand-blue); /* Or use the gradient: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%) */
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
        <% } %>

        <div class="col-md-9 col-lg-10 main-content">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="profile-card p-4 text-center h-100">
                        <div class="profile-img-container">
                            <img src="<%= student.hasProfilePic() ? request.getContextPath() + "/ProfilePicture?id=" + student.getId() + "&targetRole=Student&t=" + System.currentTimeMillis() : defaultAvatarUrl %>"
                                 class="profile-img">
                            <% if (isOwner) { %>
                            <div class="profile-img-overlay">
                                <label for="pfpUpload" class="overlay-item upload-side m-0" title="Upload Photo"><i
                                        class="fa-solid fa-camera"></i></label>
                                <% if (student.hasProfilePic()) { %>
                                <button type="button" class="overlay-item delete-side" title="Delete Photo"
                                        data-bs-toggle="modal" data-bs-target="#deletePfpModal"><i
                                        class="fa-solid fa-trash-can"></i></button>
                                <% } %>
                            </div>
                            <form action="${pageContext.request.contextPath}/UploadProfilePicture" method="POST"
                                  enctype="multipart/form-data" style="display:none;">
                                <input type="file" id="pfpUpload" name="file" onchange="this.form.submit()"
                                       accept="image/*">
                            </form>
                            <% } %>
                        </div>

                        <h3 class="fw-bold text-dark mb-1"><%= student.getFullName() %>
                        </h3>
                        <div class="mb-4">
                            <span class="badge rounded-pill bg-primary px-3 py-2"><%= student.getStatus() %></span>
                            <span class="badge rounded-pill <%= student.getEnrolled() ? "bg-success" : "bg-danger" %> px-3 py-2 ms-1"><%= student.getEnrolled() ? "Enrolled" : "Not Enrolled" %></span>
                        </div>

                        <div class="text-start mb-4">
                            <h6 class="text-uppercase text-muted small fw-bold mb-2">Biography <% if (isOwner) { %>
                                <button class="btn btn-sm btn-link p-0 float-end" data-bs-toggle="modal"
                                        data-bs-target="#editBioModal"><i class="fa-solid fa-pen fa-xs"></i></button>
                                <% } %></h6>
                            <div class="text-dark small"><%= (student.getBiography() != null && !student.getBiography().isEmpty()) ? student.getBiography() : "No bio provided." %>
                            </div>
                        </div>

                        <div class="d-grid gap-2">
                            <% if (isOwner) { %>
                            <button class="btn btn-outline-secondary btn-sm" data-bs-toggle="modal"
                                    data-bs-target="#changePasswordModal"><i class="fa-solid fa-key me-2"></i> Password
                            </button>
                            <% } else { %>
                            <a href="mailto:<%= student.getUserEmail() %>" class="btn btn-brand btn-sm"><i
                                    class="fa-solid fa-envelope me-2"></i> Contact</a>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="col-lg-8">
                    <div class="profile-card p-4 mb-4">
                        <h5 class="fw-bold mb-4 text-primary"><i class="fa-solid fa-user-graduate me-2"></i> Academic
                            Info</h5>
                        <div class="row g-4">
                            <div class="col-md-6">
                                <div class="info-label">Email</div>
                                <div class="info-value"><%= student.getUserEmail() %>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-label">Username</div>
                                <div class="info-value"><%= student.getUsername() %>
                                </div>
                            </div>
                            <div class="col-12">
                                <hr class="text-muted opacity-25 m-0">
                            </div>
                            <div class="col-md-4">
                                <div class="info-label">Study Year</div>
                                <div class="info-value">Year <%= student.getStudyYear() %>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="info-label">Last Year's Grade</div>
                                <div class="info-value">
                                    <% if ("Company".equals(sessionRole) && !student.getGradeVisibility()) { %><span
                                        class="text-muted small fst-italic">Private</span><% } else { %>
                                    <span class="fw-bold"><%= student.getGradeFormatted() %></span>
                                    <% if (isOwner) { %>
                                    <button class="btn btn-link btn-sm p-0 ms-2" data-bs-toggle="modal"
                                            data-bs-target="#confirmHideGradeModal">
                                        <i class="fa-solid <%= student.getGradeVisibility() ? "fa-eye text-primary" : "fa-eye-slash text-muted" %>"></i>
                                    </button>
                                    <% } %>
                                    <% } %>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="info-label">Faculty</div>
                                <div class="info-value text-dark">Engineering</div>
                            </div>
                        </div>
                    </div>

                    <div class="profile-card p-4">
                        <h5 class="fw-bold mb-4 text-primary"><i class="fa-solid fa-file-pdf me-2"></i> Curriculum Vitae
                        </h5>
                        <div class="cv-container">
                            <% if (student.hasCv()) { %>
                            <i class="fa-regular fa-file-pdf cv-icon text-danger"></i>
                            <h5 class="fw-bold">Student_CV.pdf</h5>
                            <div class="d-flex justify-content-center gap-3 mt-4">
                                <a href="${pageContext.request.contextPath}/DownloadCV?id=<%= student.getId() %>"
                                   class="btn btn-brand px-4">Download</a>
                                <% if (isOwner) { %>
                                <button class="btn btn-outline-danger px-4" data-bs-toggle="modal"
                                        data-bs-target="#deleteCvModal">Delete
                                </button>
                                <% } %>
                            </div>
                            <% } else { %>
                            <i class="fa-solid fa-cloud-arrow-up cv-icon opacity-25"></i>
                            <h5>No CV Uploaded</h5>
                            <% if (isOwner) { %>
                            <button class="btn btn-outline-brand mt-3" data-bs-toggle="modal"
                                    data-bs-target="#uploadCvModal">Upload Now
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

<%-- MODALS --%>
<% if (isOwner) { %>
<div class="modal fade" id="editBioModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Edit Biography</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/StudentProfile" method="POST">
                <input type="hidden" name="action" value="update_bio">
                <div class="modal-body"><textarea name="biography" class="form-control" rows="5"
                                                  maxlength="255"><%= student.getBiography() != null ? student.getBiography() : "" %></textarea>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Save Changes</button>
                </div>
            </form>
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
                    <button type="submit" class="btn btn-brand">Update Password</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="uploadCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-light"><h5 class="modal-title fw-bold">Upload CV (PDF)</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="${pageContext.request.contextPath}/UploadCV" method="POST" enctype="multipart/form-data">
                <div class="modal-body"><input type="file" name="cvFile" class="form-control" accept=".pdf" required>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-brand">Upload</button>
                </div>
            </form>
        </div>
    </div>
</div>

<div class="modal fade" id="deleteCvModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content text-center">
            <div class="modal-body p-4"><i class="fa-solid fa-trash-can fa-3x text-danger mb-3"></i>
                <p>Delete your CV permanently?</p>
                <div class="d-flex gap-2 justify-content-center mt-3">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <a href="${pageContext.request.contextPath}/DeleteCV" class="btn btn-danger btn-sm">Confirm
                        Delete</a></div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="deletePfpModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm">
        <div class="modal-content text-center">
            <div class="modal-body p-4"><i class="fa-solid fa-image fa-3x text-danger mb-3"></i>
                <p>Remove profile photo?</p>
                <div class="d-flex gap-2 justify-content-center mt-3">
                    <button type="button" class="btn btn-light btn-sm" data-bs-dismiss="modal">Cancel</button>
                    <a href="${pageContext.request.contextPath}/DeleteProfilePicture" class="btn btn-danger btn-sm">Remove</a>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="confirmHideGradeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold">Privacy Settings</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>

            <div class="modal-body text-center py-4">
                <div class="bg-light rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 70px; height: 70px;">
                    <i class="fa-solid <%= student.getGradeVisibility() ? "fa-eye-slash text-danger" : "fa-eye text-success" %> fa-2x"></i>
                </div>
                <h6 class="fw-bold"><%= student.getGradeVisibility() ? "Hide Study Grade?" : "Show Study Grade?" %></h6>
                <p class="text-muted small mb-0">
                    <%= student.getGradeVisibility()
                            ? "Companies will no longer see your Weighted Grade Average during the application process."
                            : "Companies will now be able to see your Weighted Grade Average on your profile." %>
                </p>
            </div>

            <div class="modal-footer border-0 justify-content-center pb-4">
                <button type="button" class="btn btn-light btn-sm px-3" data-bs-dismiss="modal">Cancel</button>
                <form action="${pageContext.request.contextPath}/StudentProfile" method="POST">
                    <input type="hidden" name="action" value="toggle_grade_visibility">
                    <% if (!student.getGradeVisibility()) { %>
                    <input type="hidden" name="gradeVisibility" value="on">
                    <% } %>

                    <button type="submit" class="btn <%= student.getGradeVisibility() ? "btn-danger" : "btn-success" %> btn-sm px-3">
                        Confirm <%= student.getGradeVisibility() ? "Hide" : "Show" %>
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>