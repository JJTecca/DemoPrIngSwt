<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard - CSEE ULBS</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
        /* Shared Roots matching Login */
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

        /* --- Sidebar Styling --- */
        .sidebar-container {
            background-color: white;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
            min-height: 100%; /* approximate header height */
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
            border-left-color: var(--ulbs-red); /* Red accent for active */
            font-weight: 700;
        }

        .nav-link i {
            width: 25px;
            text-align: center;
            margin-right: 10px;
        }

        /* --- Content Styling --- */
        .main-content {
            padding: 2rem;
        }

        .page-title {
            color: var(--brand-blue-dark);
            font-weight: 700;
            margin-bottom: 1.5rem;
        }

        /* --- Modern Stats Cards --- */
        .stat-card {
            background: white;
            border: none;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s;
            overflow: hidden;
            position: relative;
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

        /* Card Accent Colors */
        .card-users::before {
            background-color: var(--brand-blue);
        }

        .card-students::before {
            background-color: #008080;
        }

        /* Teal */
        .card-companies::before {
            background-color: #444;
        }

        .card-pending::before {
            background-color: var(--ulbs-red);
        }

        .stat-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--brand-blue-dark);
            margin-bottom: 0;
        }

        .stat-label {
            color: #888;
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }

        .stat-icon {
            position: absolute;
            right: 20px;
            bottom: 20px;
            font-size: 3rem;
            opacity: 0.05;
            color: black;
        }

        /* --- Tables --- */
        .custom-card {
            border: none;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border-radius: 8px;
            margin-bottom: 2rem;
        }

        .custom-card .card-header {
            background-color: white;
            border-bottom: 1px solid #eee;
            padding: 1.2rem;
        }

        .table thead th {
            background-color: var(--brand-blue);
            color: white;
            font-weight: 500;
            border: none;
        }

        /* Action Buttons */
        .btn-approve {
            background-color: #28a745;
            color: white;
            border: none;
        }

        .btn-reject {
            background-color: var(--ulbs-red);
            color: white;
            border: none;
        }

        .btn-reject:hover {
            background-color: #7a0808;
            color: white;
        }

        .badge-pending {
            background-color: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }

    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">

        <div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
            <h5 class="sidebar-title">
                <i class="fa-solid fa-screwdriver-wrench me-2"></i> Admin Panel
            </h5>
            <div class="d-flex flex-column">
                <a class="nav-link active" href="AdminDashboard">
                    <i class="fa-solid fa-chart-line"></i> Dashboard
                </a>
                <a class="nav-link" href="#users">
                    <i class="fa-solid fa-users"></i> Manage Users
                </a>
                <a class="nav-link" href="#companies">
                    <i class="fa-solid fa-building"></i> Manage Companies
                </a>
                <a class="nav-link" href="AdminRequests">
                    <i class="fa-solid fa-envelope-open-text"></i> Requests
                    <c:if test="${pendingRequestsCount > 0}">
                        <span class="badge rounded-pill bg-danger float-end">${pendingRequestsCount}</span>
                    </c:if>
                </a>
                <a class="nav-link" href="#positions">
                    <i class="fa-solid fa-briefcase"></i> Internships
                </a>
                <a class="nav-link" href="#reports">
                    <i class="fa-solid fa-file-pdf"></i> Reports
                </a>

                <div class="mt-5 border-top pt-3">
                    <a class="nav-link text-danger" href="${pageContext.request.contextPath}/UserLogin">
                        <i class="fa-solid fa-right-from-bracket"></i> Logout
                    </a>
                </div>
            </div>
        </div>

        <div class="col-md-9 col-lg-10 main-content">

            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1 class="h2 page-title">Dashboard Overview</h1>
                <span class="text-muted small"><i class="fa-regular fa-clock me-1"></i> Today's Summary</span>
            </div>

            <div class="row mb-5 g-4">
                <div class="col-md-3">
                    <div class="card stat-card card-users h-100 p-3">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h2 class="stat-value">${totalUsers}</h2>
                                <span class="stat-label">Total Users</span>
                            </div>
                            <i class="fa-solid fa-users stat-icon"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card stat-card card-students h-100 p-3">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h2 class="stat-value">${activeStudents}</h2>
                                <span class="stat-label">Active Students</span>
                            </div>
                            <i class="fa-solid fa-user-graduate stat-icon"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card stat-card card-companies h-100 p-3">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h2 class="stat-value">${totalCompanies}</h2>
                                <span class="stat-label">Partner Companies</span>
                            </div>
                            <i class="fa-solid fa-building stat-icon"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card stat-card card-pending h-100 p-3">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h2 class="stat-value text-danger">${pendingRequestsCount}</h2>
                                <span class="stat-label text-danger">Pending Requests</span>
                            </div>
                            <i class="fa-solid fa-circle-exclamation stat-icon"></i>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <div class="card custom-card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5 class="mb-0 fw-bold" style="color: var(--brand-blue);">
                                <i class="fa-solid fa-list-check me-2"></i> Pending Company Approvals
                            </h5>
                        </div>
                        <div class="card-body p-0">
                            <c:choose>
                                <c:when test="${not empty pendingRequests}">
                                    <div class="table-responsive">
                                        <table class="table table-hover align-middle mb-0">
                                            <thead>
                                            <tr>
                                                <th class="ps-4">Company</th>
                                                <th>Contact Info</th>
                                                <th>Address</th>
                                                <th>Status</th>
                                                <th class="text-end pe-4">Actions</th>
                                            </tr>
                                            </thead>
                                            <tbody>
                                            <c:forEach var="req" items="${pendingRequests}">
                                                <tr>
                                                    <td class="ps-4">
                                                        <div class="fw-bold text-dark">${req.companyName}</div>
                                                        <div class="small text-muted">ID: #${req.id}</div>
                                                    </td>
                                                    <td>
                                                        <div class="small"><i
                                                                class="fa-solid fa-envelope me-1"></i> ${req.companyEmail}
                                                        </div>
                                                        <div class="small"><i
                                                                class="fa-solid fa-phone me-1"></i> ${req.phoneNumber}
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <span class="small text-muted">${req.hqAddress}</span>
                                                    </td>
                                                    <td>
                                                        <span class="badge badge-pending">
                                                            <i class="fa-solid fa-clock me-1"></i> ${req.status}
                                                        </span>
                                                    </td>
                                                    <td class="text-end pe-4">
                                                        <button class="btn btn-sm btn-approve me-1"
                                                                onclick="approveRequest(${req.id})"
                                                                title="Approve">
                                                            <i class="fa-solid fa-check"></i>
                                                        </button>
                                                        <button class="btn btn-sm btn-reject"
                                                                onclick="rejectRequest(${req.id})"
                                                                title="Reject">
                                                            <i class="fa-solid fa-xmark"></i>
                                                        </button>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="p-5 text-center text-muted">
                                        <i class="fa-regular fa-folder-open fa-3x mb-3 opacity-25"></i>
                                        <p>No pending registration requests found.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row">
                <div class="col-12">
                    <h5 class="text-muted mb-3 fs-6 text-uppercase ls-1">System Logs</h5>
                    <div class="list-group shadow-sm">
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            <div>
                                <i class="fa-solid fa-user-shield text-primary me-2"></i>
                                <strong>${sessionScope.userEmail}</strong> logged into the admin panel.
                            </div>
                            <span class="text-muted small">Just now</span>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function approveRequest(requestId) {
        if (confirm('Are you sure you want to approve this request? This will grant the company access.')) {
            fetch('TokenApproval?action=approve&id=' + requestId, {
                method: 'POST'
            }).then(response => {
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Error approving request. Check console for details.');
                }
            });
        }
    }

    function rejectRequest(requestId) {
        if (confirm('Are you sure you want to reject this request? This action cannot be undone.')) {
            fetch('TokenApproval?action=reject&id=' + requestId, {
                method: 'POST'
            }).then(response => {
                if (response.ok) {
                    location.reload();
                } else {
                    alert('Error rejecting request.');
                }
            });
        }
    }
</script>
</body>
</html>