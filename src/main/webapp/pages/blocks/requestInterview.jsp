<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Interview Requests</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f9fa;
        }

        .page-header {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border-left: 4px solid var(--brand-blue);
        }

        .page-title {
            color: var(--brand-blue-dark);
            font-weight: 700;
            margin-bottom: 0.5rem;
        }

        .page-subtitle {
            color: #6c757d;
            margin-bottom: 0;
        }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: white;
            color: var(--brand-blue);
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            transition: all 0.3s ease;
            border: 2px solid var(--brand-blue);
            margin-top: 1rem;
        }

        .back-btn:hover {
            background: var(--brand-blue);
            color: white;
            transform: translateX(-5px);
        }

        .student-card {
            background: white;
            border: none;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
            height: 100%;
            overflow: hidden;
        }

        .student-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
        }

        .student-card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: var(--brand-blue);
            opacity: 0;
            transition: opacity 0.3s;
        }

        .student-card:hover::before {
            opacity: 1;
        }

        .student-card-body {
            padding: 1.5rem;
        }

        .student-avatar {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid #e9ecef;
            transition: all 0.3s ease;
        }

        .student-card:hover .student-avatar {
            border-color: var(--brand-blue);
            transform: scale(1.05);
        }

        .student-name {
            font-weight: 700;
            color: var(--brand-blue-dark);
            margin-bottom: 0.25rem;
            font-size: 1.1rem;
        }

        .student-email {
            color: #6c757d;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }

        .student-id {
            color: #adb5bd;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .badge-status {
            font-size: 0.75rem;
            padding: 0.35em 0.7em;
            border-radius: 50px;
            font-weight: 600;
        }

        .badge-available {
            background-color: #d1e7dd;
            color: #0f5132;
        }

        .badge-unavailable {
            background-color: #f8d7da;
            color: #842029;
        }

        .btn-request {
            background-color: var(--brand-blue);
            color: white;
            border: none;
            padding: 0.65rem 1.25rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.9rem;
        }

        .btn-request:hover {
            background-color: var(--brand-blue-dark);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(14, 43, 88, 0.2);
        }

        .btn-request:disabled {
            background-color: #e9ecef;
            color: #adb5bd;
            cursor: not-allowed;
            opacity: 0.6;
        }

        .btn-request:disabled:hover {
            transform: none;
            box-shadow: none;
        }

        .alert-custom {
            border-radius: 8px;
            border: none;
            padding: 1rem 1.25rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border-left: 4px solid;
        }

        .alert-success {
            background-color: #d1e7dd;
            color: #0f5132;
            border-left-color: #198754;
        }

        .alert-danger {
            background-color: #f8d7da;
            color: #842029;
            border-left-color: #dc3545;
        }

        .empty-state {
            text-align: center;
            padding: 4rem 2rem;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
        }

        .empty-icon {
            font-size: 4rem;
            color: #dee2e6;
            margin-bottom: 1.5rem;
        }

        .empty-title {
            color: #6c757d;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .empty-subtitle {
            color: #adb5bd;
            max-width: 500px;
            margin: 0 auto;
        }

        /* Modal Styling */
        .interview-form-modal {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 1050;
            backdrop-filter: blur(3px);
        }

        .interview-form {
            background: white;
            border-radius: 8px;
            padding: 2rem;
            width: 90%;
            max-width: 600px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            animation: slideUp 0.3s ease;
            position: relative;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .form-title {
            color: var(--brand-blue-dark);
            font-weight: 700;
            margin-bottom: 1.5rem;
            font-size: 1.5rem;
            padding-bottom: 0.75rem;
            border-bottom: 3px solid var(--brand-blue);
        }

        .modal-close {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: #f8f9fa;
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6c757d;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .modal-close:hover {
            background: var(--brand-blue);
            color: white;
            transform: rotate(90deg);
        }

        .form-select {
            border: 2px solid #e9ecef;
            border-radius: 6px;
            padding: 0.75rem;
            transition: all 0.3s ease;
        }

        .form-select:focus {
            border-color: var(--brand-blue);
            box-shadow: 0 0 0 3px rgba(14, 43, 88, 0.1);
        }

        .position-preview {
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 6px;
            padding: 1rem;
            margin-top: 1rem;
            border-left: 4px solid var(--brand-blue);
        }

        .position-title {
            font-weight: 600;
            color: var(--brand-blue-dark);
            margin-bottom: 0.25rem;
        }

        .position-company {
            color: #6c757d;
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
        }

        .btn-cancel {
            background: #f8f9fa;
            color: #6c757d;
            border: 2px solid #e9ecef;
            padding: 0.65rem 1.25rem;
            border-radius: 50px;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .btn-cancel:hover {
            background: #e9ecef;
            color: #495057;
            border-color: #dee2e6;
        }

        @media (max-width: 768px) {
            .page-header {
                padding: 1.5rem;
            }

            .student-card-body {
                padding: 1.25rem;
            }

            .interview-form {
                padding: 1.5rem;
                width: 95%;
            }
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }

        .is-invalid {
            border-color: #dc3545 !important;
        }

        .invalid-feedback {
            color: #dc3545;
            font-size: 0.875rem;
            margin-top: 0.5rem;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid flex-grow-1">
    <div class="row h-100">
        <jsp:include page="../blocks/companySidebar.jsp"/>

        <div class="col-md-9 col-lg-10 main-content">
            <!-- Page Header -->
            <div class="page-header">
                <h1 class="page-title">
                    <i class="fa-solid fa-calendar-check me-2"></i>Request Interview
                </h1>
                <p class="page-subtitle">Select a student to schedule an interview for your internship position</p>

                <a href="${pageContext.request.contextPath}/CompanyDashboard" class="back-btn">
                    <i class="fas fa-arrow-left"></i> Back to Dashboard
                </a>
            </div>

            <!-- Messages -->
            <c:if test="${not empty successMessage}">
                <div class="alert alert-success alert-custom">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-check-circle fa-2x me-3"></i>
                        <div>
                            <strong>Success!</strong>
                            <div>${successMessage}</div>
                        </div>
                    </div>
                </div>
            </c:if>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger alert-custom">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-exclamation-triangle fa-2x me-3"></i>
                        <div>
                            <strong>Error!</strong>
                            <div>${errorMessage}</div>
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- Student List -->
            <div class="row g-4">
                <c:choose>
                    <c:when test="${not empty studentUsers}">
                        <c:forEach var="student" items="${studentUsers}">
                            <div class="col-md-6 col-xl-4">
                                <div class="student-card">
                                    <div class="student-card-body">
                                        <div class="d-flex align-items-start mb-3">
                                            <img src="https://ui-avatars.com/api/?name=${student.studentName}&background=0E2B58&color=fff&size=70&bold=true"
                                                 alt="${student.studentName}"
                                                 class="student-avatar me-3">
                                            <div class="flex-grow-1">
                                                <h3 class="student-name mb-1">
                                                    <c:choose>
                                                        <c:when test="${not empty student.studentName}">
                                                            ${student.studentName}
                                                        </c:when>
                                                        <c:otherwise>
                                                            N/A
                                                        </c:otherwise>
                                                    </c:choose>
                                                </h3>
                                                <p class="student-email mb-2">
                                                    <i class="fas fa-envelope me-1"></i>${student.email}
                                                </p>
                                                <span class="student-id">
                                                    <i class="fas fa-id-card me-1"></i>ID: ${student.userId}
                                                </span>
                                            </div>
                                        </div>

                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <span class="badge-status
                                                ${student.studentStatus == 'Available' ? 'badge-available' : 'badge-unavailable'}">
                                                <c:choose>
                                                    <c:when test="${student.studentStatus == 'Available'}">
                                                        <i class="fas fa-check-circle me-1"></i>Available
                                                    </c:when>
                                                    <c:when test="${student.studentStatus == 'Accepted'}">
                                                        <i class="fas fa-user-check me-1"></i>Already Hired
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fas fa-clock me-1"></i>${student.studentStatus}
                                                    </c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>

                                        <div class="d-grid">
                                            <c:choose>
                                                <c:when test="${student.studentStatus == 'Available'}">
                                                    <button onclick="showInterviewForm('${student.userId}', '${student.email}', '${student.studentName}')"
                                                            class="btn-request">
                                                        <i class="fas fa-calendar-plus"></i> Request Interview
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="btn-request" disabled>
                                                        <i class="fas fa-ban"></i> Unavailable (${student.studentStatus})
                                                    </button>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="col-12">
                            <div class="empty-state">
                                <div class="empty-icon">
                                    <i class="fas fa-user-graduate"></i>
                                </div>
                                <h3 class="empty-title">No Students Found</h3>
                                <p class="empty-subtitle">
                                    There are currently no student users in the system.
                                    Students will appear here once they register and complete their profiles.
                                </p>
                            </div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<!-- Interview Form Modal -->
<div id="interviewFormModal" class="interview-form-modal">
    <div class="interview-form">
        <button class="modal-close" onclick="hideInterviewForm()">
            <i class="fas fa-times"></i>
        </button>

        <h3 id="formTitle" class="form-title">Request Interview</h3>

        <form action="RequestInterview" method="post" onsubmit="return validateForm()" id="interviewRequestForm">
            <input type="hidden" id="selectedStudentUserId" name="studentUserId">
            <input type="hidden" id="selectedStudentEmail" name="studentEmail">

            <div class="mb-4">
                <label for="positionId" class="form-label fw-bold mb-2">
                    <i class="fas fa-briefcase me-2"></i>Select Internship Position
                </label>
                <select id="positionId" name="positionId" class="form-select" required>
                    <option value="">-- Select a Position --</option>
                    <c:forEach var="position" items="${companyPositions}">
                        <option value="${position.id}">
                                ${position.title} (${position.companyName})
                        </option>
                    </c:forEach>
                </select>
                <div class="invalid-feedback" id="positionError" style="display: none;">
                    <i class="fas fa-exclamation-circle me-1"></i> Please select a position
                </div>

                <div id="positionPreview"></div>
            </div>

            <div class="d-flex gap-3">
                <button type="submit" class="btn-request flex-grow-1">
                    <i class="fas fa-paper-plane"></i> Send Interview Request
                </button>
                <button type="button" onclick="hideInterviewForm()" class="btn-cancel">
                    Cancel
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentPositions = [];

    // Initialize positions from JSP
    <c:if test="${not empty companyPositions}">
    currentPositions = [
        <c:forEach var="position" items="${companyPositions}" varStatus="loop">
        {
            id: ${position.id},
            title: "${position.title}",
            companyName: "${position.companyName}",
            description: "${position.description}",
            requirements: "${position.requirements}"
        }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];
    </c:if>

    function showInterviewForm(studentUserId, studentEmail, studentName) {
        document.getElementById('selectedStudentUserId').value = studentUserId;
        document.getElementById('selectedStudentEmail').value = studentEmail;

        // Update form title
        var formTitle = document.getElementById('formTitle');
        formTitle.textContent = 'Request Interview for ' + studentName;

        // Show the modal
        var modal = document.getElementById('interviewFormModal');
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';

        // Reset form
        document.getElementById('positionId').selectedIndex = 0;
        document.getElementById('positionPreview').innerHTML = '';
        document.getElementById('positionId').classList.remove('is-invalid');
        document.getElementById('positionError').style.display = 'none';

        // Position select change listener
        document.getElementById('positionId').addEventListener('change', function() {
            updatePositionPreview(this.value);
        });
    }

    function hideInterviewForm() {
        var modal = document.getElementById('interviewFormModal');
        modal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }

    function updatePositionPreview(positionId) {
        const previewDiv = document.getElementById('positionPreview');
        previewDiv.innerHTML = '';

        if (!positionId) return;

        const position = currentPositions.find(p => p.id == positionId);
        if (position) {
            const html = `
                <div class="position-preview">
                    <h6 class="position-title">${position.title}</h6>
                    <p class="position-company">
                        <i class="fas fa-building me-1"></i>${position.companyName}
                    </p>
                    <p class="mb-0 small text-secondary">${position.description.substring(0, 100)}...</p>
                </div>
            `;
            previewDiv.innerHTML = html;
        }
    }

    function validateForm() {
        var positionSelect = document.getElementById('positionId');
        var positionError = document.getElementById('positionError');

        if (positionSelect.value === "") {
            positionError.style.display = 'block';
            positionSelect.classList.add('is-invalid');

            // Add shake animation
            positionSelect.style.animation = 'shake 0.5s';
            setTimeout(() => {
                positionSelect.style.animation = '';
            }, 500);

            return false;
        } else {
            positionError.style.display = 'none';
            positionSelect.classList.remove('is-invalid');
            return true;
        }
    }

    // Close modal when clicking outside
    document.getElementById('interviewFormModal').addEventListener('click', function(e) {
        if (e.target === this) {
            hideInterviewForm();
        }
    });
</script>
</body>
</html>