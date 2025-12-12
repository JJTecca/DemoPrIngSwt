<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.InternshipPositionDto" %>
<%
    // 1. Retrieve Data from Servlet
    List<InternshipPositionDto> positions = (List<InternshipPositionDto>) request.getAttribute("positions");
    Long totalPositions = (Long) request.getAttribute("totalPositions");
    String error = (String) request.getAttribute("error");

    // 2. Session Data
    String userRole = (String) session.getAttribute("userRole");

    // Safety check for stats
    if (totalPositions == null) totalPositions = 0L;
    int displayedCount = (positions != null) ? positions.size() : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Internship Positions - CSEE ULBS</title>
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

        /* --- Header Stats --- */
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
        }

        /* --- Cards --- */
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

        .btn-brand {
            background-color: var(--brand-blue);
            color: white;
            border: none;
        }

        .btn-brand:hover {
            background-color: var(--brand-blue-dark);
            color: white;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">

        <div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
            <% if ("Student".equals(userRole)) { %>
            <h5 class="sidebar-title"><i class="fa-solid fa-graduation-cap me-2"></i> Student Portal</h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="${pageContext.request.contextPath}/Students"><i
                        class="fa-solid fa-table-columns"></i> Dashboard</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/StudentProfile"><i
                        class="fa-regular fa-id-card"></i> My Profile</a>
                <a class="nav-link active" href="${pageContext.request.contextPath}/InternshipPositions"><i
                        class="fa-solid fa-briefcase"></i> Internships</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-calendar-check"></i> Schedule</a>
            </div>
            <% } else if ("Company".equals(userRole)) { %>
            <h5 class="sidebar-title"><i class="fa-solid fa-building me-2"></i> Company Portal</h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="${pageContext.request.contextPath}/CompanyDashboard"><i
                        class="fa-solid fa-table-columns"></i> Dashboard</a>
                <a class="nav-link" href="${pageContext.request.contextPath}/CompanyProfile"><i
                        class="fa-regular fa-id-card"></i> Company Profile</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-user-friends"></i> Enrolled Interns</a>
                <a class="nav-link" href="#"><i class="fa-regular fa-comments"></i> Chats</a>
                <a class="nav-link active" href="${pageContext.request.contextPath}/InternshipPositions"><i
                        class="fa-solid fa-briefcase"></i> Positions</a>
            </div>
            <% } else if ("Admin".equals(userRole)) { %>
            <h5 class="sidebar-title"><i class="fa-solid fa-shield-halved me-2"></i> Admin Portal</h5>
            <div class="d-flex flex-column">
                <a class="nav-link" href="${pageContext.request.contextPath}/AdminDashboard"><i
                        class="fa-solid fa-table-columns"></i> Dashboard</a>
                <a class="nav-link active" href="${pageContext.request.contextPath}/InternshipPositions"><i
                        class="fa-solid fa-briefcase"></i> Manage Internships</a>
                <a class="nav-link" href="#"><i class="fa-solid fa-users"></i> Manage Users</a>
            </div>
            <% } %>

            <div class="mt-auto border-top pt-3 px-3">
                <form action="${pageContext.request.contextPath}/Logout" method="post">
                    <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start">
                        <i class="fa-solid fa-right-from-bracket"></i> Logout
                    </button>
                </form>
            </div>
        </div>

        <div class="col-md-9 col-lg-10 main-content">

            <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %>
            </div>
            <% } %>

            <div class="header-stat">
                <div class="row align-items-center">
                    <div class="col-md-8">
                        <h2 class="fw-bold mb-1"><i class="fa-solid fa-briefcase me-2"></i> Internship Opportunities
                        </h2>
                        <p class="mb-0 opacity-75">
                            Browse <strong><%= totalPositions %>
                        </strong> available positions from our partner companies.
                        </p>
                    </div>
                    <div class="col-md-4">
                        <div class="bg-white rounded p-1 shadow-sm">
                            <div class="input-group">
                                <span class="input-group-text bg-transparent border-0"><i
                                        class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                <input type="text" id="searchInput" class="form-control border-0 shadow-none"
                                       placeholder="Search by title or company...">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4" id="positionsGrid">
                <% if (positions != null && !positions.isEmpty()) { %>
                <% for (InternshipPositionDto pos : positions) { %>
                <div class="col-xl-6 position-item"
                     data-search="<%= pos.getTitle().toLowerCase() %> <%= pos.getCompanyName() != null ? pos.getCompanyName().toLowerCase() : "" %>">
                    <div class="position-card p-4">

                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div class="d-flex gap-3 align-items-center">
                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>"
                                   title="View Company Profile">
                                    <img src="https://ui-avatars.com/api/?name=<%= pos.getCompanyName() %>&background=0E2B58&color=fff&size=64"
                                         class="company-logo-small" alt="<%= pos.getCompanyName() %>">
                                </a>
                                <div>
                                    <h5 class="fw-bold mb-0 text-dark"><%= pos.getTitle() %>
                                    </h5>
                                    <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>"
                                       class="text-muted small text-decoration-none">
                                        <i class="fa-solid fa-building me-1"></i> <%= pos.getCompanyName() %>
                                    </a>
                                </div>
                            </div>
                            <span class="badge badge-spots rounded-pill" title="Filled / Total Spots">
                                    <i class="fa-solid fa-users me-1"></i>
                                    <%= (pos.getFilledSpots() != null ? pos.getFilledSpots() : 0) %> / <%= pos.getMaxSpots() %>
                                </span>
                        </div>

                        <p class="text-muted small mb-4 flex-grow-1">
                            <%= (pos.getDescription() != null && pos.getDescription().length() > 120) ?
                                    pos.getDescription().substring(0, 120) + "..." : pos.getDescription() %>
                        </p>

                        <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-3">
                            <small class="text-muted">
                                <i class="fa-regular fa-clock me-1"></i> Deadline:
                                <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %>
                            </small>

                            <% if ("Student".equals(userRole)) { %>
                            <button class="btn btn-brand btn-sm px-4 rounded-pill"
                                    data-bs-toggle="modal"
                                    data-bs-target="#applyModal<%= pos.getId() %>">
                                Apply Now
                            </button>
                            <% } else { %>
                            <button class="btn btn-outline-secondary btn-sm px-4 rounded-pill"
                                    data-bs-toggle="modal"
                                    data-bs-target="#applyModal<%= pos.getId() %>">
                                View Details
                            </button>
                            <% } %>
                        </div>

                    </div>
                </div>

                <div class="modal fade" id="applyModal<%= pos.getId() %>" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header border-0 pb-0">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body p-5 pt-0">
                                <div class="text-center mb-4">
                                    <img src="https://ui-avatars.com/api/?name=<%= pos.getCompanyName() %>&background=0E2B58&color=fff&size=80"
                                         class="rounded-circle mb-3 border p-1" width="80">
                                    <h3 class="fw-bold"><%= pos.getTitle() %>
                                    </h3>
                                    <p class="text-muted"><%= pos.getCompanyName() %>
                                    </p>
                                </div>

                                <h6 class="fw-bold text-uppercase text-muted small mt-4">Description</h6>
                                <p><%= pos.getDescription() %>
                                </p>

                                <h6 class="fw-bold text-uppercase text-muted small mt-4">Requirements</h6>
                                <p><%= pos.getRequirements() != null ? pos.getRequirements() : "No specific requirements." %>
                                </p>

                                <div class="alert alert-light border mt-4">
                                    <div class="d-flex justify-content-between">
                                        <span><i class="fa-solid fa-circle-info me-2 text-primary"></i> <strong>Deadline:</strong> <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %></span>
                                        <span><i
                                                class="fa-solid fa-users me-2 text-primary"></i> <strong>Spots:</strong> <%= pos.getMaxSpots() %></span>
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer border-0 justify-content-center pb-4">
                                <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>

                                <% if ("Student".equals(userRole)) { %>
                                <form action="ApplyForInternship" method="POST">
                                    <input type="hidden" name="positionId" value="<%= pos.getId() %>">
                                    <button type="submit" class="btn btn-brand px-5">
                                        <i class="fa-solid fa-paper-plane me-2"></i> Confirm Application
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

<jsp:include page="../blocks/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Search Filter Logic
    document.getElementById('searchInput').addEventListener('keyup', function () {
        let filter = this.value.toLowerCase();
        let cards = document.querySelectorAll('.position-item');

        cards.forEach(function (card) {
            let text = card.getAttribute('data-search');
            if (text.includes(filter)) {
                card.classList.remove('d-none');
            } else {
                card.classList.add('d-none');
            }
        });
    });
</script>

</body>
</html>