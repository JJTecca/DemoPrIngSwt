[file name]: studentPanel.jsp (Updated)
[file content begin]
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.StudentInfoDto" %>
<%@ page import="com.internshipapp.common.AccountActivityDto" %>
<%@ page import="com.internshipapp.common.UserAccountDto" %>
<%@ page import="java.util.*" %>
<%
    // Get data from request attributes
    StudentInfoDto student = (StudentInfoDto) request.getAttribute("student");
    UserAccountDto userAccount = (UserAccountDto) request.getAttribute("userAccount");
    List<AccountActivityDto> activities = (List<AccountActivityDto>) request.getAttribute("activities");
    Map<String, Object> studentStats = (Map<String, Object>) request.getAttribute("studentStats");

    // Get session data
    String userEmail = (String) session.getAttribute("userEmail");
    String userRole = (String) session.getAttribute("userRole");

    // Check if student data is available
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Internship Portal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        :root {
            --primary-color: #3498db;
            --secondary-color: #2c3e50;
            --success-color: #27ae60;
            --warning-color: #f39c12;
            --danger-color: #e74c3c;
            --info-color: #17a2b8;
            --light-bg: #f8f9fa;
            --card-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            --border-radius: 12px;
        }

        body {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding-bottom: 60px;
        }

        .dashboard-header {
            background: white;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            margin-top: 30px;
            margin-bottom: 30px;
            overflow: hidden;
            border: none;
        }

        .header-gradient {
            background: linear-gradient(90deg, var(--primary-color), var(--info-color));
            padding: 30px;
            color: white;
        }

        .user-avatar {
            width: 100px;
            height: 100px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            color: var(--primary-color);
            margin-right: 25px;
            border: 4px solid rgba(255, 255, 255, 0.3);
        }

        .info-card {
            background: white;
            border: none;
            border-radius: var(--border-radius);
            box-shadow: var(--card-shadow);
            transition: transform 0.3s, box-shadow 0.3s;
            margin-bottom: 25px;
            overflow: hidden;
        }

        .info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0, 0, 0, 0.15);
        }

        .card-header-custom {
            background: linear-gradient(90deg, var(--secondary-color), #34495e);
            color: white;
            padding: 20px;
            border-bottom: none;
            border-radius: var(--border-radius) var(--border-radius) 0 0 !important;
        }

        .stat-card {
            padding: 25px;
            border-radius: var(--border-radius);
            color: white;
            text-align: center;
            margin-bottom: 20px;
            min-height: 150px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .stat-card-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .stat-card-success {
            background: linear-gradient(135deg, var(--success-color), #229954);
        }

        .stat-card-warning {
            background: linear-gradient(135deg, var(--warning-color), #e67e22);
        }

        .stat-card-info {
            background: linear-gradient(135deg, var(--info-color), #2980b9);
        }

        .info-badge {
            font-size: 0.85rem;
            padding: 6px 12px;
            border-radius: 20px;
            font-weight: 600;
        }

        .info-item {
            padding: 15px;
            border-bottom: 1px solid #eee;
            transition: background-color 0.2s;
        }

        .info-item:hover {
            background-color: var(--light-bg);
        }

        .info-item:last-child {
            border-bottom: none;
        }

        .info-label {
            color: #666;
            font-weight: 500;
            font-size: 0.9rem;
            margin-bottom: 5px;
        }

        .info-value {
            color: var(--secondary-color);
            font-weight: 600;
            font-size: 1.1rem;
        }

        .activity-item {
            padding: 15px;
            border-left: 4px solid var(--primary-color);
            margin-bottom: 15px;
            background: var(--light-bg);
            border-radius: 8px;
            transition: transform 0.2s;
        }

        .activity-item:hover {
            transform: translateX(5px);
        }

        .logout-btn {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        .back-btn {
            position: fixed;
            bottom: 20px;
            left: 20px;
            z-index: 1000;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
        }

        @media (max-width: 768px) {
            .user-avatar {
                width: 80px;
                height: 80px;
                font-size: 36px;
                margin-right: 15px;
            }

            .stat-card {
                padding: 15px;
                min-height: 120px;
            }
        }
    </style>
</head>
<body>
<!-- Navigation Bar -->
<nav class="navbar navbar-expand-lg navbar-dark" style="background-color: var(--secondary-color);">
    <div class="container">
        <a class="navbar-brand" href="#">
            <i class="bi bi-briefcase me-2"></i>
            Internship Portal
        </a>
        <div class="navbar-text ms-auto">
            <i class="bi bi-person-circle me-2"></i>
            <span class="d-none d-md-inline"><%= student.getFullName() %></span>
            <span class="badge bg-light text-dark ms-2"><%= userRole %></span>
        </div>
    </div>
</nav>

<!-- Main Dashboard -->
<div class="container">
    <!-- Header Card -->
    <div class="dashboard-header">
        <div class="header-gradient">
            <div class="d-flex align-items-center">
                <div class="user-avatar">
                    <i class="bi bi-person-fill"></i>
                </div>
                <div class="flex-grow-1">
                    <h1 class="display-6 mb-2">Welcome back, <%= student.getFirstName() %>!</h1>
                    <p class="lead mb-0">
                        <i class="bi bi-award me-2"></i>Student Dashboard
                    </p>
                    <div class="mt-3">
                            <span class="badge bg-light text-dark me-2">
                                <i class="bi bi-envelope me-1"></i><%= userEmail %>
                            </span>
                        <span class="badge bg-light text-dark">
                                <i class="bi bi-person me-1"></i><%= userAccount != null ? userAccount.getUsername() : "N/A" %>
                            </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Stats -->
        <div class="row p-4">
            <div class="col-md-3 col-6">
                <div class="stat-card stat-card-primary">
                    <h3><i class="bi bi-person-check"></i></h3>
                    <h5>Status</h5>
                    <h4 class="mb-0">
                            <span class="badge bg-white text-dark">
                                <%= student.getStatus() %>
                            </span>
                    </h4>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-card stat-card-success">
                    <h3><i class="bi bi-mortarboard"></i></h3>
                    <h5>Study Year</h5>
                    <h2 class="mb-0"><%= student.getStudyYear() %></h2>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-card stat-card-warning">
                    <h3><i class="bi bi-graph-up"></i></h3>
                    <h5>Last Year Grade</h5>
                    <h2 class="mb-0"><%= student.getGradeFormatted() %></h2>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="stat-card stat-card-info">
                    <h3><i class="bi bi-check-circle"></i></h3>
                    <h5>Enrollment</h5>
                    <h4 class="mb-0">
                            <span class="badge bg-white text-dark">
                                <%= student.getEnrolled() ? "Enrolled" : "Not Enrolled" %>
                            </span>
                    </h4>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="row">
        <!-- Left Column: Personal Information -->
        <div class="col-lg-8">
            <!-- Personal Information Card -->
            <div class="info-card">
                <div class="card-header-custom">
                    <h4 class="mb-0"><i class="bi bi-person-badge me-2"></i>Personal Information</h4>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- Student Information -->
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">Full Name</div>
                                <div class="info-value"><%= student.getFullName() %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Student ID</div>
                                <div class="info-value">#<%= student.getId() %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Study Year</div>
                                <div class="info-value">Year <%= student.getStudyYear() %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Academic Status</div>
                                <div class="info-value">
                                        <span class="info-badge bg-<%= studentStats.get("statusColor") %>">
                                            <%= student.getStatus() %>
                                        </span>
                                </div>
                            </div>
                        </div>

                        <!-- Academic Information -->
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">Last Year Grade</div>
                                <div class="info-value">
                                        <span class="info-badge bg-<%= studentStats.get("gradeColor") %>">
                                            <%= student.getGradeFormatted() %>
                                        </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Enrollment Status</div>
                                <div class="info-value">
                                        <span class="info-badge bg-<%= studentStats.get("enrollmentColor") %>">
                                            <%= student.getEnrolled() ? "Enrolled" : "Not Enrolled" %>
                                        </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">CV Available</div>
                                <div class="info-value">
                                        <span class="info-badge <%= student.hasAttachment() ? "bg-success" : "bg-warning" %>">
                                            <%= student.hasAttachment() ? "Yes" : "No" %>
                                        </span>
                                </div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Account Linked</div>
                                <div class="info-value">
                                        <span class="info-badge <%= student.hasUserAccount() ? "bg-success" : "bg-danger" %>">
                                            <%= student.hasUserAccount() ? "Linked" : "Not Linked" %>
                                        </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Account Information Card -->
            <div class="info-card">
                <div class="card-header-custom">
                    <h4 class="mb-0"><i class="bi bi-person-circle me-2"></i>Account Information</h4>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">Username</div>
                                <div class="info-value"><%= student.getUsername() != null ? student.getUsername() : "N/A" %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Email Address</div>
                                <div class="info-value"><%= student.getUserEmail() != null ? student.getUserEmail() : "N/A" %></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">User ID</div>
                                <div class="info-value">#<%= student.getUserId() != null ? student.getUserId() : "N/A" %></div>
                            </div>
                            <div class="info-item">
                                <div class="info-label">Account Type</div>
                                <div class="info-value">
                                    <span class="info-badge bg-primary"><%= userRole %></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Activities & Quick Actions -->
        <div class="col-lg-4">
            <!-- Recent Activities Card -->
            <div class="info-card">
                <div class="card-header-custom">
                    <h4 class="mb-0"><i class="bi bi-clock-history me-2"></i>Recent Activities</h4>
                </div>
                <div class="card-body" style="max-height: 400px; overflow-y: auto;">
                    <% if (activities != null && !activities.isEmpty()) { %>
                    <% for (AccountActivityDto activity : activities) { %>
                    <div class="activity-item">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h6 class="mb-1"><%= activity.getAction() %></h6>
                                <small class="text-muted">
                                    <%= activity.getActionTime() != null ?
                                            activity.getActionTime().toString().substring(0, 16) : "N/A" %>
                                </small>
                            </div>
                            <div class="text-end">
                                <small class="text-muted">User ID: <%= activity.getUserId() %></small>
                            </div>
                        </div>
                    </div>
                    <% } %>
                    <% } else { %>
                    <div class="text-center py-4">
                        <i class="bi bi-info-circle display-4 text-muted mb-3"></i>
                        <p class="text-muted">No recent activities found</p>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Quick Actions Card -->
            <div class="info-card">
                <div class="card-header-custom">
                    <h4 class="mb-0"><i class="bi bi-lightning me-2"></i>Quick Actions</h4>
                </div>
                <div class="card-body">
                    <div class="d-grid gap-2">
                        <button class="btn btn-outline-primary btn-lg">
                            <i class="bi bi-journal-text me-2"></i>View Internships
                        </button>
                        <button class="btn btn-outline-success btn-lg">
                            <i class="bi bi-calendar-check me-2"></i>Check Schedule
                        </button>
                        <button class="btn btn-outline-info btn-lg">
                            <i class="bi bi-file-earmark-text me-2"></i>Upload Documents
                        </button>
                        <button class="btn btn-outline-warning btn-lg">
                            <i class="bi bi-chat-left-text me-2"></i>Contact Faculty
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Additional Information (if available) -->
    <% if (student.getMiddleName() != null || student.getAttachmentId() != null) { %>
    <div class="info-card mt-4">
        <div class="card-header-custom">
            <h4 class="mb-0"><i class="bi bi-info-square me-2"></i>Additional Information</h4>
        </div>
        <div class="card-body">
            <div class="row">
                <% if (student.getMiddleName() != null && !student.getMiddleName().isEmpty()) { %>
                <div class="col-md-4">
                    <div class="info-item">
                        <div class="info-label">Middle Name</div>
                        <div class="info-value"><%= student.getMiddleName() %></div>
                    </div>
                </div>
                <% } %>
                <% if (student.getAttachmentId() != null) { %>
                <div class="col-md-4">
                    <div class="info-item">
                        <div class="info-label">Attachment ID</div>
                        <div class="info-value">#<%= student.getAttachmentId() %></div>
                    </div>
                </div>
                <% } %>
                <div class="col-md-4">
                    <div class="info-item">
                        <div class="info-label">Profile Complete</div>
                        <div class="info-value">
                            <%
                                int completeness = 0;
                                if (student.getFirstName() != null) completeness += 20;
                                if (student.getLastName() != null) completeness += 20;
                                if (student.getStudyYear() != null) completeness += 20;
                                if (student.getLastYearGrade() != null) completeness += 20;
                                if (student.getUserEmail() != null) completeness += 20;
                            %>
                            <div class="progress" style="height: 10px;">
                                <div class="progress-bar bg-success" role="progressbar"
                                     style="width: <%= completeness %>%">
                                </div>
                            </div>
                            <small class="text-muted"><%= completeness %>% Complete</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <% } %>
</div>

<!-- Action Buttons -->
<div class="back-btn">
    <a href="${pageContext.request.contextPath}/UserLogin" class="btn btn-secondary btn-lg rounded-pill shadow">
        <i class="bi bi-arrow-left-circle me-2"></i>Back to Login
    </a>
</div>

<div class="logout-btn">
    <form action="${pageContext.request.contextPath}/Logout" method="post">
        <button type="submit" class="btn btn-danger btn-lg rounded-pill shadow">
            <i class="bi bi-box-arrow-right me-2"></i>Logout
        </button>
    </form>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Custom Script -->
<script>
    // Add active state to current page
    document.addEventListener('DOMContentLoaded', function() {
        // Add animation to stat cards
        const statCards = document.querySelectorAll('.stat-card');
        statCards.forEach((card, index) => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';

            setTimeout(() => {
                card.style.transition = 'opacity 0.5s, transform 0.5s';
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, index * 100);
        });

        // Auto-refresh activities every 30 seconds
        setInterval(() => {
            const activitiesSection = document.querySelector('.activity-item');
            if (activitiesSection) {
                // In a real app, you would make an AJAX call here
                console.log('Refreshing activities...');
            }
        }, 30000);

        // Add tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    });

    // Handle quick action buttons
    document.querySelectorAll('.btn-outline-primary, .btn-outline-success, .btn-outline-info, .btn-outline-warning')
        .forEach(button => {
            button.addEventListener('click', function() {
                const action = this.textContent.trim();
                alert('Action: ' + action + '\nThis feature will be implemented soon!');
            });
        });
</script>
</body>
</html>
[file content end]