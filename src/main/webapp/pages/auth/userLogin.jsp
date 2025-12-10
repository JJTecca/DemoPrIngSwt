<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In - Internship Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">

    <style>
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

        .login-form-area {
            position: relative !important;
        }

        .login-container {
            display: flex;
            min-height: 100vh;
        }

        .login-form-area {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 2rem;

            background-image: url('images/background0.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }

        .login-form-area::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(
                    to bottom,
                    rgba(14, 43, 88, 0.50),
                    rgba(14, 43, 88, 0.65)
            );
            z-index: 1;
        }

        .login-form-area > * {
            position: relative;
            z-index: 2;
        }

        .form-box {
            max-width: 500px;
            width: 100%;
            padding: 0;
            border-radius: 1rem;
            box-shadow: 0 20px 50px rgba(0,0,0,0.4);
            overflow: hidden;
            background-color: white;
        }

        .form-box-header {
            background-color: var(--brand-blue);
            padding: 3rem 3rem 1rem 3rem;
            color: white;
        }

        .form-box-body {
            background-color: white;
            padding: 1rem 3rem 3rem 3rem;
        }

        .form-box__title {
            color: white;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .form-box__description {
            color: rgba(255, 255, 255, 0.85);
            font-size: 1.1rem;
        }

        .form-control-lg {
            border: 2px solid #e9ecef;
            padding: 0.8rem 1rem;
            font-size: 1rem;
            border-radius: 0.5rem;
            background-color: #f8f9fa;
        }
        .form-control-lg:focus {
            background-color: #ffffff;
            border-color: var(--brand-blue);
            box-shadow: 0 0 0 4px rgba(14, 43, 88, 0.15);
        }

        .btn-main-login {
            background-color: var(--brand-blue);
            border: none;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
            padding: 0.8rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(14, 43, 88, 0.2);
        }
        .btn-main-login:hover {
            background-color: var(--brand-blue-dark);
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(14, 43, 88, 0.3);
        }

        .btn-contact-us {
            color: var(--brand-blue);
            border: 2px solid var(--brand-blue);
            font-weight: 600;
            border-radius: 50px;
            transition: all 0.3s ease;
        }
        .btn-contact-us:hover {
            background-color: var(--brand-blue);
            color: white;
        }

        .login-info-area {
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
            max-width: 280px;
            height: auto;
            margin-bottom: 2rem;
        }

        .login-info-area h1 { color: var(--brand-blue); }
        .login-info-area h2 { color: #555; }

        .info-lead-text {
            color: #444;
            font-weight: 500;
            font-size: 1.2rem;
            line-height: 1.6;
        }

        .info-small-text {
            color: #555;
            font-weight: 600;
        }

        .highlight-text {
            color: var(--brand-blue);
            font-weight: 800;
        }

    </style>
</head>
<body>

<div class="container-fluid p-0 login-container">

    <div class="col-lg-9 col-md-8 col-12 login-form-area">

        <div class="form-box">

            <div class="form-box-header">
                <h1 class="mb-2 text-center display-4 form-box__title">Log In</h1>
                <p class="text-center mb-0 form-box__description">
                    Welcome back. Access your portal below.
                </p>
            </div>

            <div class="form-box-body">
                <form action="UserLogin" method="POST" class="mt-4">

                    <div class="mb-3">
                        <label for="email" class="form-label text-muted fw-bold small">EMAIL ADDRESS</label>
                        <input type="email" class="form-control form-control-lg" id="email" name="email"
                               placeholder="student@ulbsibiu.ro / name@company.com" required>
                    </div>

                    <div class="mb-4">
                        <label for="password" class="form-label text-muted fw-bold small">PASSWORD</label>
                        <input type="password" class="form-control form-control-lg" id="password" name="password"
                               placeholder="••••••••" required>
                    </div>

                    <div class="d-grid gap-2 mb-4">
                        <button type="submit" class="btn btn-main-login">
                            LOG IN
                        </button>
                    </div>
                </form>

                <hr class="text-muted my-4">

                <div class="text-center">
                    <p class="text-muted small mb-3">Forgot your credentials or need assistance?</p>
                    <a href="contact.jsp" class="btn btn-contact-us px-4 py-2">
                        Contact Support
                    </a>
                </div>
            </div>

        </div>
    </div>

    <div class="col-lg-3 col-md-4 d-none d-md-flex login-info-area">
        <div>
            <img src="images/logo.png"
                 alt="ULBS Logo" class="ulbs-logo">

            <h2 class="h5 text-uppercase fw-bold mb-2 ls-2">Internship Program</h2>
            <h1 class="h2 fw-bolder mb-4">CSEE ULBS</h1>

            <p class="info-lead-text mb-5">
                Connecting Students, Faculty, and Companies for practical experience.
            </p>

            <p class="info-small-text mt-auto small">
                <span class="highlight-text">CSEE ULBS</span><br>
                Computer Science and <br>Electrical Engineering<br>
                Lucian Blaga University of Sibiu
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>