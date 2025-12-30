<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.InternshipPositionDto" %>
<%@ page import="com.internshipapp.common.InternshipApplicationDto" %>
<%
    // 1. Retrieve Data from Servlet
    List<InternshipPositionDto> positions = (List<InternshipPositionDto>) request.getAttribute("positions");
    Long totalPositions = (Long) request.getAttribute("totalPositions");
    String error = (String) request.getAttribute("error");

    // 2. Session Data
    String sessionRole = (String) session.getAttribute("userRole");
    // We assume the Company user has their Company ID stored in session to check ownership
    Long sessionCompanyId = (Long) session.getAttribute("companyId");

    // Safety check for stats
    if (totalPositions == null) totalPositions = 0L;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Internship Positions - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        .header-stat {
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;

        }

        .header-stat::after {
            content: "\f0b1";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: 20px;
            bottom: -20px;
            font-size: 8rem;
            opacity: 0.1;
            pointer-events: none;
            z-index: 1;
        }

        .col-md-3.text-end {
            position: relative;
            z-index: 10;
        }

        #tutoringFilter {
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            border-width: 2px;
            position: relative;
            z-index: 11; /* Ensures it stays above the decorative briefcase icon */
        }

        #tutoringFilter:hover {
            transform: translateY(-2px);
            background-color: rgba(255, 255, 255, 0.2);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
        }

        /* State when the filter is turned ON */
        #tutoringFilter.filter-btn-active {
            background-color: white !important;
            color: var(--brand-blue) !important;
            transform: scale(1.05);
            box-shadow: 0 4px 12px rgba(255, 255, 255, 0.3);
            font-weight: 700;
        }

        #tutoringFilter i {
            transition: transform 0.2s ease;
        }

        #tutoringFilter:hover i {
            transform: rotate(-10deg) scale(1.1);
        }

        .position-card {
            background: white;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s;
            margin-bottom: 20px;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .position-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
        }

        .company-logo-small {
            width: 50px;
            height: 50px;
            border-radius: 8px;
            object-fit: contain;
            border: 1px solid #eee;
            padding: 2px;
            background: white;
        }

        .badge-spots {
            background-color: #e3f2fd;
            color: #0d47a1;
            border: 1px solid #bbdefb;
        }

        .company-link {
            color: #777;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .company-link:hover {
            color: var(--ulbs-red);
            text-decoration: underline;
        }

        .position-title-link {
            font-weight: bold;
            color: var(--brand-blue-dark);
            text-decoration: none;
            transition: color 0.3s ease;
            display: inline-block;
        }

        .position-title-link:hover {
            color: var(--ulbs-red);
            text-decoration: underline;
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

        .btn-applied {
            background-color: #198754;
            color: white;
            border: none;
            cursor: default;
        }

        .applicant-scroll {
            max-height: 350px;
            overflow-y: auto;
        }

        .filter-btn-active {
            background-color: white !important;
            color: var(--brand-blue) !important;
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
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <%-- Sidebars logic --%>
        <% if ("Admin".equals(sessionRole)) { %>
        <jsp:include page="../blocks/adminSidebar.jsp"/>
        <% } else if ("Company".equals(sessionRole)) { %>
        <jsp:include page="../blocks/companySidebar.jsp"/>
        <% } else if ("Faculty".equals(sessionRole)) { %>
        <jsp:include page="../blocks/facultySidebar.jsp"/>
        <% } else if ("Student".equals(sessionRole)) { %>
        <jsp:include page="../blocks/studentSidebar.jsp"/>
        <% } %>

        <div class="col-md-9 col-lg-10 main-content">
            <% if (error != null || "already_applied".equals(request.getParameter("error"))) { %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <i class="fa-solid fa-triangle-exclamation me-2"></i>
                <%= "already_applied".equals(request.getParameter("error")) ? "You have already applied for this position." : error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <div class="header-stat">
                <div class="row align-items-center">
                    <div class="col-md-5">
                        <h2 class="fw-bold mb-1"><i class="fa-solid fa-briefcase me-2"></i> Internship Opportunities
                        </h2>
                        <p class="mb-0 opacity-75">Browse <strong><%= totalPositions %>
                        </strong> available positions.</p>
                    </div>
                    <div class="col-md-4">
                        <div class="bg-white rounded p-1 shadow-sm">
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-0"><i
                                        class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                <input type="text" id="searchInput" class="form-control border-0 shadow-none"
                                       placeholder="Search title or company...">
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 text-end">
                        <button id="tutoringFilter" class="btn btn-outline-light rounded-pill btn-sm">
                            <i class="fa-solid fa-chalkboard-user me-1"></i> Tutoring Only
                        </button>
                    </div>
                </div>
            </div>

            <div class="row g-4" id="positionsGrid">
                <% if (positions != null && !positions.isEmpty()) { %>
                <% for (InternshipPositionDto pos : positions) {
                    String companyPfp = request.getContextPath() + "/ProfilePicture?id=" + pos.getCompanyId() + "&targetRole=Company";
                    String fallbackAvatar = "https://ui-avatars.com/api/?name=" + pos.getCompanyName() + "&background=0E2B58&color=fff&size=100";
                    boolean isTutoring = pos.getCompanyName().toLowerCase().contains("faculty") || pos.getCompanyName().toLowerCase().contains("csee");

                    // ACCESS CONTROL LOGIC
                    boolean canSeeApplicants = "Admin".equals(sessionRole) || "Faculty".equals(sessionRole) ||
                            ("Company".equals(sessionRole) && pos.getCompanyId().equals(sessionCompanyId));
                %>
                <div class="col-xl-6 position-item"
                     data-search="<%= pos.getTitle().toLowerCase() %> <%= pos.getCompanyName().toLowerCase() %>"
                     data-tutoring="<%= isTutoring %>">
                    <div class="position-card p-4">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div class="d-flex gap-3 align-items-center">
                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>">
                                    <img src="<%= companyPfp %>"
                                         onerror="this.onerror=null;this.src='<%= fallbackAvatar %>';"
                                         class="company-logo-small" alt="Logo">
                                </a>
                                <div>
                                    <a href="#" class="position-title-link" data-bs-toggle="modal"
                                       data-bs-target="#applyModal<%= pos.getId() %>"><%= pos.getTitle() %>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>"
                                       class="company-link small text-decoration-none d-block">
                                        <i class="fa-solid fa-building me-1"></i> <%= pos.getCompanyName() %>
                                    </a>
                                </div>
                            </div>
                            <span class="badge badge-spots rounded-pill">
                                <i class="fa-solid fa-users me-1"></i> <%= (pos.getFilledSpots() != null ? pos.getFilledSpots() : 0) %> / <%= pos.getMaxSpots() %>
                            </span>
                        </div>

                        <p class="text-muted small mb-4 flex-grow-1"><%= (pos.getDescription() != null && pos.getDescription().length() > 120) ? pos.getDescription().substring(0, 120) + "..." : pos.getDescription() %>
                        </p>

                        <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-3">
                            <small class="text-muted"><i class="fa-regular fa-clock me-1"></i>
                                Deadline: <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %>
                            </small>
                            <% if ("Student".equals(sessionRole)) { %>
                            <% if (pos.isAlreadyApplied()) { %>
                            <button class="btn btn-applied btn-sm px-4 rounded-pill" disabled><i
                                    class="fa-solid fa-check me-1"></i> Already Applied
                            </button>
                            <% } else { %>
                            <button class="btn btn-brand btn-sm px-4 rounded-pill" data-bs-toggle="modal"
                                    data-bs-target="#applyModal<%= pos.getId() %>">Apply Now
                            </button>
                            <% } %>
                            <% } else { %>
                            <button class="btn btn-outline-secondary btn-sm px-4 rounded-pill" data-bs-toggle="modal"
                                    data-bs-target="#applyModal<%= pos.getId() %>">View Details
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>

                <%-- Modal Content --%>
                <div class="modal fade" id="applyModal<%= pos.getId() %>" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-lg modal-dialog-scrollable">
                        <div class="modal-content border-0">
                            <div class="modal-header border-0 pb-0">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body p-5 pt-0">
                                <div class="text-center mb-4">
                                    <img src="<%= companyPfp %>"
                                         onerror="this.onerror=null;this.src='<%= fallbackAvatar %>';"
                                         class="rounded-circle mb-3 border p-1" width="80" height="80"
                                         style="object-fit: cover;">
                                    <h3 class="fw-bold"><%= pos.getTitle() %>
                                    </h3>
                                    <p class="text-muted"><%= pos.getCompanyName() %>
                                    </p>
                                </div>

                                <div class="row">
                                    <div class="<%= (canSeeApplicants) ? "col-md-7" : "col-12" %>">
                                        <h6 class="fw-bold text-uppercase text-muted small">Description</h6>
                                        <p class="small text-secondary"><%= pos.getDescription() %>
                                        </p>
                                        <h6 class="fw-bold text-uppercase text-muted small mt-4">Requirements</h6>
                                        <p class="small text-secondary"><%= pos.getRequirements() != null ? pos.getRequirements() : "No specific requirements." %>
                                        </p>
                                    </div>

                                    <% if (canSeeApplicants) { %>
                                    <div class="col-md-5 border-start">
                                        <h6 class="fw-bold text-uppercase text-muted small mb-3"><i
                                                class="fa-solid fa-user-graduate me-2"></i>Candidates</h6>
                                        <div class="applicant-scroll">
                                            <% if (pos.getApplicants() != null && !pos.getApplicants().isEmpty()) { %>
                                            <% for (InternshipApplicationDto app : pos.getApplicants()) { %>
                                            <div class="applicant-item">
                                                <img src="${pageContext.request.contextPath}/ProfilePicture?id=<%= app.getStudentId() %>&targetRole=Student"
                                                     onerror="this.src='https://ui-avatars.com/api/?name=<%= app.getStudentName() %>&background=random';"
                                                     class="applicant-pfp">
                                                <div class="overflow-hidden">
                                                    <a href="${pageContext.request.contextPath}/StudentProfile?id=<%= app.getStudentId() %>"
                                                       class="text-decoration-none text-dark fw-bold small d-block text-truncate">
                                                        <%= app.getStudentName() %>
                                                    </a>
                                                    <span class="badge bg-light text-dark x-small"
                                                          style="font-size: 0.65rem;"><%= app.getStatus() %></span>
                                                </div>
                                            </div>
                                            <% } %>
                                            <% } else { %>
                                            <div class="text-center py-4 text-muted small">No applications yet.</div>
                                            <% } %>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>

                                <div class="alert alert-light border mt-4 m-0">
                                    <div class="d-flex justify-content-between small">
                                        <span><i class="fa-solid fa-circle-info me-2 text-primary"></i> <strong>Deadline:</strong> <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %></span>
                                        <span><i
                                                class="fa-solid fa-users me-2 text-primary"></i> <strong>Applications:</strong> <%= (pos.getApplicationsCount() != null ? pos.getApplicationsCount() : 0) %></span>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer border-0 justify-content-center pb-4">
                                <button type="button" class="btn btn-light px-4" data-bs-dismiss="modal">Close</button>
                                <% if ("Student".equals(sessionRole) && !pos.isAlreadyApplied()) { %>
                                <form action="ApplyForInternship" method="POST">
                                    <input type="hidden" name="positionId" value="<%= pos.getId() %>">
                                    <button type="submit" class="btn btn-brand px-5"><i
                                            class="fa-solid fa-paper-plane me-2"></i> Confirm Application
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
                <% } else { %>
                <div class="col-12 text-center py-5">
                    <i class="fa-regular fa-folder-open fa-3x text-muted opacity-25 mb-3"></i>
                    <p class="text-muted">No positions available at the moment.</p>
                </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<%-- Success Modal --%>
<div class="modal fade" id="successModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-body text-center p-5">
                <div class="mb-4"><i
                        class="fa-solid fa-circle-check text-success fa-4x animate__animated animate__bounceIn"></i>
                </div>
                <h4 class="fw-bold mb-2">Application Successful!</h4>
                <p class="text-muted">The company will review your application. Expect a potential message from them
                    soon!</p>
                <button type="button" class="btn btn-brand rounded-pill px-5 mt-3" data-bs-dismiss="modal">Got It
                </button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('success')) {
            new bootstrap.Modal(document.getElementById('successModal')).show();
            window.history.replaceState({}, document.title, window.location.pathname);
        }

        const searchInput = document.getElementById('searchInput');
        const tutoringBtn = document.getElementById('tutoringFilter');
        let tutoringFilterActive = false;

        function filterGrid() {
            const searchTerm = searchInput.value.toLowerCase();
            const cards = document.querySelectorAll('.position-item');
            cards.forEach(card => {
                const text = card.getAttribute('data-search');
                const isTutoring = card.getAttribute('data-tutoring') === 'true';
                card.classList.toggle('d-none', !(text.includes(searchTerm) && (!tutoringFilterActive || isTutoring)));
            });
        }

        searchInput.addEventListener('keyup', filterGrid);
        tutoringBtn.addEventListener('click', function () {
            tutoringFilterActive = !tutoringFilterActive;
            this.classList.toggle('filter-btn-active', tutoringFilterActive);
            filterGrid();
        });
    });
</script>
</body>
</html>