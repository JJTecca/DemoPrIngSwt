<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.*" %>
<%@ page import="java.util.List" %>
<%
    List<InternshipApplicationDto> sidebarApps = (List<InternshipApplicationDto>) request.getAttribute("applications");
    String userRole = (String) session.getAttribute("userRole");
    Long selectedId = (Long) request.getAttribute("selectedAppId");
%>

<div class="applications-sidebar bg-white border-end h-100 d-flex flex-column shadow-sm"
     style="width: 350px; min-width: 350px; z-index: 10;">
    <div class="p-4 border-bottom bg-light">
        <h5 class="fw-bold mb-0 text-dark" style="letter-spacing: -0.5px;">
            <i class="fa-solid fa-inbox me-2 text-primary"></i>My Applications
        </h5>
        <div class="text-muted x-small text-uppercase fw-bold mt-1" style="font-size: 0.65rem;">
            <%= sidebarApps != null ? sidebarApps.size() : 0 %> Active Discussions
        </div>
    </div>

    <div class="flex-grow-1 overflow-auto custom-scrollbar">
        <% if (sidebarApps != null && !sidebarApps.isEmpty()) { %>
        <% for (InternshipApplicationDto app : sidebarApps) {
            boolean isActive = selectedId != null && selectedId.equals(app.getId());
            String displayName = "Student".equals(userRole) ? app.getCompanyName() : app.getStudentName();
            String pfpRole = "Student".equals(userRole) ? "Company" : "Student";
            Long pfpId = "Student".equals(userRole) ? app.getCompanyId() : app.getStudentId();
            String pfpShape = "Student".equals(userRole) ? "rounded-3" : "rounded-circle";
        %>
        <a href="InternshipApplications?id=<%= app.getId() %>"
           class="app-card border-bottom d-flex align-items-center p-3 text-decoration-none transition-all <%= isActive ? "bg-primary-subtle border-start border-primary border-4" : "text-dark" %>">

            <div class="position-relative me-3">
                <img src="ProfilePicture?id=<%= pfpId %>&targetRole=<%= pfpRole %>"
                     class="<%= pfpShape %> border shadow-sm"
                     style="width: 52px; height: 52px; object-fit: cover;"
                     onerror="this.src='https://ui-avatars.com/api/?name=<%= displayName.replace(" ", "+") %>&background=0E2B58&color=fff';">
                <% if ("Discussion".equals(app.getStatus())) { %>
                <span class="position-absolute bottom-0 end-0 p-1 bg-primary border border-light rounded-circle"
                      title="Active Chat"></span>
                <% } %>
            </div>

            <div class="flex-grow-1 overflow-hidden">
                <div class="fw-bold text-truncate mb-0"
                     style="font-size: 0.95rem; color: #1a1a1a;"><%= app.getPositionTitle() %>
                </div>
                <div class="small text-muted text-truncate mb-1"><%= displayName %>
                </div>
                <span class="badge x-small fw-bold <%= "Accepted".equals(app.getStatus()) ? "bg-success" : "bg-light text-primary border" %>"
                      style="font-size: 0.65rem;">
                            <%= app.getStatus() %>
                        </span>
            </div>
        </a>
        <% } %>
        <% } else { %>
        <div class="text-center p-5 mt-4 opacity-50">
            <i class="fa-solid fa-message-slash fa-3x mb-3"></i>
            <p class="small fw-bold">No applications found</p>
        </div>
        <% } %>
    </div>
</div>