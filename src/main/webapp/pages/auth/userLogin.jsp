<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In - Internship Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">

    <style>
        .login-container {
            display: flex;
            min-height: 100vh;
        }

        .login-form-area {
            position: relative;
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            overflow: hidden;
            background-color: #0E2B58;
        }

        #bg-fader, .login-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
        }

        #bg-fader {
            background-image: url('images/background0.png');
            background-size: cover;
            background-position: center;
            transition: opacity 0.8s linear;
            z-index: 1;
            opacity: 1;
        }

        .login-overlay {
            background: linear-gradient(to bottom, rgba(14, 43, 88, 0.50), rgba(14, 43, 88, 0.65));
            z-index: 2;
        }

        .form-box {
            position: relative;
            z-index: 10;
            max-width: 500px;
            width: 100%;
            padding: 0;
            border-radius: 1rem;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.4);
            overflow: hidden;
            background-color: white;
        }

        .form-box-header {
            background: var(--brand-gradient);
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
            background: var(--brand-gradient);
            border: none;
            color: white;
            font-weight: 700;
            font-size: 1.2rem;
            padding: 0.8rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(14, 43, 88, 0.2);
        }

        .btn-main-login:hover {
            filter: brightness(1.1);
            transform: translateY(-2px);
            box-shadow: 0 8px 15px rgba(14, 43, 88, 0.3);
            color: white;
        }

        .btn-company-reg {
            color: var(--brand-blue);
            border: 2px solid var(--brand-blue);
            font-weight: 600;
            border-radius: 50px;
            transition: all 0.3s ease;
        }

        .btn-company-reg:hover {
            background: var(--brand-gradient);
            border-color: transparent;
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
            position: relative;
            z-index: 5;
        }

        .ulbs-logo {
            max-width: 100%;
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

        .login-info-area img {
            display: block;
            margin-left: auto;
            margin-right: auto;
        }

        .info-small-text { color: #555; font-weight: 600; }
        .highlight-text { color: var(--brand-blue); font-weight: 800; }
    </style>
</head>
<body>

<div class="container-fluid p-0 login-container">

    <div class="col-lg-9 col-md-8 col-12 login-form-area">

        <div id="bg-fader"></div>
        <div class="login-overlay"></div>

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
                    <p class="text-muted small mb-3">Partner with CSEE and start recruiting.</p>
                    <a href="CompanyRegister" class="btn btn-company-reg px-4 py-2">
                        Company Register
                    </a>
                </div>
            </div>

        </div>
    </div>

    <div class="col-lg-3 col-md-4 d-none d-md-flex login-info-area">
        <div>
            <img src="images/logo_vert.png"
                 alt="ULBS Logo" class="ulbs-logo">

            <h2 class="h5 text-uppercase fw-bold mb-2 ls-2">Internship Program</h2>
            <div class="mb-4">
                <img src="images/cseelogo.png" alt="CSEE Logo" style="max-width: 220px; height: auto;">
            </div>

            <p class="info-lead-text mb-5">
                Connecting Students, Faculty, and Companies for practical experience.
            </p>

            <p class="info-small-text mt-auto small" style="font-size: 12px">
                Computer Science and <br>Electrical Engineering<br>
                Lucian Blaga University of Sibiu
            </p>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<jsp:include page="../blocks/footer.jsp"/>

<script>
    (function() {
        const fader = document.getElementById('bg-fader');
        const images = [
            'images/background0.png',
            'images/background1.png',
            'images/background4.jpg'
        ];

        let currentIndex = 0;

        // Preload all images immediately
        images.forEach(src => {
            const img = new Image();
            img.src = src;
        });

        function changeBackground() {
            // 1. Start Fade out
            fader.style.opacity = '0';

            // 2. Wait for the fade duration (1.5s) to swap the image
            setTimeout(() => {
                currentIndex = (currentIndex + 1) % images.length;
                fader.style.backgroundImage = "url('" + images[currentIndex] + "')";

                // 3. Immediately start Fade in
                fader.style.opacity = '1';
            }, 800);
        }

        // Set the interval
        setInterval(changeBackground, 7000);
    })();
</script>
</body>
</html>