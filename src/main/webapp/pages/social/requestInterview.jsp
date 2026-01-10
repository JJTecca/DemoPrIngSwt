<%@ page import="com.internshipapp.common.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    List<StudentInfoDto> students = (List<StudentInfoDto>) request.getAttribute("studentUsers");
    List<InternshipPositionDto> positions = (List<InternshipPositionDto>) request.getAttribute("companyPositions");
    Map<Long, List<InternshipApplicationDto>> appsMap = (Map<Long, List<InternshipApplicationDto>>) request.getAttribute("studentAppsMap");
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("company");

    // Calculate counts for the header
    long requestedCount = 0;
    long browseableCount = 0;

    if (students != null) {
        for (StudentInfoDto s : students) {
            List<InternshipApplicationDto> apps = (appsMap != null) ? appsMap.get(s.getUserId()) : null;
            boolean isRequested = apps != null && apps.stream().anyMatch(a -> "Request".equalsIgnoreCase(a.getStatus()));

            if (isRequested) {
                requestedCount++;
                browseableCount++;
            } else {
                // Check other exclusion rules (Hired/Accepted) to match your grid logic
                String status = s.getStatus() != null ? s.getStatus() : "Available";
                if (!status.equals("Accepted") && !status.equals("Completed")) {
                    browseableCount++;
                }
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Potential Interns - CSEE Internship Program - </title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        body {
            background-color: #f4f7f9;
        }

        /* --- Banner Fixes (Synced with Positions Page) --- */
        .header-stat {
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white;
            border-radius: 12px;
            padding: 2rem;
            margin-bottom: 2rem;
            position: relative;
            /* Changed to visible so filter dropdown is not clipped */
            overflow: visible;
            box-shadow: 0 8px 30px rgba(14, 43, 88, 0.15);
            z-index: 1;
        }

        /* Large Background Icon */
        .header-stat::after {
            content: "\f002"; /* Magnifying Glass */
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: 20px;
            bottom: -20px;
            font-size: 8rem;
            opacity: 0.1;
            pointer-events: none;
            z-index: 0;
        }

        /* Ensure content is above background icon */
        .header-stat .row {
            position: relative;
            z-index: 2;
        }

        #studentSearch {
            border: none;
            box-shadow: none;
            padding-left: 0.7rem;
            height: 45px;
            border-radius: 8px;
            flex-grow: 1;
        }

        .btn-filter-hub {
            height: 45px;
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 8px !important;
            padding: 0 1.5rem;
            font-weight: 700;
            color: #495057;
            transition: all 0.3s ease;
        }

        .btn-filter-hub:hover {
            border-color: var(--brand-blue);
            background: #f8f9fa;
            color: var(--brand-blue);
            transform: translateY(-2px);
        }

        .bg-white.rounded.p-1.shadow-sm {
            height: 45px !important; /* Force match with Filter Button */
            display: flex !important;
            align-items: center !important;
            padding: 0 10px !important; /* Horizontal padding only */
            overflow: hidden;
        }

        .input-group {
            height: 100% !important;
            display: flex !important;
            align-items: center !important;
            flex-wrap: nowrap !important; /* Prevent splitting into 2 rows */
        }

        /* Ensure the button doesn't darken/change color on hover while open */
        .btn-filter-hub.show,
        .btn-filter-hub.show:hover {
            background-color: white !important;
            border-color: #dee2e6 !important;
            color: inherit !important;
        }

        /* --- Student Results Grid --- */
        #studentGrid {
            background: white;
            border-radius: 16px;
            /* High visibility separation border */
            border: 1.5px solid #cbd5e1;
            overflow: hidden;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        .student-item {
            background: white;
            /* Sharp Gray Separation Line */
            border-bottom: 1.5px solid #cbd5e1;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            position: relative;
        }

        .student-item:last-child {
            border-bottom: none;
        }

        .student-item:hover {
            background-color: #f8faff;
            transform: translateX(8px);
            box-shadow: inset 4px 0 0 var(--brand-blue);
        }

        .student-row-body {
            display: flex;
            align-items: flex-start;
            padding: 1.5rem 2rem;
        }

        /* --- Circular Avatar --- */
        .student-avatar-small {
            width: 60px;
            height: 60px;
            border-radius: 50% !important;
            object-fit: cover;
            border: 3px solid white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            transition: transform 0.3s ease;
        }

        .student-item:hover .student-avatar-small {
            transform: scale(1.1);
        }

        /* --- Refined Badges & Typography --- */
        .status-badge {
            font-size: 0.65rem;
            padding: 0.4em 1em;
            border-radius: 50px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border: 1px solid transparent;
        }

        .student-name {
            font-weight: 700;
            font-size: 1.3rem;
            color: #333333;
            text-decoration: none;
            display: block;
            margin-bottom: 0.2rem;
        }

        .badge-email {
            background-color: #f1f5f9;
            color: #334155;
            border: 1px solid #e2e8f0;
            font-weight: 700; /* Bolded Email */
            font-size: 0.85rem; /* Bigger Email */
            text-transform: none !important;
            letter-spacing: normal !important;
        }

        .status-available {
            background-color: #e6f6ec;
            color: #0f5132;
            border-color: #d1ead9;
        }

        .status-busy {
            background-color: #f5f5f5;
            color: #616161;
            border-color: #e2e8f0;
        }

        .status-linked {
            background-color: #e8effe;
            color: #0d6efd;
            border-color: #d0e0fc;
        }

        /* --- Consistently Blue Request Button --- */
        .btn-request-small {
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white;
            border: none;
            padding: 0.5rem 1.2rem;
            border-radius: 8px;
            font-weight: 700;
            font-size: 0.72rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.3s ease;
            margin-top: 12px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            box-shadow: 0 4px 10px rgba(14, 43, 88, 0.2);
        }

        .btn-request-small:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 15px rgba(14, 43, 88, 0.3);
            color: white;
        }

        /* --- Simplistic & Professional Modal --- */
        .interview-form {
            max-width: 550px;
            border: none;
            border-radius: 16px;
            background: white;
        }

        .modal-header-simple {
            padding: 2rem 1.5rem 1.5rem;
            border-bottom: 1px solid #eee;
            background: #fff;
        }

        /* Fix for the Close Button Animation conflict */
        .modal-close {
            position: absolute;
            top: 1rem;
            right: 1rem;
            border: none;
            background: #f8f9fa;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            color: #adb5bd;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.2s ease;
            z-index: 100;
        }

        .modal-close:hover {
            background: #dc3545;
            color: white;
        }

        /* Professional Tab Bar */
        .nav-tabs-custom {
            background: #f8fafc;
            border-bottom: 1px solid #eee;
            padding: 0 1rem;
        }

        .nav-tabs-custom .nav-link {
            border: none;
            color: #64748b;
            font-weight: 700;
            padding: 1rem 1.2rem;
            font-size: 0.85rem;
            text-transform: uppercase;
            transition: all 0.3s;
            border-bottom: 3px solid transparent;
        }

        .nav-tabs-custom .nav-link.active {
            color: var(--brand-blue);
            background: transparent;
            border-bottom-color: var(--brand-blue);
        }

        .modal-student-avatar {
            width: 65px;
            height: 65px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #fff;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        /* Selection Box (Dashboard Style) */
        .action-card-simple {
            background-color: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 1.5rem;
        }

        /* Form labels sync with dashboard */
        .form-label-dashboard {
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 800;
            color: #94a3b8;
            margin-bottom: 0.5rem;
            display: block;
        }

        .selection-context-box {
            background: #f1f5f9;
            padding: 1.5rem;
            border-radius: 16px;
            border: 1px solid #e2e8f0;
        }

        .btn-filter-hub.dropdown-show-active #filterLabel {
            opacity: 0 !important;
            visibility: hidden !important;
        }

        /* Ensure the icon stays visible and becomes the primary brand blue when active */
        .btn-filter-hub.dropdown-show-active i {
            opacity: 1 !important;
            visibility: visible !important;
        }

        .student-filter.active-filter {
            color: #00ace6 !important;
            font-weight: 700 !important;
        }

        #filterLabel {
            transition: opacity 0.5s ease-in-out;
        }

        .label-fade-out {
            opacity: 0;
        }

        /* Modal Styles */
        .interview-form-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(14, 43, 88, 0.75);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 2000;
        }

        .interview-form {
            background: white;
            border-radius: 24px;
            padding: 2.5rem;
            width: 95%;
            max-width: 550px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            position: relative;
            animation: slideUp 0.4s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(40px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .modal-close {
            position: absolute;
            top: 1.5rem;
            right: 1.5rem;
            border: none;
            background: #f8f9fa;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            color: #999;
            cursor: pointer;
            transition: 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-close:hover {
            background: #dc3545;
            color: white;
            transform: rotate(90deg);
        }

        /* --- Modal & Tabs Styling --- */
        .interview-form-modal {
            background: rgba(0, 0, 0, 0.6); /* Standard Darken Overlay */
        }

        .interview-form {
            max-width: 650px; /* Slightly wider for tabs */
            padding: 0; /* Let content handle padding */
            overflow: hidden;
        }

        .modal-content-wrapper {
            padding: 2.5rem;
        }

        .nav-tabs-custom {
            border-bottom: 1px solid #eee;
            background: #f8fafc;
            padding: 0 1rem;
        }

        .nav-tabs-custom .nav-link {
            border: none;
            color: #64748b;
            font-weight: 600;
            padding: 1rem 1.5rem;
            font-size: 0.9rem;
            transition: all 0.3s;
        }

        .nav-tabs-custom .nav-link.active {
            color: var(--brand-blue);
            background: transparent;
            border-bottom: 3px solid var(--brand-blue);
        }

        .tab-pane {
            padding-top: 1.5rem;
        }

        .empty-state {
            text-align: center;
            padding: 2rem;
            color: #94a3b8;
        }

        .application-row {
            background: #f1f5f9;
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 0.75rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <jsp:include page="../blocks/companySidebar.jsp"/>

        <div class="col-md-9 col-lg-10 main-content py-4 px-4">

            <div class="header-stat">
                <div class="row align-items-center">
                    <div class="col-md-5">
                        <h2 class="fw-bold mb-1">
                            <i class="fa-solid fa-magnifying-glass me-2"></i>Search Potential Interns
                        </h2>
                        <%if (requestedCount == 0) { %>
                        <p class="mb-0 opacity-75">
                            Browse <strong><%= browseableCount %></strong> available students.
                        </p>
                        <% } else if (requestedCount == 1) { %>
                        <p class="mb-0 opacity-75">
                            Browse <strong><%= browseableCount %></strong> available students,
                            <span class="text-white-50">of which <strong><%= requestedCount %></strong> is requested.</span>
                        </p>
                        <% } else if (requestedCount >= 2) { %>
                        <p class="mb-0 opacity-75">
                            Browse <strong><%= browseableCount %></strong> available students,
                            <span class="text-white-50">of which <strong><%= requestedCount %></strong> are requested.</span>
                        </p>
                        <% } %>
                    </div>

                    <div class="col-md-7">
                        <div class="d-flex gap-2 justify-content-end align-items-center">
                            <div class="bg-white rounded p-1 shadow-sm flex-grow-1" style="max-width: 400px; max-height:55px;">
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-0"><i
                                            class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                    <input type="text" id="studentSearch" class="form-control border-0 shadow-none"
                                           placeholder="Search by name or email...">
                                </div>
                            </div>

                            <div class="dropdown">
                                <button id="filterButton"
                                        class="btn btn-light btn-filter-hub shadow-sm dropdown-toggle fw-bold"
                                        type="button" data-bs-toggle="dropdown">
                                    <i class="fa-solid fa-filter me-1 text-primary"></i>
                                    <span id="filterLabel">Show All</span>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0">
                                    <li><a class="dropdown-item student-filter" href="#" data-filter="all"><i
                                            class="fa-solid fa-users me-2 text-muted"></i>Show All</a></li>

                                    <li><h6 class="dropdown-header">Academic Sort</h6></li>
                                    <li><a class="dropdown-item student-filter" href="#" data-filter="grade"><i
                                            class="fa-solid fa-graduation-cap me-2 text-success"></i>By Study Grade</a>
                                    </li>
                                    <li><a class="dropdown-item student-filter" href="#" data-filter="year"><i
                                            class="fa-solid fa-layer-group me-2 text-info"></i>By Year of Study</a></li>

                                    <li>
                                        <hr class="dropdown-divider">
                                    </li>
                                    <li><h6 class="dropdown-header">Connection History</h6></li>
                                    <li><a class="dropdown-item student-filter" href="#" data-filter="new"><i
                                            class="fa-solid fa-user-plus me-2 text-muted"></i>No Connection</a></li>
                                    <li><a class="dropdown-item student-filter" href="#" data-filter="previous"><i
                                            class="fa-solid fa-link me-2 text-primary"></i>Applied To You</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-0" id="studentGrid">
                <%
                    if (students != null) {
                        for (StudentInfoDto studentRow : students) {
                            // Skip if not Available or if already placed (Logic as requested)
                            String sStatus = studentRow.getStatus() != null ? studentRow.getStatus() : "Available";
                            if (sStatus.equals("Accepted") || sStatus.equals("Completed")) continue;

                            Double grade = (studentRow.getLastYearGrade() != null) ? studentRow.getLastYearGrade() : 0.0;
                            Integer year = (studentRow.getStudyYear() != null) ? studentRow.getStudyYear() : 1;

                            // Privacy Check
                            boolean hideGrade = !studentRow.getGradeVisibility();

                            List<InternshipApplicationDto> studentApps = (appsMap != null) ? appsMap.get(studentRow.getUserId()) : null;
                            boolean hasActiveRequest = false;
                            if (studentApps != null) {
                                hasActiveRequest = studentApps.stream()
                                        .anyMatch(a -> a.getStatus() != null && a.getStatus().equalsIgnoreCase("Request"));
                            }

                            if (hasActiveRequest) continue; // Completely skip rendering this student
                            boolean isLinked = (studentApps != null && !studentApps.isEmpty());
                %>
                <div class="student-item"
                     data-name="<%= studentRow.getFullName().toLowerCase() %>"
                     data-email="<%= studentRow.getUserEmail().toLowerCase() %>"
                     data-grade="<%= hideGrade ? -1 : grade %>"
                     data-year="<%= year %>"
                     data-has-applied="<%= isLinked %>">

                    <div class="student-row-body">
                        <div class="d-flex flex-column align-items-center">
                            <a href="StudentProfile?id=<%= studentRow.getId() %>">
                                <img src="https://ui-avatars.com/api/?name=<%= studentRow.getFullName().replace(" ","+") %>&background=0E2B58&color=fff&size=128&bold=true"
                                     class="student-avatar-small">
                            </a>
                        </div>

                        <div class="ms-4 flex-grow-1">
                            <div class="d-flex align-items-center mb-1">
                                <a href="StudentProfile?id=<%= studentRow.getId() %>"
                                   class="student-name h6 mb-0 text-decoration-none">
                                    <%= studentRow.getFullName() %>
                                </a>

                                <% if (!hideGrade) { %>
                                <span class="ms-3 badge rounded-pill bg-light text-dark border"
                                      style="font-size: 0.75rem;">
                            <i class="fa-solid fa-graduation-cap text-success me-1"></i> <%= String.format("%.2f", grade) %>
                        </span>
                                <% } else { %>
                                <% } %>

                                <span class="ms-2 badge rounded-pill bg-light text-dark border"
                                      style="font-size: 0.75rem;">
                        <i class="fa-solid fa-calendar-day text-primary me-1"></i> Year <%= year %>
                    </span>
                            </div>

                            <div class="text-muted x-small mb-1 d-flex gap-2 align-items-center flex-wrap">
                   <span class="status-badge badge-email rounded-pill py-1">
                      <i class="fa-regular fa-envelope me-1"></i> <%= studentRow.getUserEmail() %>
                   </span>

                                <% if (isLinked) { %>
                                <span class="status-badge status-linked rounded-pill py-1">
                        <i class="fa-solid fa-link me-1"></i> Applied at <%= company.getName() %>
                    </span>
                                <% } %>
                            </div>

                            <button id="btn-action-<%= studentRow.getUserId() %>"
                                    onclick="showInterviewForm('<%= studentRow.getUserId() %>', '<%= studentRow.getUserEmail() %>', '<%= studentRow.getFullName() %>')"
                                    class="btn-request-small action-button-dynamic"
                                    data-user-id="<%= studentRow.getUserId() %>">
                                <i class="fa-solid fa-calendar-plus"></i>
                                <span class="button-text">Request Interview</span>
                            </button>
                        </div>
                    </div>
                </div>
                <% }
                } %>
            </div>
        </div>
    </div>
</div>

<div id="interviewFormModal" class="interview-form-modal">
    <div class="interview-form shadow-lg position-relative">
        <button class="modal-close" onclick="hideInterviewForm()"><i class="fas fa-times"></i></button>

        <div class="modal-header-simple text-center">
            <div class="d-flex align-items-center justify-content-center gap-3 mb-2">
                <div class="position-relative">
                    <img src="" id="modalStudentAvatar" class="modal-student-avatar"
                         onerror="this.src='https://ui-avatars.com/api/?name=' + document.getElementById('formTitle').textContent.replace(' ','+') + '&background=0E2B58&color=fff&size=128&bold=true';">
                </div>
                <div class="text-start">
                    <h4 id="formTitle" class="fw-bold mb-0 text-dark">Student Name</h4>
                    <p id="studentEmailSub" class="text-muted small mb-0">email@ulbsibiu.ro</p>
                </div>
            </div>
        </div>

        <ul class="nav nav-tabs nav-tabs-custom" id="interviewTabs" role="tablist">
            <li class="nav-item"><button class="nav-link" id="request-tab" data-bs-toggle="tab" data-bs-target="#requestPane" type="button">Request</button></li>
            <li class="nav-item"><button class="nav-link" id="pending-tab" data-bs-toggle="tab" data-bs-target="#pendingPane" type="button">Pending</button></li>
            <li class="nav-item"><button class="nav-link" id="chat-tab" data-bs-toggle="tab" data-bs-target="#chatPane" type="button">Chat Hub</button></li>
        </ul>

        <div class="modal-content-wrapper p-4">
            <div class="tab-content">

                <div class="tab-pane fade" id="requestPane" role="tabpanel">
                    <form action="RequestInterview" method="post">
                        <input type="hidden" id="selectedStudentUserId" name="studentUserId">
                        <div id="requestBlockedMessage" class="alert alert-warning d-none small py-2">This student has already applied to all your positions.</div>

                        <div id="requestFormFields">
                            <span class="form-label-dashboard">Choose Target Position</span>
                            <select id="positionId" name="positionId" class="form-select border-0 bg-light p-3 mb-3" style="border-radius: 12px;" required>
                                <option value="">-- Select --</option>
                                <% if (positions != null) { for (InternshipPositionDto pos : positions) { %>
                                <option value="<%= pos.getId() %>"><%= pos.getTitle() %></option>
                                <% } } %>
                            </select>

                            <span class="form-label-dashboard">Your Invitation Message</span>
                            <textarea name="message" class="form-control border-0 bg-light p-3 mb-3" rows="3" style="border-radius: 12px;" placeholder="Message to student..." required></textarea>

                            <button type="submit" class="btn btn-primary w-100 fw-bold p-3 border-0 shadow-sm" style="background: var(--brand-blue); border-radius: 12px;">
                                Send Interview Request
                            </button>
                        </div>
                    </form>
                </div>

                <div class="tab-pane fade" id="pendingPane" role="tabpanel">
                    <div class="action-card-simple">
                        <span class="form-label-dashboard">Unprocessed Applications</span>
                        <select id="pendingAppSelector" class="form-select border-0 bg-white p-3 mb-3 shadow-sm" style="border-radius: 10px;" onchange="togglePendingAction(this.value)">
                            <option value="">-- Choose application to answer --</option>
                        </select>

                        <div id="pendingActionArea" class="d-none animate__animated animate__fadeIn">
                            <form action="SendMessage" method="POST">
                                <input type="hidden" name="appId" id="pendingAppIdInput">
                                <input type="hidden" name="isInitial" value="true">
                                <span class="form-label-dashboard text-primary">Write Initial Message</span>
                                <textarea name="message" class="form-control border-0 bg-white p-3 mb-3 shadow-sm" rows="3" style="border-radius: 10px;" placeholder="Say hello and start the discussion..." required></textarea>
                                <button type="submit" class="btn btn-primary w-100 fw-bold p-2" style="border-radius: 8px;">
                                    <i class="fa-regular fa-comments me-2"></i>Start Discussion
                                </button>
                            </form>
                        </div>
                    </div>
                </div>

                <div class="tab-pane fade" id="chatPane" role="tabpanel">
                    <div class="action-card-simple">
                        <span class="form-label-dashboard">Ongoing Conversations</span>
                        <select id="chatAppSelector" class="form-select border-0 bg-white p-3 mb-3 shadow-sm" style="border-radius: 10px;" onchange="toggleChatAction(this.value)">
                            <option value="">-- Select active chat --</option>
                        </select>

                        <div id="chatActionArea" class="d-none text-center animate__animated animate__fadeIn">
                            <div class="alert alert-info border-0 py-2 small mb-3">You already have an active chat for this role.</div>
                            <a href="" id="chatAppGoBtn" class="btn btn-primary w-100 fw-bold p-2" style="border-radius: 8px;">
                                <i class="fa-solid fa-up-right-from-square me-2"></i>Go to Conversation
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div class="modal fade" id="requestSuccessModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-body text-center p-5">
                <div class="mb-4 text-success"><i class="fa-solid fa-circle-check fa-4x"></i></div>
                <h4 class="fw-bold">Request Sent!</h4>
                <p class="text-muted">Your formal interview invitation has been sent to <strong id="successStudentName"></strong>.</p>
                <button type="button" class="btn btn-primary rounded-pill px-5" data-bs-dismiss="modal">Excellent</button>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const appDataStore = {
        <% if (appsMap != null) {
            for (Map.Entry<Long, List<InternshipApplicationDto>> entry : appsMap.entrySet()) { %>
        "<%= entry.getKey() %>": [
            <% for (InternshipApplicationDto app : entry.getValue()) { %>
            {
                id: <%= app.getId() %>,
                status: "<%= app.getStatus() %>",
                posId: "<%= app.getInternshipPositionId() %>",
                pos: "<%= (app.getPositionTitle() != null) ? app.getPositionTitle().replace("\"", "\\\"") : "Position" %>"
            },
            <% } %>
        ],
        <% } } %>
    };

    const totalPos = <%= positions != null ? positions.size() : 0 %>;

    function hideInterviewForm() {
        const modal = document.getElementById('interviewFormModal');
        modal.style.opacity = '0';
        setTimeout(() => {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }, 200);
    }

    function showInterviewForm(userId, email, name) {
        const apps = appDataStore[userId] || [];
        const modal = document.getElementById('interviewFormModal');

        // 1. SHOW MODAL
        modal.style.display = 'flex';
        void modal.offsetWidth;
        modal.style.opacity = '1';
        document.body.style.overflow = 'hidden';

        // 2. IDENTITY & IMAGE
        document.getElementById('formTitle').textContent = name;
        document.getElementById('studentEmailSub').textContent = email;
        document.getElementById('selectedStudentUserId').value = userId;

        const avatarImg = document.getElementById('modalStudentAvatar');
        avatarImg.src = `ProfilePicture?id=${userId}&targetRole=Student`;

        // 3. RESET ACTION VISIBILITY
        document.getElementById('pendingActionArea').classList.add('d-none');
        document.getElementById('chatActionArea').classList.add('d-none');

        // 4. POPULATE DROPDOWNS
        const pSelector = document.getElementById('pendingAppSelector');
        const cSelector = document.getElementById('chatAppSelector');

        // Reset Options
        pSelector.options.length = 0;
        pSelector.add(new Option("-- Choose application to answer --", ""));

        cSelector.options.length = 0;
        cSelector.add(new Option("-- Select active chat --", ""));

        // Filter by Status
        const pendingApps = apps.filter(a => a.status === 'Pending');
        const activeApps = apps.filter(a => a.status === 'Discussion' || a.status === 'Interview');

        // Add to Pending Dropdown
        pendingApps.forEach(a => {
            const title = a.pos ? a.pos : "Untitled Position";
            pSelector.add(new Option(title, a.id));
        });

        // FIX: Add to Chat Dropdown (Corrected from pSelector to cSelector)
        activeApps.forEach(a => {
            const title = a.pos ? a.pos : "Untitled Position";
            const status = a.status ? a.status : "Active";
            // Ensure 'a.id' is passed as the second parameter here
            cSelector.add(new Option(title + " (" + status + ")", a.id));
        });

        // 5. REQUEST POSITION FILTER
        const appliedIds = apps.map(a => a.posId.toString());
        const reqSelect = document.getElementById('positionId');
        let availCount = 0;

        Array.from(reqSelect.options).forEach(opt => {
            if (!opt.value) return;
            const alreadyLinked = appliedIds.includes(opt.value);
            opt.style.display = alreadyLinked ? 'none' : 'block';
            opt.disabled = alreadyLinked;
            if (!alreadyLinked) availCount++;
        });
        reqSelect.value = "";

        // 6. TAB VISIBILITY & PRIORITY
        const reqLi = document.getElementById('request-tab').parentElement;
        const penLi = document.getElementById('pending-tab').parentElement;
        const chatLi = document.getElementById('chat-tab').parentElement;

        let target = 'request-tab';
        if (activeApps.length > 0) {
            target = 'chat-tab';
            chatLi.classList.remove('d-none');
            reqLi.classList.add('d-none');
            penLi.classList.add('d-none');
        } else if (pendingApps.length > 0) {
            target = 'pending-tab';
            chatLi.classList.add('d-none');
            reqLi.classList.add('d-none');
            penLi.classList.remove('d-none');
        } else {
            target = 'request-tab';
            chatLi.classList.add('d-none');
            reqLi.classList.remove('d-none');
            penLi.classList.add('d-none');
        }

        document.getElementById('requestFormFields').classList.toggle('d-none', availCount === 0);
        document.getElementById('requestBlockedMessage').classList.toggle('d-none', availCount > 0);

        bootstrap.Tab.getOrCreateInstance(document.getElementById(target)).show();
    }

    // Toggle Action Areas based on dropdown selection
    function togglePendingAction(appId) {
        const area = document.getElementById('pendingActionArea');
        if(!appId) { area.classList.add('d-none'); return; }
        document.getElementById('pendingAppIdInput').value = appId;
        area.classList.remove('d-none');
    }

    function toggleChatAction(appId) {
        const area = document.getElementById('chatActionArea');
        if(!appId) {
            area.classList.add('d-none');
            return;
        }
        // This ensures the button gets the correct appId immediately
        document.getElementById('chatAppGoBtn').href = "InternshipApplications?id=" + appId;
        area.classList.remove('d-none');
    }

    document.addEventListener('DOMContentLoaded', () => {
        const searchInput = document.getElementById('studentSearch');
        const grid = document.getElementById('studentGrid');
        const filterLinks = document.querySelectorAll('.student-filter');
        const filterLabel = document.getElementById('filterLabel');
        const filterButton = document.getElementById('filterButton');
        const dropdownParent = filterButton.parentElement;
        let currentFilter = 'all';

        updateButtonLabels();

        // Success Check
        if (new URLSearchParams(window.location.search).has('success')) {
            new bootstrap.Modal(document.getElementById('requestSuccessModal')).show();
            window.history.replaceState({}, document.title, window.location.pathname);
        }

        // Dropdown Visibility Toggle
        dropdownParent.addEventListener('show.bs.dropdown', () => filterButton.classList.add('dropdown-show-active'));
        dropdownParent.addEventListener('hide.bs.dropdown', () => filterButton.classList.remove('dropdown-show-active'));

        function updateGrid() {
            const val = searchInput.value.toLowerCase();
            let items = Array.from(document.querySelectorAll('.student-item'));

            if (currentFilter === 'grade') items.sort((a,b) => b.dataset.grade - a.dataset.grade);
            if (currentFilter === 'year') items.sort((a,b) => b.dataset.year - a.dataset.year);

            items.forEach(it => {
                grid.appendChild(it);
                const name = it.dataset.name || "";
                const email = it.dataset.email || "";
                const matchSearch = name.includes(val) || email.includes(val);
                const hasApplied = it.dataset.hasApplied === 'true';
                let matchStatus = true;

                if (currentFilter === 'new') matchStatus = !hasApplied;
                else if (currentFilter === 'previous') matchStatus = hasApplied;

                it.style.display = (matchSearch && matchStatus) ? 'block' : 'none';
            });
            updateButtonLabels();
        }

        filterLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                currentFilter = link.dataset.filter;
                filterLinks.forEach(l => l.classList.remove('active-filter'));
                link.classList.add('active-filter');
                filterLabel.classList.add('label-fade-out');
                setTimeout(() => {
                    filterLabel.textContent = link.textContent;
                    updateGrid();
                    filterLabel.classList.remove('label-fade-out');
                }, 150);
            });
        });

        searchInput.addEventListener('input', updateGrid);
        updateGrid();
    });

    function updateButtonLabels() {
        document.querySelectorAll('.action-button-dynamic').forEach(btn => {
            const userId = btn.getAttribute('data-user-id');
            const textSpan = btn.querySelector('.button-text');
            const icon = btn.querySelector('i');
            const apps = appDataStore[userId] || [];
            const pending = apps.filter(a => a.status === 'Pending' || a.status === 'applied');
            const active = apps.filter(a => a.status === 'Discussion' || a.status === 'Interview' || a.status === 'Accepted');

            if (active.length > 0) {
                textSpan.textContent = "Go to Chat";
                icon.className = "fa-solid fa-comments";
            } else if (pending.length > 0) {
                textSpan.textContent = "View Pending";
                icon.className = "fa-solid fa-clock-rotate-left";
            } else {
                textSpan.textContent = "Request Interview";
                icon.className = "fa-solid fa-calendar-plus";
            }
        });
    }
</script>
</body>
</html>