<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
    .main-footer {
        background-color: var(--brand-blue-dark);
        color: white;
        padding: 2rem 0;
        margin-top: auto; /* Pushes footer to bottom if flex container used */
        border-top: 1px solid rgba(255, 255, 255, 0.1);
    }

    .footer-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        text-align: center;
    }

    .footer-logo {
        height: 160px;
        width: auto;
        margin-bottom: 1.5rem;
        /* Optional: Add white background container if logo needs it */
        border-radius: 4px;
    }

    .footer-links {
        margin-bottom: 1.5rem;
    }

    .footer-links a {
        color: rgba(255, 255, 255, 0.7);
        text-decoration: none;
        margin: 0 10px;
        font-size: 0.9rem;
        transition: color 0.3s;
    }

    .footer-links a:hover {
        color: var(--ulbs-red);
    }

    .copyright-text {
        font-size: 0.85rem;
        color: rgba(255, 255, 255, 0.5);
    }
</style>

<footer class="main-footer">
    <div class="container footer-container">
        <img src="images/logo_vert.png" alt="ULBS Logo Vertical" class="footer-logo">

        <div class="footer-links">
            <a href="https://www.ulbsibiu.ro/">University Website</a>
        </div>

        <p class="copyright-text">
            &copy;
            <script>document.write(new Date().getFullYear())</script>
            CSEE ULBS - Computer Science and Electrical Engineering. All rights reserved.
        </p>
    </div>
</footer>