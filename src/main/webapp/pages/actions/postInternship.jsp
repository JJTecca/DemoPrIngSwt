<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.time.LocalDate" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || (!role.equals("Company") && !role.equals("Faculty"))) {
        response.sendRedirect("UserLogin");
        return;
    }
    boolean isFaculty = "Faculty".equals(role);
    String pageTitle = isFaculty ? "Post Tutoring Position" : "Post New Internship";
    String minDate = LocalDate.now().plusDays(7).toString();

    // Determine the dashboard return path based on role
    String dashboardPath = isFaculty ? "FacultyDashboard" : "CompanyDashboard";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        .main-content {
            background-color: #f8f9fa;
            min-height: 100vh;
        }

        .form-box {
            max-width: 700px;
            width: 100%;
            margin: 2rem auto;
            border-radius: 1rem;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            background-color: white;
        }

        .form-box-header {
            background: var(--brand-gradient);
            padding: 3rem 2rem 2.5rem 2rem;
            color: white;
            text-align: center;
        }

        .form-box-body {
            padding: 2.5rem 3.5rem;
        }

        .header-badge {
            width: 60px;
            height: 60px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem auto;
            font-size: 1.8rem;
            border: 2px solid rgba(255, 255, 255, 0.3);
        }

        .form-control-lg {
            border: 2px solid #e9ecef;
            border-radius: 0.5rem;
            background-color: #f8f9fa;
            transition: all 0.3s;
            font-size: 0.95rem;
        }

        .form-control-lg:focus {
            border-color: var(--brand-blue);
            box-shadow: 0 0 0 4px rgba(14, 43, 88, 0.15);
            background-color: #fff;
        }

        .invalid-feedback-custom {
            display: none;
            color: #dc3545;
            font-size: 0.72rem;
            font-weight: 700;
            margin-top: 0.4rem;
        }

        .is-invalid {
            border-color: #dc3545 !important;
            background-color: #fff8f8 !important;
        }

        .is-invalid + .invalid-feedback-custom {
            display: block;
        }

        .form-label {
            color: #6c757d;
            font-weight: 700;
            font-size: 0.75rem;
            letter-spacing: 0.5px;
            margin-bottom: 0.4rem;
        }

        .btn-main-action {
            background: var(--brand-gradient);
            border: none;
            color: white;
            font-weight: 700;
            font-size: 1.1rem;
            padding: 0.8rem;
            border-radius: 0.5rem;
            transition: all 0.3s;
            width: 100%;
        }

        .btn-main-action:hover {
            filter: brightness(1.1);
            transform: translateY(-2px);
            color: white;
        }

        /* Return Link Transition */
        .btn-return {
            color: #6c757d;
            font-size: 0.85rem;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.25s ease-in-out;
            display: inline-block;
        }

        .btn-return:hover {
            color: var(--brand-blue);
            transform: translateX(-5px);
        }

        .modern-alert {
            border: none;
            border-left: 4px solid #fff;
            background: rgba(255, 255, 255, 0.15);
            color: white;
            border-radius: 0.5rem;
            padding: 1.2rem;
            margin-top: 1.5rem;
            text-align: left;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid">
    <div class="row w-100 m-0">
        <% if (isFaculty) { %>
        <jsp:include page="../blocks/facultySidebar.jsp"/>
        <% } else { %>
        <jsp:include page="../blocks/companySidebar.jsp"/>
        <% } %>

        <div class="col-md-9 col-lg-10 main-content py-4">
            <div class="form-box">
                <div class="form-box-header">
                    <div class="header-badge"><i class="fa-solid fa-briefcase"></i></div>
                    <h1 class="h2 fw-bold text-white mb-1"><%= pageTitle %>
                    </h1>

                    <% if (!isFaculty) { %>
                    <div class="modern-alert">
                        <i class="fa-solid fa-user-shield me-2"></i>
                        <strong>Approval Required:</strong> After submission, an administrator will review your position
                        before it becomes visible to students.
                    </div>
                    <% } else { %>
                    <p class="mb-0 opacity-75">Connect students with department opportunities</p>
                    <% } %>
                </div>

                <div class="form-box-body">
                    <form id="postForm" action="${pageContext.request.contextPath}/PostPosition" method="POST"
                          novalidate>

                        <div class="mb-4">
                            <label class="form-label">POSITION TITLE *</label>
                            <input type="text" name="title" id="titleInput" class="form-control form-control-lg"
                                   placeholder="<%= isFaculty ? "e.g. Java Laboratory Assistant" : "e.g. Software Engineering Intern" %>"
                                   required minlength="10">
                            <div class="invalid-feedback-custom">Minimum 10 characters required</div>
                        </div>

                        <div class="row mb-4">
                            <div class="col-md-6">
                                <label class="form-label">AVAILABLE SPOTS *</label>
                                <input type="number" name="maxSpots" id="spotsInput"
                                       class="form-control form-control-lg"
                                       min="3" value="3" required>
                                <div class="invalid-feedback-custom">At least 3 spots are required</div>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label">APPLICATION DEADLINE *</label>
                                <input type="date" name="deadline" id="deadlineInput"
                                       class="form-control form-control-lg"
                                       min="<%= minDate %>" required>
                                <div class="invalid-feedback-custom">Deadline must be at least 7 days from today</div>
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">DETAILED DESCRIPTION *</label>
                            <textarea name="description" id="descInput" class="form-control form-control-lg" rows="4"
                                      placeholder="Provide a thorough overview of the role..." required
                                      minlength="50"></textarea>
                            <div class="invalid-feedback-custom">Description must be at least 50 characters</div>
                        </div>

                        <div class="mb-4">
                            <label class="form-label">TECHNICAL REQUIREMENTS *</label>
                            <textarea name="requirements" id="reqInput" class="form-control form-control-lg" rows="2"
                                      placeholder="List specific skills or knowledge required..." required
                                      minlength="20"></textarea>
                            <div class="invalid-feedback-custom">Requirements must be at least 20 characters</div>
                        </div>

                        <button type="submit" class="btn btn-main-action mb-4 shadow-sm">
                            <%= isFaculty ? "Publish Position" : "Send for Approval" %>
                        </button>

                        <div class="text-center">
                            <a href="<%= dashboardPath %>" class="btn-return">
                                <i class="fa-solid fa-chevron-left me-1"></i> Return to Dashboard
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="successModal" tabindex="-1" data-bs-backdrop="static" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-body text-center p-5">
                <div class="mb-4">
                    <i class="fa-solid fa-circle-check text-success fa-4x"></i>
                </div>
                <h4 class="fw-bold mb-2">Position Submitted!</h4>
                <p class="text-muted">
                    <%= isFaculty ? "Your tutoring position is now live." : "Your post has been sent for Admin approval." %>
                </p>
                <button type="button" class="btn btn-main-action rounded-pill px-5 mt-3" id="btnGoToDashboard">
                    Got It
                </button>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const postForm = document.getElementById('postForm');
        const inputs = {
            title: document.getElementById('titleInput'),
            spots: document.getElementById('spotsInput'),
            deadline: document.getElementById('deadlineInput'),
            desc: document.getElementById('descInput'),
            req: document.getElementById('reqInput')
        };

        function validateField(input, condition) {
            if (condition) {
                input.classList.remove('is-invalid');
                return true;
            } else {
                input.classList.add('is-invalid');
                return false;
            }
        }

        function validate() {
            let isValid = true;
            if (!validateField(inputs.title, inputs.title.value.length >= 10)) isValid = false;
            if (!validateField(inputs.desc, inputs.desc.value.length >= 50)) isValid = false;
            if (!validateField(inputs.req, inputs.req.value.length >= 20)) isValid = false;
            if (!validateField(inputs.spots, inputs.spots.value >= 1)) isValid = false;

            const minAllowed = new Date();
            minAllowed.setDate(minAllowed.getDate() + 7);
            const selected = new Date(inputs.deadline.value);
            if (!validateField(inputs.deadline, inputs.deadline.value && selected >= minAllowed.setHours(0, 0, 0, 0))) isValid = false;

            return isValid;
        }

        // Live Validation listeners
        Object.values(inputs).forEach(input => {
            input.addEventListener('input', () => {
                if (input.classList.contains('is-invalid')) validate();
            });
        });

        postForm.addEventListener('submit', function (e) {
            if (!validate()) {
                e.preventDefault();
            }
        });
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('success') === 'true') {
            const successModal = new bootstrap.Modal(document.getElementById('successModal'));
            successModal.show();
        }

        document.getElementById('btnGoToDashboard').addEventListener('click', function () {
            window.location.href = '<%= dashboardPath %>';
        });
    });
</script>

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>