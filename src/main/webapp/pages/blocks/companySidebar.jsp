<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 1. Get the original browser URL (even inside a jsp:include)
    String originUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
    if (originUri == null) {
        originUri = request.getRequestURI();
    }

    // Normalize to lowercase for reliable matching
    originUri = originUri.toLowerCase();

    // 2. Define the Dashboard URL
    String dashboardUrl = request.getContextPath() + "/CompanyDashboard";
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
        <i class="fa-solid fa-building me-2"></i> Company Portal
    </h5>

    <div class="d-flex flex-column">
        <%-- Dashboard Link --%>
        <a class="nav-link <%= originUri.contains("companydashboard") ? "active" : "" %>"
           href="<%= dashboardUrl %>">
            <i class="fa-solid fa-table-columns"></i> Dashboard
        </a>

        <%-- Company Profile Link --%>
        <a class="nav-link <%= originUri.contains("companyprofile") ? "active" : "" %>"
           href="${pageContext.request.contextPath}/CompanyProfile">
            <i class="fa-regular fa-id-card"></i> Company Profile
        </a>

        <%-- Enrolled Interns Link --%>
        <a class="nav-link <%= originUri.contains("enrolledinterns") ? "active" : "" %>"
           href="#">
            <i class="fa-solid fa-user-friends"></i> Enrolled Interns
        </a>

        <%-- Chats Link --%>
        <a class="nav-link <%= originUri.contains("chats") ? "active" : "" %>"
           href="#">
            <i class="fa-regular fa-comments"></i> Chats
        </a>

        <%-- Positions Link (Manage Positions) --%>
        <a class="nav-link <%= originUri.contains("positions") && !originUri.contains("companyprofile") ? "active" : "" %>"
           href="#">
            <i class="fa-solid fa-briefcase"></i> Positions
        </a>
    </div>

    <%-- Bottom Section: Logout --%>
    <div class="mt-3 border-top pt-3">
        <form action="${pageContext.request.contextPath}/Logout" method="post" class="d-inline">
            <button type="submit" class="nav-link text-danger bg-transparent border-0 w-100 text-start">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </button>
        </form>
    </div>
</div>