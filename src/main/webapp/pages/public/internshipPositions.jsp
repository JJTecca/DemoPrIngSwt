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
        /* 1. HEADER & LAYERING (Fixed Overflow/Z-Index) */
        .header-stat {
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            position: relative;
            /* UPDATED: Allow dropdowns to show while staying under Modals */
            overflow: visible;
            z-index: 1;
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

        /* 2. TUTORING FILTER (Updated with Descriptive Label) */
        #tutoringFilter {
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            border-width: 2px;
            position: relative;
            z-index: 1021;
            white-space: nowrap;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        /* Extension: Adds label without changing HTML structure */
        #tutoringFilter::after {
            content: "In-Faculty Tutoring";
            font-size: 0.85rem;
            pointer-events: none;
        }

        /* Hide label on very small mobile screens to prevent overflow */
        @media (max-width: 576px) {
            #tutoringFilter::after { content: "Faculty"; }
        }

        #tutoringFilter:hover {
            transform: translateY(-2px);
            background-color: rgba(255, 255, 255, 0.2);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
        }

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

        /* 3. POSITION CARDS */
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

        /* 4. BUTTONS & UI COMPONENTS */
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

        .btn-white {
            background-color: white;
            border: 1px solid #dee2e6;
            color: #495057;
            transition: all 0.3s ease;
        }

        .btn-white:hover {
            background-color: #f8f9fa;
            border-color: var(--brand-blue);
            color: var(--brand-blue);
        }

        /* 5. DROPDOWN POLISH (Open-Closed Extension) */
        .dropdown-menu {
            border-radius: 10px;
            padding: 0.5rem;
            /* UPDATED: Sits above cards but below Modal (1050) */
            z-index: 1030 !important;
            border: none;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
        }

        .dropdown-item {
            border-radius: 6px;
            padding: 0.6rem 1rem;
            font-weight: 500;
            color: #555;
            transition: all 0.2s;
            cursor: pointer;
        }

        .dropdown-item:hover {
            background-color: rgba(14, 43, 88, 0.05);
            color: var(--brand-blue);
        }

        .dropdown-header {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: #999;
            font-weight: 800;
            padding: 0.5rem 1rem;
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

        .pos-status-badge {
            font-size: 0.65rem;
            padding: 2px 8px;
            border-radius: 4px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            display: inline-block;
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
                    <div class="col-md-4">
                        <h2 class="fw-bold mb-1"><i class="fa-solid fa-briefcase me-2"></i> Internship Opportunities
                        </h2>
                        <p class="mb-0 opacity-75">Browse <strong><%= totalPositions %>
                        </strong> available positions.</p>
                    </div>

                    <div class="col-md-8">
                        <div class="d-flex gap-2 justify-content-end align-items-center">
                            <div class="bg-white rounded p-1 shadow-sm flex-grow-1" style="max-width: 400px;">
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-0"><i
                                            class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                    <input type="text" id="searchInput" class="form-control border-0 shadow-none"
                                           placeholder="Search title or company...">
                                </div>
                            </div>

                            <div class="dropdown">
                                <button id="sortButton" class="btn btn-white shadow-sm dropdown-toggle fw-bold" type="button"
                                        data-bs-toggle="dropdown" style="height: 45px; background: white;">
                                    <i class="fa-solid fa-arrow-down-wide-short me-1 text-primary"></i>
                                    <span id="sortLabel">Sort By</span>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                                    <li><h6 class="dropdown-header">Chronological</h6></li>
                                    <li><a class="dropdown-item sort-btn" href="#" data-criteria="newest"><i
                                            class="fa-solid fa-clock-rotate-left me-2 text-muted"></i>Newest First</a>
                                    </li>
                                    <li><a class="dropdown-item sort-btn" href="#" data-criteria="oldest"><i
                                            class="fa-solid fa-calendar-day me-2 text-muted"></i>Oldest First</a></li>
                                    <li>
                                        <hr class="dropdown-divider">
                                    </li>
                                    <li><h6 class="dropdown-header">Filter and Capacity</h6></li>
                                    <li><a class="dropdown-item sort-btn" href="#" data-criteria="openOnly"><i
                                            class="fa-solid fa-door-open me-2 text-success"></i>Only Open Positions</a></li>
                                    <li><a class="dropdown-item sort-btn" href="#" data-criteria="spots">
                                        <i class="fa-solid fa-users me-2 text-muted"></i>Max Spots</a></li>
                                </ul>
                            </div>

                            <button id="tutoringFilter" class="btn btn-outline-light rounded shadow-sm"
                                    style="height: 45px;">
                                <i class="fa-solid fa-chalkboard-user"></i>
                            </button>
                        </div>
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
                     data-tutoring="<%= isTutoring %>"
                     data-date="<%= pos.getDatePosted() != null ? pos.getDatePosted().getTime() : 0 %>"
                     data-spots="<%= pos.getMaxSpots() %>"
                     data-status="<%= pos.getStatus() %>">
                    <div class="position-card p-4">
                        <div class="d-flex justify-content-between align-items-start mb-3">
                            <div class="d-flex gap-3 align-items-center">
                                <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>">
                                    <img src="<%= companyPfp %>"
                                         onerror="this.onerror=null;this.src='<%= fallbackAvatar %>';"
                                         class="company-logo-small" alt="Logo">
                                </a>
                                <div>
                                    <div class="d-flex align-items-center gap-2">
                                        <a href="#" class="position-title-link" data-bs-toggle="modal"
                                           data-bs-target="#applyModal<%= pos.getId() %>"><%= pos.getTitle() %>
                                        </a>
                                        <%
                                            String status = (pos.getStatus() != null) ? pos.getStatus() : "Pending";
                                            String badgeClass = "pos-status-pending";
                                            if ("Open".equalsIgnoreCase(status)) badgeClass = "pos-status-open";
                                            else if ("Closed".equalsIgnoreCase(status)) badgeClass = "pos-status-closed";
                                        %>
                                        <span class="pos-status-badge <%= badgeClass %>">
                                            <%= status %>
                                            </span>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/CompanyProfile?id=<%= pos.getCompanyId() %>"
                                       class="company-link small text-decoration-none d-block">
                                        <i class="fa-solid fa-building me-1"></i> <%= pos.getCompanyName() %>
                                    </a>
                                </div>
                            </div>
                            <%-- Updated Badge to show Accepted / Max --%>
                            <span class="badge badge-spots rounded-pill">
                <i class="fa-solid fa-user-check me-1"></i> <%= (pos.getAcceptedCount() != null ? pos.getAcceptedCount() : 0) %> / <%= pos.getMaxSpots() %>
            </span>
                        </div>

                        <p class="text-muted small mb-4 flex-grow-1"><%= (pos.getDescription() != null && pos.getDescription().length() > 120) ? pos.getDescription().substring(0, 120) + "..." : pos.getDescription() %>
                        </p>

                        <div class="d-flex justify-content-between align-items-center mt-auto border-top pt-3">
                            <div class="d-flex flex-column">
                                <small class="text-muted"><i class="fa-regular fa-clock me-1"></i>
                                    Deadline: <%= pos.getDeadline() != null ? pos.getDeadline().toString().substring(0, 10) : "Open" %>
                                </small>
                                <small class="text-muted" style="font-size: 0.7rem;">
                                    <i class="fa-solid fa-upload me-1"></i>
                                    Posted: <%= pos.getDatePosted() != null ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(pos.getDatePosted()) : "N/A" %>
                                </small>
                            </div>
                            <% if ("Student".equals(sessionRole)) { %>
                            <% if (pos.isAlreadyApplied()) { %>
                            <button class="btn btn-applied btn-sm px-4 rounded-pill" disabled>
                                <i class="fa-solid fa-check me-1"></i> Already Applied
                            </button>
                            <% } else if ("Closed".equalsIgnoreCase(status)) { %>
                            <button class="btn btn-secondary btn-sm px-4 rounded-pill opacity-75" disabled style="cursor: not-allowed;">
                                <i class="fa-solid fa-lock me-1"></i> Closed
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
                                    <%-- Status Badge Logic --%>
                                    <%
                                        String modalStatus = (pos.getStatus() != null) ? pos.getStatus() : "Pending";
                                        String modalBadgeClass = "pos-status-pending";
                                        if ("Open".equalsIgnoreCase(modalStatus)) modalBadgeClass = "pos-status-open";
                                        else if ("Closed".equalsIgnoreCase(modalStatus)) modalBadgeClass = "pos-status-closed";
                                    %>
                                    <div class="mb-2">
                                        <span class="pos-status-badge <%= modalBadgeClass %>" style="font-size: 0.75rem; padding: 4px 12px;">
                                            <%= modalStatus %> Status
                                        </span>
                                    </div>
                                    <img src="<%= companyPfp %>"
                                         onerror="this.onerror=null;this.src='<%= fallbackAvatar %>';"
                                         class="rounded-3 mb-3 border p-1" width="80" height="80"
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
                                <% if ("Student".equals(sessionRole)) { %>

                                <% if ("Closed".equalsIgnoreCase(modalStatus)) { %>
                                <button class="btn btn-secondary px-5 opacity-50" disabled style="cursor: not-allowed;">
                                    <i class="fa-solid fa-lock me-2"></i> Position Closed
                                </button>

                                <%-- 3. Then check if they already applied --%>
                                <% } else if (pos.isAlreadyApplied()) { %>
                                <button class="btn btn-applied px-5" disabled>
                                    <i class="fa-solid fa-check me-2"></i> Application Sent
                                </button>

                                <%-- 4. Only if Open and Not Applied, show the form --%>
                                <% } else { %>
                                <form action="ApplyForInternship" method="POST">
                                    <input type="hidden" name="positionId" value="<%= pos.getId() %>">
                                    <button type="submit" class="btn btn-brand px-5">
                                        <i class="fa-solid fa-paper-plane me-2"></i> Confirm Application
                                    </button>
                                </form>
                                <% } %>
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
        // Success Modal Logic
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('success')) {
            new bootstrap.Modal(document.getElementById('successModal')).show();
            window.history.replaceState({}, document.title, window.location.pathname);
        }

        const searchInput = document.getElementById('searchInput');
        const tutoringBtn = document.getElementById('tutoringFilter');
        const positionsGrid = document.getElementById('positionsGrid');

        let tutoringFilterActive = false;
        let openOnlyFilterActive = false;

        // --- MASTER FILTER FUNCTION ---
        // This function checks EVERYTHING (Search, Tutoring, Status)
        function applyAllFilters() {
            const searchTerm = searchInput.value.toLowerCase();
            const cards = document.querySelectorAll('.position-item');

            cards.forEach(card => {
                const text = card.getAttribute('data-search');
                const isTutoring = card.getAttribute('data-tutoring') === 'true';
                const status = card.getAttribute('data-status');

                const matchesSearch = text.includes(searchTerm);
                const matchesCategory = (tutoringFilterActive === isTutoring);
                const matchesStatus = !openOnlyFilterActive || (status === 'Open');

                // Show only if ALL active filters match
                card.classList.toggle('d-none', !(matchesSearch && matchesCategory && matchesStatus));
            });
        }

// Variable to store the "base" sort text
        let currentSortLabel = "Sort By";

        document.querySelectorAll('.sort-btn').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                const criteria = this.getAttribute('data-criteria');
                const sortLabelElement = document.getElementById('sortLabel');

                // CASE 1: TOGGLE FILTER (Open Only)
                if (criteria === 'openOnly') {
                    openOnlyFilterActive = !openOnlyFilterActive;

                    // Toggle visual state of the specific dropdown item
                    this.classList.toggle('fw-bold', openOnlyFilterActive);
                    this.classList.toggle('text-primary', openOnlyFilterActive);
                    this.querySelector('i').classList.toggle('text-success', openOnlyFilterActive);

                    // Update Label: If filter is OFF, go back to the base sort. If ON, show filter.
                    sortLabelElement.innerText = openOnlyFilterActive ? "Only Open Positions" : currentSortLabel;

                    applyAllFilters();
                    return;
                }

                // CASE 2: ACTUAL SORTING (Newest, Oldest, Spots)
                // 1. Remove active effect from all OTHER sort-only buttons
                document.querySelectorAll('.sort-btn[data-criteria]:not([data-criteria="openOnly"])')
                    .forEach(b => b.classList.remove('fw-bold', 'text-primary'));

                // 2. Add active effect to THIS button
                this.classList.add('fw-bold', 'text-primary');

                // 3. Update the "Memory" of what the sort is
                currentSortLabel = this.innerText;

                // 4. Update UI: If "Open Only" is active, don't overwrite the label yet
                if (!openOnlyFilterActive) {
                    sortLabelElement.innerText = currentSortLabel;
                }

                // Execution of the Sort
                const items = Array.from(positionsGrid.querySelectorAll('.position-item'));
                items.sort((a, b) => {
                    const dateA = parseInt(a.getAttribute('data-date')) || 0;
                    const dateB = parseInt(b.getAttribute('data-date')) || 0;
                    const spotsA = parseInt(a.getAttribute('data-spots')) || 0;
                    const spotsB = parseInt(b.getAttribute('data-spots')) || 0;

                    if (criteria === 'newest') return dateB - dateA;
                    if (criteria === 'oldest') return dateA - dateB;
                    if (criteria === 'spots') return spotsB - spotsA;
                    return 0;
                });

                items.forEach(item => positionsGrid.appendChild(item));
                applyAllFilters();
            });
        });

        // --- EVENT LISTENERS ---
        tutoringBtn.addEventListener('click', function () {
            tutoringFilterActive = !tutoringFilterActive;
            this.classList.toggle('filter-btn-active', tutoringFilterActive);
            applyAllFilters();
        });

        searchInput.addEventListener('keyup', applyAllFilters);

        // Initial Run on Page Load
        applyAllFilters();
    });
</script>
</body>
</html>