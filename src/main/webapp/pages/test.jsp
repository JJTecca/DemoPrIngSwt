<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Students - Internship Platform</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">

    <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background-color: #f8f9fa;
        }
        .header {
            background-color: #007bff;
            color: white;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .stats-card {
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
            color: white;
            text-align: center;
        }
        table {
            background-color: white;
            border-radius: 5px;
            overflow: hidden;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
    </style>
</head>
<body>
<div class="container">
    <!-- Header -->
    <div class="header">
        <h1><i class="bi bi-people"></i> Students Management</h1>
        <p>Total students in database: ${totalStudents}</p>
    </div>

    <!-- Statistics -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="stats-card bg-primary">
                <h4>${totalStudents}</h4>
                <p>Total Students</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card bg-success">
                <h4>${availableStudents}</h4>
                <p>Available</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card bg-warning">
                <h4>${acceptedStudents}</h4>
                <p>Accepted</p>
            </div>
        </div>
        <div class="col-md-3">
            <div class="stats-card bg-info">
                <h4>${completedStudents}</h4>
                <p>Completed</p>
            </div>
        </div>
    </div>

    <!-- Students Table -->
    <div class="card">
        <div class="card-header bg-white">
            <h5 class="mb-0">Students List</h5>
        </div>
        <div class="card-body">
            <c:choose>
                <c:when test="${not empty students}">
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>First Name</th>
                                <th>Last Name</th>
                                <th>Study Year</th>
                                <th>Grade</th>
                                <th>Status</th>
                                <th>Enrolled</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="student" items="${students}">
                                <tr>
                                    <td>${student.id}</td>
                                    <td>${student.firstName}</td>
                                    <td>${student.lastName}</td>
                                    <td>Year ${student.studyYear}</td>
                                    <td>
                                                <span class="badge ${student.lastYearGrade >= 9 ? 'bg-success' :
                                                                    student.lastYearGrade >= 8 ? 'bg-warning' : 'bg-danger'}">
                                                        ${student.lastYearGrade}
                                                </span>
                                    </td>
                                    <td>
                                                <span class="badge bg-${student.status == 'Available' ? 'success' :
                                                                     student.status == 'Accepted' ? 'warning' : 'info'}">
                                                        ${student.status}
                                                </span>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${student.enrolled}">
                                                <span class="badge bg-success">Yes</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger">No</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>

                    <div class="mt-3 text-muted">
                        <p>Showing ${students.size()} students</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="text-center py-5">
                        <i class="bi bi-people display-1 text-muted"></i>
                        <h5 class="mt-3">No students found</h5>
                        <p class="text-muted">The students table appears to be empty.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>

    <!-- Debug Info (remove in production) -->
    <div class="mt-4 card">
        <div class="card-header bg-light">
            <h6 class="mb-0">Debug Information</h6>
        </div>
        <div class="card-body">
            <p><strong>Database Status:</strong>
                <c:choose>
                    <c:when test="${totalStudents > 0}">
                        <span class="badge bg-success">Connected - Data Found</span>
                    </c:when>
                    <c:otherwise>
                        <span class="badge bg-warning">Connected - No Data</span>
                    </c:otherwise>
                </c:choose>
            </p>
            <p><strong>Servlet Context:</strong> ${pageContext.request.contextPath}</p>
            <p><strong>Students List Size:</strong> ${students.size()}</p>
        </div>
    </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>