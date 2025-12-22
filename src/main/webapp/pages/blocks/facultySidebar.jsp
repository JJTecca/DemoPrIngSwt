<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Logic to highlight the active link based on the current URL
    String originUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
    if (originUri == null) originUri = request.getRequestURI();
    originUri = originUri.toLowerCase();

    String facultyDashboardUrl = request.getContextPath() + "/FacultyDashboard";
%>

<style>
    .sidebar-container {
        position: sticky;
        top: 100px;
        height: calc(100vh - 120px);
        background-color: white;
        box-shadow: 2px 0 10px rgba(0, 0, 0, 0.05);
        overflow-y: auto;
        z-index: 1000;
    }

    .sidebar-title {
        color: var(--brand-blue);
        font-weight: 800;
        padding: 1.5rem 1rem;
        border-bottom: 1px solid #eee;
        margin-bottom: 1rem;
    }

    .nav-link {
        color: #555 !important;
        font-weight: 500;
        padding: 0.8rem 1.5rem;
        transition: all 0.3s;
        border-left: 4px solid transparent;
    }

    .nav-link:hover {
        background-color: #f8f9fa;
        color: var(--brand-blue) !important;
        border-left-color: var(--brand-blue);
    }

    .nav-link.active {
        background-color: rgba(14, 43, 88, 0.05);
        color: var(--brand-blue) !important;
        border-left-color: var(--ulbs-red);
        font-weight: 700;
    }

    .nav-link i {
        width: 25px;
        text-align: center;
        margin-right: 10px;
    }
</style>

<div class="col-md-3 col-lg-2 p-0 sidebar-container d-none d-md-block">
    <h5 class="sidebar-title">
        <i class="fa-solid fa-building-columns me-2"></i> Faculty Panel
    </h5>
    <div class="d-flex flex-column">
        <%-- Dashboard Link --%>
        <a class="nav-link <%= originUri.endsWith("/facultydashboard") ? "active" : "" %>" href="<%= facultyDashboardUrl %>">
            <i class="fa-solid fa-chart-line"></i> Dashboard
        </a>

        <%-- NEW: My Profile Link (Points to CompanyProfile) --%>
        <a class="nav-link <%= originUri.contains("companyprofile") ? "active" : "" %>" href="${pageContext.request.contextPath}/CompanyProfile">
            <i class="fa-regular fa-id-card"></i> Faculty Profile
        </a>

        <a class="nav-link <%= originUri.contains("managestudents") ? "active" : "" %>" href="${pageContext.request.contextPath}/ManageStudents">
            <i class="fa-solid fa-users-gear"></i> Manage Students
        </a>
        <a class="nav-link <%= originUri.contains("tutoringpositions") ? "active" : "" %>" href="${pageContext.request.contextPath}/TutoringPositions">
            <i class="fa-solid fa-chalkboard-user"></i> Tutoring Positions
        </a>
        <a class="nav-link <%= originUri.contains("facultychats") ? "active" : "" %>" href="${pageContext.request.contextPath}/FacultyChats">
            <i class="fa-solid fa-comments"></i> Chats
        </a>
    </div>

    <div class="mt-3 border-top pt-3">
        <form action="${pageContext.request.contextPath}/Logout" method="post" class="d-inline">
            <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </button>
        </form>
    </div>
</div>