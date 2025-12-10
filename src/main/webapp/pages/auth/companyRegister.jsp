<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register Company - Internship Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
        /* ALL YOUR ORIGINAL STYLES HERE - KEEP THEM EXACTLY AS BEFORE */
        body, html {
            height: 100%;
            margin: 0;
            font-family: 'Segoe UI', Roboto, "Helvetica Neue", Arial, sans-serif;
        }

        :root {
            --brand-blue: #0E2B58;
            --brand-blue-dark: #071a38;
            --ulbs-red: #A30B0B;
        }

        .register-container {
            display: flex;
            min-height: 100vh;
        }

        .register-form-area {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 2rem;

            background-image: url('images/background1.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        .register-form-area::before {
            content: "";
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(
                    to bottom,
                    rgba(14, 43, 88, 0.50),
                    rgba(14, 43, 88, 0.65)
            );
            z-index: 1;
        }

        .register-form-area > * {
            position: relative;
            z-index: 2;
        }

        .form-box {
            max-width: 550px;
            width: 100%;
            padding: 0;
            border-radius: 1rem;
            box-shadow: 0 20px 50px rgba(0,0,0,0.4);
            overflow: hidden;
            background-color: white;
        }

        .form-box-header {
            background-color: var(--brand-blue);
            padding: 2.5rem 2.5rem 1rem 2.5rem;
            color: white;
        }

        .form-box-body {
            background-color: white;
            padding: 2rem 2.5rem 2.5rem 2.5rem;
        }

        .form-box__title {
            color: white;
            font-weight: 800;
            letter-spacing: -0.5px;
            font-size: 2.5rem;
        }

        .form-box__description {
            color: rgba(255, 255, 255, 0.85);
            font-size: 1rem;
        }

        .form-control-lg {
            border: 2px solid #e9ecef;
            padding: 0.7rem 1rem;
            font-size: 1rem;
            background-color: #f8f9fa;
        }
        .form-control-lg:focus {
            background-color: #ffffff;
            border-color: var(--brand-blue);
            box-shadow: 0 0 0 4px rgba(14, 43, 88, 0.15);
            z-index: 3;
        }

        .input-group-text {
            background-color: #e9ecef;
            border: 2px solid #e9ecef;
            color: var(--brand-blue);
            cursor: help;
        }
        .input-group:hover .input-group-text {
            background-color: #dee2e6;
            border-color: #dee2e6;
        }

        .btn-main-register {
            background-color: var(--brand-blue);
            border: none;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
            padding: 0.8rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(14, 43, 88, 0.2);
        }
        .btn-main-register:hover {
            background-color: var(--brand-blue-dark);
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(14, 43, 88, 0.3);
            color: white;
        }

        .register-info-area {
            background: #fff;
            color: var(--brand-blue);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            text-align: center;
            padding: 3rem;
            border-left: 10px solid var(--brand-blue);
            position: relative;
            z-index: 5;
        }

        .ulbs-logo {
            max-width: 250px;
            height: auto;
            margin-bottom: 2rem;
        }

        .info-lead-text {
            color: #444;
            font-weight: 500;
            font-size: 1.2rem;
            line-height: 1.6;
        }

        .highlight-text {
            color: var(--brand-blue);
            font-weight: 800;
        }

        /* Success Modal Styles - Minimal addition */
        .success-icon {
            color: #28a745;
            font-size: 4rem;
            margin-bottom: 1rem;
        }

        .modal-success-header {
            background-color: var(--brand-blue);
            color: white;
            border-bottom: none;
        }

        .modal-success-header .btn-close {
            filter: invert(1) grayscale(100%) brightness(200%);
        }

        .modal-success-btn {
            background-color: var(--brand-blue);
            border-color: var(--brand-blue);
            color: white;
        }

        .modal-success-btn:hover {
            background-color: var(--brand-blue-dark);
            border-color: var(--brand-blue-dark);
        }
    </style>
</head>
<body>

<div class="container-fluid p-0 register-container">

    <div class="col-lg-9 col-md-8 col-12 register-form-area">
        <div class="form-box">

            <div class="form-box-header">
                <h1 class="mb-2 text-center form-box__title">Partner Registration</h1>
                <p class="text-center mb-0 form-box__description">
                    Join our platform to offer internships to CSEE students.
                </p>
            </div>

            <div class="form-box-body">
                <!-- Display error message if any -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i>
                            ${errorMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <form id="registrationForm" action="CompanyRegister" method="POST">

                    <div class="mb-3">
                        <label for="companyName" class="form-label visually-hidden">Company Name</label>
                        <input type="text" class="form-control form-control-lg rounded" id="companyName" name="companyName"
                               placeholder="Company Name" required>
                    </div>

                    <div class="mb-3">
                        <label for="companyEmail" class="form-label visually-hidden">Company Email</label>
                        <div class="input-group">
                            <input type="email" class="form-control form-control-lg" id="companyEmail" name="companyEmail"
                                   placeholder="Company Email" required>
                            <span class="input-group-text" data-bs-toggle="tooltip" data-bs-placement="right"
                                  title="This email address will be used for logging into the platform and receiving official notifications.">
                                <i class="fa-solid fa-circle-question"></i>
                            </span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="companyAddress" class="form-label visually-hidden">Company Address</label>
                        <input type="text" class="form-control form-control-lg rounded" id="companyAddress" name="companyAddress"
                               placeholder="Company Headquarters Address" required>
                    </div>

                    <div class="mb-3">
                        <label for="phoneNumber" class="form-label visually-hidden">Phone Number</label>
                        <div class="input-group">
                            <input type="tel" class="form-control form-control-lg" id="phoneNumber" name="phoneNumber"
                                   placeholder="Contact Phone Number" required>
                            <span class="input-group-text" data-bs-toggle="tooltip" data-bs-placement="right"
                                  title="This number is for administrative use and student contact after acceptance; it won't be publicly displayed.">
                                <i class="fa-solid fa-circle-question"></i>
                            </span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="password" class="form-label visually-hidden">Password</label>
                        <input type="password" class="form-control form-control-lg rounded" id="password" name="password"
                               placeholder="Password" required>
                    </div>

                    <div class="mb-4">
                        <label for="confirmPassword" class="form-label visually-hidden">Confirm Password</label>
                        <input type="password" class="form-control form-control-lg rounded" id="confirmPassword" name="confirmPassword"
                               placeholder="Confirm Password" required>
                    </div>

                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-main-register" id="submitBtn">
                            REGISTER COMPANY
                        </button>
                    </div>
                </form>

                <hr class="text-muted my-4">

                <div class="text-center">
                    <a href="${pageContext.request.contextPath}/UserLogin" class="text-decoration-none fw-bold" style="color: var(--brand-blue);">
                        <i class="fa-solid fa-arrow-left me-1"></i> Back to Log In
                    </a>
                </div>

            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-4 d-none d-md-flex register-info-area">
        <div>
            <img src="images/logo.png" alt="ULBS Logo" class="ulbs-logo">

            <h2 class="h5 text-uppercase fw-bold mb-2 ls-2">Partner With</h2>
            <h1 class="h2 fw-bolder mb-4">CSEE ULBS</h1>

            <p class="info-lead-text mb-5">
                <span class="highlight-text">Expand Your Talent Pool.</span><br>
                Register now to find highly skilled students for your internship positions.
            </p>

            <p class="info-small-text mt-auto small">
                <span class="highlight-text">CSEE ULBS</span><br>
                Computer Science and <br>Electrical Engineering<br>
                Lucian Blaga University of Sibiu
            </p>
        </div>
    </div>
</div>

<div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header modal-success-header">
                <h5 class="modal-title" id="successModalLabel">
                    <i class="fas fa-check-circle me-2"></i>Registration Successful!
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body text-center py-4">
                <div class="success-icon">
                    <i class="fas fa-check-circle"></i>
                </div>
                <h4 class="mb-3">Thank You for Registering!</h4>
                <p class="mb-2"><strong>Company:</strong> <span id="modalCompanyName">${companyName}</span></p>
                <p class="mb-3"><strong>Email:</strong> <span id="modalCompanyEmail">${companyEmail}</span></p>
                <div class="alert alert-info">
                    <i class="fas fa-info-circle me-2"></i>
                    ${not empty successMessage ? successMessage : 'Registration submitted! Your request is pending admin approval.'}
                </div>
                <p class="text-muted small mt-3">
                    <i class="fas fa-clock me-1"></i>
                    Approval typically takes 1-2 business days.
                </p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn modal-success-btn" data-bs-dismiss="modal" onclick="redirectToLogin()">
                    <i class="fas fa-sign-in-alt me-1"></i>Go to Login
                </button>
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">
                    Close
                </button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Initialize tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.forEach(function (tooltipTriggerEl) {
            new bootstrap.Tooltip(tooltipTriggerEl);
        });

        // Check if we should show success modal (from servlet attribute)
        const showModal = '${showSuccessModal}' === 'true';

        if (showModal) {
            // Wait a moment for page to load, then show modal
            setTimeout(function() {
                const successModal = new bootstrap.Modal(document.getElementById('successModal'));
                successModal.show();
            }, 500);
        }

        // Form validation
        const form = document.getElementById('registrationForm');
        const submitBtn = document.getElementById('submitBtn');

        if (form) {
            form.addEventListener('submit', function(e) {
                const password = document.getElementById('password').value;
                const confirmPassword = document.getElementById('confirmPassword').value;

                // Validate passwords match
                if (password !== confirmPassword) {
                    e.preventDefault();
                    alert('Passwords do not match! Please check and try again.');
                    return false;
                }

                // Show loading state
                if (submitBtn) {
                    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
                    submitBtn.disabled = true;
                }

                return true;
            });
        }
    });

    function redirectToLogin() {
        window.location.href = '${pageContext.request.contextPath}/UserLogin';
    }
</script>

</body>
</html>