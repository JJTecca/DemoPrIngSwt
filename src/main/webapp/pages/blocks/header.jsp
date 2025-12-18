<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    :root {
        --brand-blue: #0E2B58;
        --brand-blue-dark: #071a38;
        --ulbs-red: #A30B0B;
    }

    header.sticky-header {
        position: sticky;
        top: 0;
        z-index: 1020;
        width: 100%;
    }

    .main-header {
        background-color: var(--brand-blue);
        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        padding: 0.7rem 2rem;
        border-bottom: 4px solid var(--ulbs-red);
    }

    .header-content {
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .brand-area {
        display: flex;
        align-items: center;
        gap: 1.5rem;
    }

    .header-logo {
        height: 75px; /* Adjust based on actual aspect ratio */
        width: auto;
    }

    .platform-title {
        color: white;
        font-family: 'Segoe UI', Roboto, sans-serif;
        font-weight: 700;
        font-size: 1.4rem;
        letter-spacing: 0.5px;
        margin: 0;
        border-left: 1px solid rgba(255, 255, 255, 0.3);
        padding-left: 1.5rem;
    }

    .user-profile-header {
        color: rgba(255, 255, 255, 0.9);
        font-size: 0.95rem;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .user-icon-circle {
        width: 35px;
        height: 35px;
        background-color: rgba(255, 255, 255, 0.1);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
    }
</style>

<header class="container-fluid p-0 sticky-header">
    <div class="main-header">
        <div class="header-content">
            <div class="brand-area">
                <img src="images/logo_horiz.png" alt="ULBS Logo" class="header-logo">
                <h1 class="platform-title">CSEE Internship Platform</h1>
            </div>

            <div class="user-profile-header">
                <c:if test="${not empty sessionScope.userEmail}">
                    <div class="text-end d-none d-md-block">
                        <span class="d-block fw-bold">Welcome,</span>
                        <span class="small opacity-75">${sessionScope.userEmail}</span>
                    </div>
                    <div class="user-icon-circle">
                        <i class="fa-solid fa-user"></i>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</header>