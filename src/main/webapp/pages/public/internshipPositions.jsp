<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.internshipapp.common.InternshipPositionDto" %>
<%
    // 1. Retrieve Data from Servlet
    List<InternshipPositionDto> positions = (List<InternshipPositionDto>) request.getAttribute("positions");
    Long totalPositions = (Long) request.getAttribute("totalPositions");
    String error = (String) request.getAttribute("error");

    // 2. Session Data
    String sessionRole = (String) session.getAttribute("userRole");

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
        /* CSS maintained exactly as provided */
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
            <% if (error != null) { %>
            <div class="alert alert-danger"><%= error %>
            </div>
            <% } %>

            <div class="header-stat">
                <div class="row align-items-center">
                    <div class="col-md-8">
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
                                       placeholder="Search...">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4" id="positionsGrid">
                <% if (positions != null && !positions.isEmpty()) { %>
                <% for (InternshipPositionDto pos : positions) {
                    // Dynamic Profile Logic
                    String companyPfp = request.getContextPath() + "/ProfilePicture?id=" + pos.getCompanyId() + "&targetRole=Company";
                    String fallbackAvatar = "https://ui-avatars.com/api/?name=" + pos.getCompanyName() + "&background=0E2B58&color=fff&size=100";
                %>
                <div class="col-xl-6 position-item"
                     data-search="<%= pos.getTitle().toLowerCase() %> <%= pos.getCompanyName().toLowerCase() %>">
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
                                       data-bs-target="#applyModal<%= pos.getId() %>">
                                        <%= pos.getTitle() %>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>"
                                       class="company-link small text-decoration-none d-block">
                                        <i class="fa-solid fa-building me-1"></i> <%= pos.getCompanyName() %>
                                    </a>
                                </div>
                            </div>
                            <span class="badge badge-spots rounded-pill">
                                <i class="fa-solid fa-users me-1"></i>
                                <%= (pos.getFilledSpots() != null ? pos.getFilledSpots() : 0) %> / <%= pos.getMaxSpots() %>
                            </span>
                        </div>

                        <p class="text-muted small mb-4 flex-grow-1">
                            <%= (pos.getDescription() != null && pos.getDescription().length() > 120) ?
                                    pos.getDescription().substring(0, 120) + "..." : pos.getDescription() %>
                        </p>

                        <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-3">
                            <small class="text-muted"><i class="fa-regular fa-clock me-1"></i>
                                Deadline: <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %>
                            </small>
                            <% if ("Student".equals(sessionRole)) { %>
                            <button class="btn btn-brand btn-sm px-4 rounded-pill" data-bs-toggle="modal"
                                    data-bs-target="#applyModal<%= pos.getId() %>">Apply Now
                            </button>
                            <% } else { %>
                            <button class="btn btn-outline-secondary btn-sm px-4 rounded-pill" data-bs-toggle="modal"
                                    data-bs-target="#applyModal<%= pos.getId() %>">View Details
                            </button>
                            <% } %>
                        </div>
                    </div>
                </div>

                <%-- Application Modal --%>
                <div class="modal fade" id="applyModal<%= pos.getId() %>" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header border-0 pb-0">
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body p-5 pt-0">
                                <div class="text-center mb-4">
                                    <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>">
                                        <img src="<%= companyPfp %>"
                                             onerror="this.onerror=null;this.src='<%= fallbackAvatar %>';"
                                             class="rounded-circle mb-3 border p-1" width="80" height="80"
                                             style="object-fit: cover;">
                                    </a>
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
                                <% if ("Student".equals(sessionRole)) { %>
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

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('searchInput').addEventListener('keyup', function () {
        let filter = this.value.toLowerCase();
        let cards = document.querySelectorAll('.position-item');
        cards.forEach(card => {
            card.classList.toggle('d-none', !card.getAttribute('data-search').includes(filter));
        });
    });
</script>
</body>
</html>