<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Import Students</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f8f9fa;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        .container {
            max-width: 1200px;
            margin-top: 30px;
            margin-bottom: 50px;
        }

        .card {
            border: none;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .card-header {
            background-color: #0E2B58;
            color: white;
            border-radius: 10px 10px 0 0 !important;
            padding: 15px 20px;
        }

        .btn-primary {
            background-color: #0E2B58;
            border-color: #0E2B58;
            padding: 8px 20px;
        }

        .btn-primary:hover {
            background-color: #0a2045;
            border-color: #0a2045;
        }

        .btn-success {
            background-color: #28a745;
            border-color: #28a745;
            padding: 8px 20px;
        }

        .btn-secondary {
            padding: 8px 20px;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            border-top: none;
        }

        .alert {
            border-radius: 8px;
            border: none;
        }

        .badge-success {
            background-color: #d1e7dd;
            color: #0f5132;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .badge-warning {
            background-color: #fff3cd;
            color: #856404;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .badge-danger {
            background-color: #f8d7da;
            color: #721c24;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .stat-box {
            background: white;
            border-radius: 8px;
            padding: 15px;
            text-align: center;
            border: 1px solid #e9ecef;
            margin-bottom: 10px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 5px;
        }

        .stat-label {
            color: #6c757d;
            font-size: 14px;
        }
    </style>
</head>
<body>
<div class="container">
    <%-- Header --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="fw-bold mb-1">
                <i class="fa-solid fa-file-import text-primary me-2"></i>Import Students
            </h2>
            <p class="text-muted mb-0">Import student data from Excel file</p>
        </div>
        <a href="${pageContext.request.contextPath}/facultyPanel.jsp" class="btn btn-outline-secondary">
            <i class="fa-solid fa-arrow-left me-1"></i>Back
        </a>
    </div>

    <%-- Messages --%>
    <c:if test="${not empty successMessage}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-check me-2"></i>${successMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="fa-solid fa-circle-exclamation me-2"></i>${errorMessage}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Debug Section --%>
    <c:if test="${not empty previewData and not empty previewData[0]}">
        <div class="alert alert-info">
            <p><strong>Debug Info:</strong> Found ${studentCount} rows</p>
            <p><strong>First row keys:</strong>
                <c:forEach items="${previewData[0].keySet()}" var="key" varStatus="loop">
                    "${key}"<c:if test="${!loop.last}">, </c:if>
                </c:forEach>
            </p>
            <p><strong>First row values:</strong>
                <c:forEach items="${previewData[0].values()}" var="value" varStatus="loop">
                    "${value}"<c:if test="${!loop.last}">, </c:if>
                </c:forEach>
            </p>
        </div>
    </c:if>

    <%-- Import Results --%>
    <c:if test="${not empty importResult}">
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0"><i class="fa-solid fa-chart-column me-2"></i>Import Results</h5>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-3">
                        <div class="stat-box">
                            <div class="stat-value text-success">${importResult.imported}</div>
                            <div class="stat-label">Imported</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-box">
                            <div class="stat-value text-warning">${importResult.skipped}</div>
                            <div class="stat-label">Skipped</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-box">
                            <div class="stat-value text-primary">${importResult.totalInFile}</div>
                            <div class="stat-label">Total in File</div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="stat-box">
                            <div class="stat-value text-info">${importResult.imported + importResult.skipped}</div>
                            <div class="stat-label">Processed</div>
                        </div>
                    </div>
                </div>

                <c:if test="${importResult.skipped > 0}">
                    <div class="alert alert-warning">
                        <h6 class="fw-bold"><i class="fa-solid fa-triangle-exclamation me-2"></i>Skipped Items:</h6>
                        <ul class="mb-0">
                            <c:forEach items="${importResult.skippedDetails}" var="detail" end="3">
                                <li class="small">${detail}</li>
                            </c:forEach>
                            <c:if test="${fn:length(importResult.skippedDetails) > 3}">
                                <li class="small">... and ${fn:length(importResult.skippedDetails) - 3} more</li>
                            </c:if>
                        </ul>
                    </div>
                </c:if>
            </div>
        </div>
    </c:if>

    <%-- Load Excel Button --%>
    <c:if test="${empty previewData}">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0"><i class="fa-solid fa-database me-2"></i>Load Excel Data</h5>
            </div>
            <div class="card-body">
                <div class="text-center py-4">
                    <i class="fa-solid fa-file-excel fa-4x text-success mb-4"></i>
                    <h4 class="mb-3">Load Students from Excel</h4>
                    <p class="text-muted mb-4">
                        Click the button below to load student data from <strong>Import.xlsx</strong> file.
                        You'll be able to preview the data before importing.
                    </p>
                    <form action="ImportStudents" method="post" class="d-inline">
                        <button type="submit" class="btn btn-primary btn-lg">
                            <i class="fa-solid fa-magnifying-glass me-2"></i>Load and Preview Excel Data
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </c:if>

        <%-- Preview Section --%>
        <c:if test="${not empty previewData}">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        <i class="fa-solid fa-eye me-2"></i>Preview Data (${studentCount} students)
                    </h5>
                    <div>
                        <form action="ImportStudents" method="post" class="d-inline me-2">
                            <input type="hidden" name="action" value="confirmImport">
                            <button type="submit" class="btn btn-success">
                                <i class="fa-solid fa-check me-1"></i>Confirm Import
                            </button>
                        </form>
                        <a href="ImportStudents" class="btn btn-secondary">
                            <i class="fa-solid fa-xmark me-1"></i>Cancel
                        </a>
                    </div>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                            <tr>
                                <th>#</th>
                                <th>Full Name</th>
                                <th>Username</th>
                                <th>Email</th>
                                <th>Study Year</th>
                                <th>Last Year Grade</th>
                                <th>Status</th>
                                <th>Enrolled</th>
                                <th>Password</th> <!-- ADDED -->
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach items="${previewData}" var="row" varStatus="loop">
                                <tr>
                                    <td>${loop.index + 1}</td>
                                    <td class="fw-semibold">${row['Full Name']}</td>
                                    <td><code>${row['Username']}</code></td>
                                    <td>${row['Email']}</td>
                                    <td>${row['Study Year']}</td>
                                    <td>
                                        <c:set var="gradeStr" value="${row['Last Year Grade']}" />
                                        <c:choose>
                                            <c:when test="${not empty gradeStr and gradeStr != ''}">
                                                <c:catch var="parseError">
                                                    <c:set var="grade" value="${Double.parseDouble(gradeStr)}" />
                                                    <c:choose>
                                                        <c:when test="${grade >= 9}">
                                                            <span class="badge-success">${grade}</span>
                                                        </c:when>
                                                        <c:when test="${grade >= 5}">
                                                            <span class="badge-warning">${grade}</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge-danger">${grade}</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:catch>
                                                <c:if test="${not empty parseError}">
                                                    <span class="badge bg-secondary">${gradeStr}</span>
                                                </c:if>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">N/A</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:set var="status" value="${row['Status']}" />
                                        <c:choose>
                                            <c:when test="${status eq 'Available'}">
                                                <span class="badge bg-success">Available</span>
                                            </c:when>
                                            <c:when test="${status eq 'Accepted'}">
                                                <span class="badge bg-primary">Accepted</span>
                                            </c:when>
                                            <c:when test="${status eq 'Completed'}">
                                                <span class="badge bg-secondary">Completed</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning">${status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${row['Enrolled'] eq 'Yes'}">
                                                <span class="badge bg-success">Yes</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-secondary">No</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><code>${row['Password']}</code></td> <!-- ADDED -->
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="card-footer">
                    <div class="alert alert-info mb-0">
                        <i class="fa-solid fa-info-circle me-2"></i>
                        <strong>Note:</strong> Students will be created with passwords from Excel file.
                    </div>
                </div>
            </div>
        </c:if>

    <%-- Instructions --%>
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0"><i class="fa-solid fa-circle-info me-2"></i>Instructions</h5>
        </div>
        <div class="card-body">
            <ol class="mb-0">
                <li>The Excel file <strong>Import.xlsx</strong> must be placed in the project's resources folder</li>
                <li>Click "Load and Preview Excel Data" to see the data</li>
                <li>Review the student information in the preview table</li>
                <li>Click "Confirm Import" to create student accounts</li>
                <li>Students can login with their username and password: <code>username123</code></li>
            </ol>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Auto-dismiss alerts after 5 seconds
    setTimeout(function() {
        var alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            var bsAlert = new bootstrap.Alert(alert);
            bsAlert.close();
        });
    }, 5000);
</script>
</body>
</html>