<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <title>Admin Dashboard</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .sidebar { background-color: #0E2B58; min-height: 100vh; }
        .nav-link { color: white !important; }
        .nav-link:hover { background-color: #071a38; }
        .stat-card { border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
<div class="container-fluid">
    <div class="row">
        <!-- Sidebar -->
        <div class="col-md-3 col-lg-2 sidebar p-0">
            <div class="p-4">
                <h4 class="text-white mb-4">Admin Panel</h4>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a class="nav-link active" href="AdminDashboard">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#users">Manage Users</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#companies">Manage Companies</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="AdminRequests">Registration Requests</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#positions">Internship Positions</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#reports">Reports</a>
                    </li>
                    <li class="nav-item mt-4">
                        <a class="nav-link text-warning" href="${pageContext.request.contextPath}/UserLogin">Logout</a>
                    </li>
                </ul>
            </div>
        </div>

        <!-- Main Content -->
        <div class="col-md-9 col-lg-10 ms-sm-auto px-4">
            <div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
                <h1 class="h2">Admin Dashboard</h1>
                <div class="btn-toolbar mb-2 mb-md-0">
                    <div class="btn-group me-2">
                        <span class="badge bg-primary">Logged in as: ${sessionScope.userEmail}</span>
                    </div>
                </div>
            </div>

            <!-- Stats Cards -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card stat-card bg-primary text-white">
                        <div class="card-body">
                            <h5 class="card-title">Total Users</h5>
                            <h2 class="card-text">${totalUsers}</h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card bg-success text-white">
                        <div class="card-body">
                            <h5 class="card-title">Active Students</h5>
                            <h2 class="card-text">${activeStudents}</h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card bg-info text-white">
                        <div class="card-body">
                            <h5 class="card-title">Companies</h5>
                            <h2 class="card-text">${totalCompanies}</h2>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card stat-card bg-warning text-dark">
                        <div class="card-body">
                            <h5 class="card-title">Pending Requests</h5>
                            <h2 class="card-text">${pendingRequestsCount}</h2>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Pending Requests Table -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <h5>Pending Registration Requests</h5>
                            <span class="badge bg-warning">${pendingRequestsCount} pending</span>
                        </div>
                        <div class="card-body">
                            <c:choose>
                                <c:when test="${not empty pendingRequests}">
                                    <table class="table table-hover">
                                        <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Company Name</th>
                                            <th>Email</th>
                                            <th>Address</th>
                                            <th>Phone</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="req" items="${pendingRequests}">
                                            <tr>
                                                <td>${req.id}</td>
                                                <td>${req.companyName}</td>
                                                <td>${req.companyEmail}</td>
                                                <td>${req.hqAddress}</td>
                                                <td>${req.phoneNumber}</td>
                                                <td>
                                                    <span class="badge bg-warning">${req.status}</span>
                                                </td>
                                                <td>
                                                    <button class="btn btn-sm btn-success"
                                                            onclick="approveRequest(${req.id})">Approve</button>
                                                    <button class="btn btn-sm btn-danger"
                                                            onclick="rejectRequest(${req.id})">Reject</button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </c:when>
                                <c:otherwise>
                                    <div class="alert alert-info">
                                        No pending registration requests.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Activity -->
            <div class="row">
                <div class="col-12">
                    <div class="card">
                        <div class="card-header">
                            <h5>Recent Activity</h5>
                        </div>
                        <div class="card-body">
                            <table class="table table-hover">
                                <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Action</th>
                                    <th>Time</th>
                                </tr>
                                </thead>
                                <tbody>
                                <tr>
                                    <td>${sessionScope.userEmail}</td>
                                    <td>Logged in</td>
                                    <td>Just now</td>
                                </tr>
                                <c:if test="${not empty pendingRequests}">
                                    <c:forEach var="req" items="${pendingRequests}" end="2">
                                        <tr>
                                            <td>${req.companyEmail}</td>
                                            <td>Registration request submitted</td>
                                            <td>Pending</td>
                                        </tr>
                                    </c:forEach>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    function approveRequest(requestId) {
        if (confirm('Are you sure you want to approve this request?')) {
            fetch('AdminRequests?action=approve&id=' + requestId, {
                method: 'POST'
            }).then(response => {
                if (response.ok) {
                    alert('Request approved successfully!');
                    location.reload();
                } else {
                    alert('Error approving request');
                }
            });
        }
    }

    function rejectRequest(requestId) {
        if (confirm('Are you sure you want to reject this request?')) {
            fetch('AdminRequests?action=reject&id=' + requestId, {
                method: 'POST'
            }).then(response => {
                if (response.ok) {
                    alert('Request rejected successfully!');
                    location.reload();
                } else {
                    alert('Error rejecting request');
                }
            });
        }
    }
</script>
</body>
</html>