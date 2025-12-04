<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Internship Positions</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css">

    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .header {
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        .stats-card {
            padding: 20px;
            border-radius: 12px;
            color: white;
            margin-bottom: 20px;
            transition: transform 0.3s;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        .stats-card:hover {
            transform: translateY(-5px);
        }
        .position-card {
            border-radius: 12px;
            border: none;
            box-shadow: 0 5px 15px rgba(0,0,0,0.08);
            margin-bottom: 20px;
            transition: all 0.3s;
        }
        .position-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }
        .badge-spots {
            font-size: 0.9em;
            padding: 6px 12px;
            border-radius: 20px;
        }
        .deadline-warning {
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.7; }
            100% { opacity: 1; }
        }
    </style>
</head>
<body>
<div class="container-fluid">

    <!-- Header -->
    <div class="header">
        <div class="row align-items-center">
            <div class="col-md-8">
                <h1><i class="bi bi-briefcase-fill"></i> Internship Positions Dashboard</h1>
                <p class="mb-0">Browse and manage all available internship opportunities</p>
            </div>
            <div class="col-md-4 text-end">
                <div class="bg-white text-dark rounded p-3 d-inline-block">
                    <h4 class="mb-0"><i class="bi bi-calendar-check"></i> ${activeCount}</h4>
                    <small>Active Positions</small>
                </div>
            </div>
        </div>
    </div>

    <!-- Statistics Cards -->
    <div class="row mb-4">
        <div class="col-xl-3 col-md-6">
            <div class="stats-card bg-primary">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="display-6 fw-bold">${totalPositions}</h2>
                        <p>Total Positions</p>
                    </div>
                    <i class="bi bi-briefcase display-4 opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="stats-card bg-success">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="display-6 fw-bold">${activeCount}</h2>
                        <p>Active Positions</p>
                    </div>
                    <i class="bi bi-calendar-check display-4 opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="stats-card bg-warning">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="display-6 fw-bold">${availableCount}</h2>
                        <p>With Available Spots</p>
                    </div>
                    <i class="bi bi-person-plus display-4 opacity-50"></i>
                </div>
            </div>
        </div>
        <div class="col-xl-3 col-md-6">
            <div class="stats-card bg-info">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h2 class="display-6 fw-bold">
                            <c:if test="${stats != null}">
                                <fmt:formatNumber value="${stats.utilizationRate}" pattern="#.##"/>%
                            </c:if>
                        </h2>
                        <p>Utilization Rate</p>
                    </div>
                    <i class="bi bi-graph-up display-4 opacity-50"></i>
                </div>
            </div>
        </div>
    </div>

    <!-- Positions Grid -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="card">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="bi bi-list-ul me-2"></i>All Internship Positions</h5>
                    <span class="badge bg-primary fs-6">${positions.size()} positions</span>
                </div>
                <div class="card-body">
                    <c:choose>
                        <c:when test="${not empty positions}">
                            <div class="table-responsive">
                                <table class="table table-hover" id="positionsTable">
                                    <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Position Title</th>
                                        <th>Company</th>
                                        <th>Spots</th>
                                        <th>Applications</th>
                                        <th>Deadline</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                    </thead>
                                    <tbody>
                                    <c:forEach var="position" items="${positions}">
                                        <tr>
                                            <td><span class="badge bg-secondary">${position.id}</span></td>
                                            <td>
                                                <strong>${position.title}</strong>
                                                <c:if test="${not empty position.description}">
                                                    <div class="text-muted small mt-1" style="max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                                            ${position.description}
                                                    </div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${not empty position.companyName}">
                                                            <span class="badge bg-light text-dark">
                                                                <i class="bi bi-building"></i> ${position.companyName}
                                                            </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">No Company</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="d-flex align-items-center">
                                                    <div class="progress" style="width: 80px; height: 8px;">
                                                        <c:set var="fillPercentage" value="${position.filledSpots / position.maxSpots * 100}" />
                                                        <div class="progress-bar
                                                                <c:choose>
                                                                    <c:when test="${fillPercentage >= 100}">bg-danger</c:when>
                                                                    <c:when test="${fillPercentage >= 80}">bg-warning</c:when>
                                                                    <c:otherwise>bg-success</c:otherwise>
                                                                </c:choose>"
                                                             role="progressbar"
                                                             style="width: ${fillPercentage}%">
                                                        </div>
                                                    </div>
                                                    <span class="ms-2 small">
                                                            ${position.filledSpots}/${position.maxSpots}
                                                        </span>
                                                </div>
                                            </td>
                                            <td>
                                                    <span class="badge bg-info">
                                                        ${position.applicationsCount} apps
                                                    </span>
                                            </td>
                                            <td>
                                                <c:if test="${position.deadline != null}">
                                                    <div class="d-flex flex-column">
                                                            <span <c:if test="${position.isActive}">class="deadline-warning"</c:if>>
                                                                <fmt:formatDate value="${position.deadlineAsDate}" pattern="yyyy-MM-dd" />
                                                            </span>
                                                        <small class="text-muted">
                                                            <fmt:formatDate value="${position.deadlineAsDate}" pattern="HH:mm" />
                                                        </small>
                                                        <c:if test="${position.isActive}">
                                                            <small class="text-success">
                                                                <i class="bi bi-clock"></i> Active
                                                            </small>
                                                        </c:if>
                                                    </div>
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${position.isActive}">
                                                        <c:choose>
                                                            <c:when test="${position.availableSpots > 0}">
                                                                <span class="badge bg-success">Open</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-warning">Full</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge bg-secondary">Expired</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <div class="btn-group btn-group-sm" role="group">
                                                    <button class="btn btn-outline-primary" title="View Details">
                                                        <i class="bi bi-eye"></i>
                                                    </button>
                                                    <button class="btn btn-outline-warning" title="Edit">
                                                        <i class="bi bi-pencil"></i>
                                                    </button>
                                                    <button class="btn btn-outline-danger" title="Delete">
                                                        <i class="bi bi-trash"></i>
                                                    </button>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <i class="bi bi-briefcase display-1 text-muted mb-4"></i>
                                <h3 class="mb-3">No Internship Positions Found</h3>
                                <p class="text-muted mb-4">There are currently no internship positions available in the database.</p>
                                <button class="btn btn-primary">
                                    <i class="bi bi-plus-circle me-2"></i>Create First Position
                                </button>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <!-- Debug Panel -->
    <div class="card mt-4">
        <div class="card-header bg-light d-flex justify-content-between align-items-center"
             data-bs-toggle="collapse" data-bs-target="#debugPanel"
             style="cursor: pointer;">
            <h6 class="mb-0"><i class="bi bi-bug me-2"></i>Debug Information</h6>
            <i class="bi bi-chevron-down"></i>
        </div>
        <div class="collapse" id="debugPanel">
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Database Connection:</strong>
                            <c:choose>
                                <c:when test="${totalPositions > 0}">
                                    <span class="badge bg-success">
                                        <i class="bi bi-check-circle"></i> Connected with Data
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge bg-warning">
                                        <i class="bi bi-exclamation-triangle"></i> Connected - No Data
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </p>
                        <p><strong>Current Server Time:</strong> ${formattedDate}</p>
                        <p><strong>Context Path:</strong> ${pageContext.request.contextPath}</p>
                    </div>
                    <div class="col-md-6">
                        <p><strong>Data Loaded:</strong> ${positions.size()} positions</p>
                        <c:if test="${stats != null}">
                            <p><strong>Total Spots:</strong> ${stats.totalSpots} | <strong>Filled:</strong> ${stats.filledSpots}</p>
                            <p><strong>Companies with Positions:</strong> ${stats.companiesWithPositions}</p>
                        </c:if>
                    </div>
                </div>
                <c:if test="${not empty positions and positions.size() > 0}">
                    <hr>
                    <h6>Sample Position Data:</h6>
                    <div class="row">
                        <c:forEach var="position" items="${positions}" begin="0" end="2">
                            <div class="col-md-4">
                                <div class="bg-light p-3 rounded">
                                    <small class="text-muted">ID: ${position.id}</small><br>
                                    <strong>${position.title}</strong><br>
                                    Company: ${position.companyName}<br>
                                    Spots: ${position.filledSpots}/${position.maxSpots}<br>
                                    Status:
                                    <c:choose>
                                        <c:when test="${position.isActive}">
                                            <span class="badge bg-success">Active</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">Expired</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript Libraries -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<script>
    $(document).ready(function() {
        // Initialize DataTable
        const table = $('#positionsTable').DataTable({
            pageLength: 10,
            lengthMenu: [5, 10, 25, 50],
            order: [[0, 'asc']],
            language: {
                search: "_INPUT_",
                searchPlaceholder: "Search positions..."
            }
        });

        // Console log for debugging
        console.log("Internship Positions Dashboard Loaded");
        console.log("Total positions: ${totalPositions}");
        console.log("Active positions: ${activeCount}");
        console.log("Available positions: ${availableCount}");

        <c:if test="${not empty positions and positions.size() > 0}">
        console.log("Sample position data:", {
            id: "${positions[0].id}",
            title: "${positions[0].title}",
            company: "${positions[0].companyName}",
            spots: "${positions[0].filledSpots}/${positions[0].maxSpots}",
            status: "${positions[0].isActive ? 'Active' : 'Expired'}"
        });
        </c:if>

        // Highlight positions expiring soon
        const now = new Date();
        $('td').each(function() {
            const text = $(this).text();
            if (text.includes('Active') && $(this).find('.deadline-warning').length > 0) {
                $(this).closest('tr').addClass('table-warning');
            }
        });
    });
</script>
</body>
</html>
