<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Discovery Hub</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        body {
            background-color: #f4f7f9;
        }

        /* --- Premium ULBS Banner --- */
        .header-stat {
            background: linear-gradient(135deg, var(--brand-blue) 0%, #1a4a8d 100%);
            color: white;
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            position: relative;
            overflow: hidden;
            box-shadow: 0 8px 30px rgba(14, 43, 88, 0.15);
            z-index: 1;
        }

        .header-stat::after {
            content: "\f234";
            font-family: "Font Awesome 6 Free";
            font-weight: 900;
            position: absolute;
            right: -20px;
            bottom: -30px;
            font-size: 10rem;
            opacity: 0.08;
            pointer-events: none;
        }

        /* --- Search and Filter Styling --- */
        .input-search-container {
            background: white;
            border-radius: 50px;
            padding: 2px;
            flex-grow: 1;
            max-width: 400px;
            transition: all 0.3s ease;
            border: 1px solid transparent;
        }

        .input-search-container:hover, .input-search-container:focus-within {
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            border-color: var(--brand-blue);
            transform: translateY(-1px);
        }

        .btn-filter-hub {
            height: 48px;
            background: white;
            border: 1px solid #dee2e6;
            transition: all 0.3s ease;
        }

        .btn-filter-hub:hover {
            background: #f8f9fa;
            border-color: var(--brand-blue);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        }

        /* --- Student Card Design --- */
        .student-item {
            transition: all 0.3s ease;
        }

        .student-card {
            background: white;
            border: none;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            height: 100%;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            position: relative;
        }

        .student-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.1);
        }

        /* Status Indicator Strip */
        .status-strip {
            height: 5px;
            width: 100%;
        }

        .bg-available {
            background-color: #28a745;
        }

        .bg-accepted {
            background-color: var(--brand-blue);
        }

        .bg-completed {
            background-color: #6c757d;
        }

        .student-card-body {
            padding: 1.5rem 1.25rem;
            text-align: center;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .student-avatar {
            width: 90px;
            height: 90px;
            border-radius: 50%;
            object-fit: cover;
            border: 4px solid white;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.08);
            transition: 0.3s;
            margin-bottom: 1rem;
        }

        .student-card:hover .student-avatar {
            transform: scale(1.05);
            border-color: #e3f2fd;
        }

        .student-name {
            font-weight: 800;
            color: var(--brand-blue-dark);
            text-decoration: none;
            font-size: 1.15rem;
            margin-bottom: 0.2rem;
            display: block;
            transition: color 0.2s;
        }

        .student-name:hover {
            text-decoration: underline;
            color: var(--brand-blue);
        }

        .student-meta {
            font-size: 0.85rem;
            color: #7f8c8d;
            margin-bottom: 1rem;
        }

        /* --- Badges --- */
        .badge-soft {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 50px;
            text-transform: uppercase;
        }

        .badge-soft-success {
            background: #e8f5e9;
            color: #2e7d32;
        }

        .badge-soft-primary {
            background: #e3f2fd;
            color: #1565c0;
        }

        .badge-soft-secondary {
            background: #f5f5f5;
            color: #616161;
        }

        /* --- Buttons --- */
        .btn-view-profile {
            font-size: 0.75rem;
            font-weight: 800;
            text-transform: uppercase;
            color: var(--brand-blue);
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            padding: 6px 16px;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-view-profile:hover {
            background: var(--brand-blue);
            color: white;
            border-color: var(--brand-blue);
        }

        .btn-request-premium {
            background: linear-gradient(135deg, var(--brand-blue) 0%, var(--brand-blue-dark) 100%);
            color: white;
            border: none;
            padding: 0.75rem 1rem;
            border-radius: 12px;
            font-weight: 700;
            font-size: 0.9rem;
            width: 100%;
            margin-top: auto;
            transition: all 0.3s ease;
            box-shadow: 0 4px 12px rgba(14, 43, 88, 0.2);
            display: inline-flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }

        .btn-request-premium:hover:not(:disabled) {
            transform: scale(1.02);
            filter: brightness(1.1);
            box-shadow: 0 6px 15px rgba(14, 43, 88, 0.3);
        }

        .btn-request-premium:disabled {
            background: #e9ecef;
            color: #adb5bd;
            box-shadow: none;
            cursor: not-allowed;
        }

        /* --- Modal --- */
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
            border-radius: 20px;
            padding: 2.5rem;
            width: 95%;
            max-width: 550px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.3);
            position: relative;
            animation: slideUp 0.4s cubic-bezier(0.165, 0.84, 0.44, 1);
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
            display: flex;
            align-items: center;
            justify-content: center;
            transition: 0.2s;
        }

        .modal-close:hover {
            background: #dc3545;
            color: white;
            transform: rotate(90deg);
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <jsp:include page="../blocks/companySidebar.jsp"/>

        <div class="col-md-9 col-lg-10 main-content py-4">

            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
                    <i class="fa-solid fa-circle-check me-2"></i><strong>Success!</strong> ${successMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-dismissible fade show border-0 shadow-sm mb-4" role="alert">
                    <i class="fa-solid fa-triangle-exclamation me-2"></i><strong>Error!</strong> ${errorMessage}
                    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                </div>
            </c:if>

            <div class="header-stat">
                <div class="row align-items-center">
                    <div class="col-md-4">
                        <h2 class="fw-bold mb-1"><i class="fa-solid fa-calendar-plus me-2"></i>Request Interview</h2>
                        <p class="mb-0 opacity-75">Connect with the best candidates for your team.</p>
                    </div>

                    <div class="col-md-8">
                        <div class="d-flex gap-2 justify-content-end align-items-center">
                            <div class="input-search-container shadow-sm">
                                <div class="input-group">
                                    <span class="input-group-text bg-transparent border-0 ps-3"><i
                                            class="fa-solid fa-magnifying-glass text-muted"></i></span>
                                    <input type="text" id="studentSearch" class="form-control border-0 shadow-none"
                                           placeholder="Search by name or email...">
                                </div>
                            </div>

                            <div class="dropdown">
                                <button class="btn btn-light rounded-pill shadow-sm dropdown-toggle fw-bold px-4 btn-filter-hub"
                                        type="button" data-bs-toggle="dropdown">
                                    <i class="fa-solid fa-filter me-2 text-primary"></i> <span id="filterLabel">All Talent</span>
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end shadow border-0 p-2"
                                    style="border-radius: 12px;">
                                    <li><a class="dropdown-item student-filter rounded-2" href="#" data-filter="all"><i
                                            class="fa-solid fa-users me-2"></i>Show All</a></li>
                                    <li><a class="dropdown-item student-filter rounded-2" href="#"
                                           data-filter="Available"><i class="fa-solid fa-circle-check me-2"></i>Available
                                        Only</a></li>
                                    <li>
                                        <hr class="dropdown-divider">
                                    </li>
                                    <li><a class="dropdown-item student-filter rounded-2" href="#" data-filter="new"><i
                                            class="fa-solid fa-user-plus me-2"></i>New Connections</a></li>
                                    <li><a class="dropdown-item student-filter rounded-2" href="#"
                                           data-filter="previous"><i class="fa-solid fa-link me-2"></i>Already
                                        Linked</a></li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4" id="studentGrid">
                <c:forEach var="student" items="${studentUsers}">
                    <c:set var="isLinked" value="false"/>
                    <c:forEach var="linkedId" items="${appliedStudentIds}">
                        <c:if test="${linkedId eq student.userId}">
                            <c:set var="isLinked" value="true"/>
                        </c:if>
                    </c:forEach>

                    <div class="col-sm-6 col-md-4 col-xl-3 student-item"
                         data-name="${student.studentName.toLowerCase()}"
                         data-email="${student.email.toLowerCase()}"
                         data-status="${student.studentStatus}"
                         data-has-applied="${isLinked}">

                        <div class="student-card">
                            <div class="status-strip ${student.studentStatus == 'Available' ? 'bg-available' : (student.studentStatus == 'Accepted' ? 'bg-accepted' : 'bg-completed')}"></div>
                            <div class="student-card-body">
                                <a href="StudentProfile?id=${student.studentId}">
                                    <img src="https://ui-avatars.com/api/?name=${student.studentName}&background=0E2B58&color=fff&size=100&bold=true"
                                         class="student-avatar" alt="Profile">
                                </a>

                                <a href="StudentProfile?id=${student.studentId}"
                                   class="student-name text-truncate w-100">
                                        ${not empty student.studentName ? student.studentName : 'Anonymous'}
                                </a>

                                <span class="badge-soft ${student.studentStatus == 'Available' ? 'badge-soft-success' : (student.studentStatus == 'Accepted' ? 'badge-soft-primary' : 'badge-soft-secondary')} mb-2">
                                        ${student.studentStatus}
                                </span>

                                <div class="student-meta">
                                    <i class="fas fa-envelope me-1"></i> ${student.email}
                                </div>

                                <a href="StudentProfile?id=${student.studentId}" class="btn-view-profile">
                                    <i class="fa-solid fa-id-card"></i> View Profile
                                </a>

                                <div class="w-100 mt-auto">
                                    <c:if test="${isLinked}">
                                        <div class="alert alert-info py-1 px-2 border-0 mb-2 shadow-sm"
                                             style="font-size: 0.65rem; border-radius: 8px;">
                                            <i class="fa-solid fa-link me-1"></i> Connected to Company
                                        </div>
                                    </c:if>

                                    <c:choose>
                                        <c:when test="${student.studentStatus == 'Available'}">
                                            <button onclick="showInterviewForm('${student.userId}', '${student.email}', '${student.studentName}')"
                                                    class="btn-request-premium">
                                                <i class="fa-solid fa-paper-plane"></i> Request Interview
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn-request-premium" disabled>
                                                <i class="fa-solid fa-lock"></i> ${student.studentStatus}
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </div>
</div>

<div id="interviewFormModal" class="interview-form-modal">
    <div class="interview-form">
        <button class="modal-close" onclick="hideInterviewForm()"><i class="fas fa-times"></i></button>
        <h3 id="formTitle" class="fw-bold mb-1">Request Interview</h3>
        <p class="text-muted small mb-4">Send a formal interview request to the candidate.</p>

        <form action="RequestInterview" method="post" id="interviewRequestForm">
            <input type="hidden" id="selectedStudentUserId" name="studentUserId">
            <input type="hidden" id="selectedStudentEmail" name="studentEmail">

            <div class="mb-4">
                <label class="form-label fw-bold small text-muted text-uppercase"><i
                        class="fa-solid fa-briefcase me-1"></i> Select Position</label>
                <select id="positionId" name="positionId" class="form-select shadow-sm p-3" style="border-radius: 12px;"
                        required>
                    <option value="">-- Choose an active position --</option>
                    <c:forEach var="position" items="${companyPositions}">
                        <option value="${position.id}">${position.title}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="mb-4">
                <label class="form-label fw-bold small text-muted text-uppercase"><i
                        class="fa-solid fa-comment-dots me-1"></i> Personal Message</label>
                <textarea name="message" class="form-control bg-light border-0 p-3" rows="4"
                          style="border-radius: 12px;"
                          placeholder="Explain why you are interested in this student..." required></textarea>
            </div>

            <div class="d-flex gap-3">
                <button type="submit" class="btn btn-primary flex-grow-1 fw-bold shadow-sm p-3"
                        style="background: var(--brand-blue); border: none; border-radius: 12px;">
                    <i class="fa-solid fa-paper-plane me-2"></i> Send Request
                </button>
                <button type="button" onclick="hideInterviewForm()" class="btn btn-light border px-4"
                        style="border-radius: 12px;">Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showInterviewForm(id, email, name) {
        document.getElementById('selectedStudentUserId').value = id;
        document.getElementById('selectedStudentEmail').value = email;
        document.getElementById('formTitle').textContent = 'Request Interview for ' + name;
        document.getElementById('interviewFormModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }

    function hideInterviewForm() {
        document.getElementById('interviewFormModal').style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    document.addEventListener('DOMContentLoaded', function () {
        const searchInput = document.getElementById('studentSearch');
        const gridItems = document.querySelectorAll('.student-item');
        const filterLinks = document.querySelectorAll('.student-filter');
        const filterLabel = document.getElementById('filterLabel');
        let currentFilter = 'all';

        function applyGlobalFilters() {
            const term = searchInput.value.toLowerCase();

            gridItems.forEach(item => {
                const name = item.getAttribute('data-name');
                const email = item.getAttribute('data-email');
                const status = item.getAttribute('data-status');
                const applied = item.getAttribute('data-has-applied') === 'true';

                const matchesSearch = name.includes(term) || email.includes(term);
                let matchesFilter = true;

                if (currentFilter === 'Available') matchesFilter = (status === 'Available');
                else if (currentFilter === 'new') matchesFilter = !applied;
                else if (currentFilter === 'previous') matchesFilter = applied;

                item.style.display = (matchesSearch && matchesFilter) ? 'block' : 'none';
            });
        }

        searchInput.addEventListener('input', applyGlobalFilters);

        filterLinks.forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                currentFilter = link.dataset.filter;
                filterLabel.innerText = link.innerText;
                applyGlobalFilters();
            });
        });

        window.onclick = function (e) {
            if (e.target == document.getElementById('interviewFormModal')) hideInterviewForm();
        }
    });
</script>
</body>
</html>