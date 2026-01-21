<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    List<InternshipApplicationDto> rawApps = (List<InternshipApplicationDto>) request.getAttribute("applications");
    String userRole = (String) session.getAttribute("userRole");
    Long selectedId = (Long) request.getAttribute("selectedAppId");

    List<InternshipApplicationDto> chats = new ArrayList<>();
    List<InternshipApplicationDto> activeChats = new ArrayList<>();
    if (rawApps != null) {
        for (InternshipApplicationDto app : rawApps) {
            if (app.isChatInitiated()) {
                chats.add(app);
                if ("Discussion".equals(app.getStatus()) || "Interview".equals(app.getStatus())) {
                    activeChats.add(app);
                }
            }
        }
    }
%>

<div class="applications-sidebar bg-white border-end h-100 d-flex flex-column shadow-sm"
     style="width: 350px; min-width: 350px; z-index: 10;">

    <div class="p-4 border-bottom bg-light">
        <div class="d-flex justify-content-between align-items-center">
            <h5 class="fw-bold mb-0 text-dark" style="letter-spacing: -0.5px;">
                <i class="fa-solid fa-inbox me-2 text-primary"></i>My Applications
            </h5>
            <div class="form-check form-switch mb-0">
                <input class="form-check-input cursor-pointer" type="checkbox" id="activeOnlyToggle">
                <label class="form-check-label small fw-bold text-muted text-uppercase"
                       for="activeOnlyToggle" style="font-size: 0.6rem; cursor: pointer;">Active Only</label>
            </div>
        </div>
        <div class="text-muted x-small text-uppercase fw-bold mt-1" style="font-size: 0.65rem;">
            <span id="chatCountDisplay"><%= activeChats.size() %></span> Active Discussions
        </div>
    </div>

    <div class="flex-grow-1 overflow-auto custom-scrollbar">

        <div id="activeChatsGroup" style="display: none;">
            <% if (!activeChats.isEmpty()) { %>
            <% for (InternshipApplicationDto app : activeChats) {
                boolean isActive = selectedId != null && selectedId.equals(app.getId());
                String displayName = "Student".equals(userRole) ? app.getCompanyName() : app.getStudentName();
                String pfpRole = "Student".equals(userRole) ? "Company" : "Student";
                Long pfpId = "Student".equals(userRole) ? app.getCompanyId() : app.getStudentId();
                String pfpShape = "Student".equals(userRole) ? "rounded-3" : "rounded-circle";
                String status = app.getStatus();
                String badgeClass = "status-" + status.toLowerCase();
            %>
            <a href="InternshipApplications?id=<%= app.getId() %>"
               class="app-card border-bottom d-flex align-items-center p-3 text-decoration-none transition-all <%= isActive ? "bg-primary-subtle border-start border-primary border-4" : "text-dark" %>">
                <div class="position-relative me-3">
                    <img src="ProfilePicture?id=<%= pfpId %>&targetRole=<%= pfpRole %>"
                         class="<%= pfpShape %> border shadow-sm"
                         style="width: 52px; height: 52px; object-fit: cover;"
                        <%
                        // Logic: If target is Student, use Blue. If target is Company/Faculty, use Silver.
                        String fbColors = "Student".equalsIgnoreCase(pfpRole)
                          ? "&background=0E2B58&color=fff"
                          : "&background=F8F9FA&color=0E2B58";
                        String finalFallback = "https://ui-avatars.com/api/?name=" + displayName.replace(" ", "+") + fbColors;
                        %>
                         onerror="this.src='<%= finalFallback %>';">
                    <% if ("Discussion".equals(app.getStatus())) { %>
                    <span class="position-absolute bottom-0 end-0 p-1 bg-primary border border-light rounded-circle"></span>
                    <% } %>
                </div>
                <div class="flex-grow-1 overflow-hidden">
                    <div class="fw-bold text-truncate mb-0" style="font-size: 0.95rem;"><%= app.getPositionTitle() %></div>
                    <div class="small text-muted text-truncate mb-1"><%= displayName %></div>
                    <span class="status-badge <%= badgeClass %>"><%= status %></span>
                </div>
            </a>
            <% } %>
            <% } else { %>
            <div class="text-center p-5 mt-4 opacity-50">
                <i class="fa-solid fa-filter-circle-xmark fa-2x mb-2"></i>
                <p class="small fw-bold">No active discussions</p>
            </div>
            <% } %>
        </div>

        <div id="allChatsGroup">
            <% if (chats != null && !chats.isEmpty()) { %>
            <% for (InternshipApplicationDto app : chats) {
                boolean isActive = selectedId != null && selectedId.equals(app.getId());
                String displayName = "Student".equals(userRole) ? app.getCompanyName() : app.getStudentName();
                String pfpRole = "Student".equals(userRole) ? "Company" : "Student";
                Long pfpId = "Student".equals(userRole) ? app.getCompanyId() : app.getStudentId();
                String pfpShape = "Student".equals(userRole) ? "rounded-3" : "rounded-circle";
                String status = app.getStatus();

                String badgeClass = "bg-light text-muted border";
                if ("Accepted".equalsIgnoreCase(status)) badgeClass = "status-accepted";
                else if ("Rejected".equalsIgnoreCase(status)) badgeClass = "status-rejected";
                else if ("Pending".equalsIgnoreCase(status)) badgeClass = "status-pending";
                else if ("Interview".equalsIgnoreCase(status)) badgeClass = "status-interview";
                else if ("Discussion".equalsIgnoreCase(status)) badgeClass = "status-discussion";
                else if ("Request".equalsIgnoreCase(status)) badgeClass = "status-request";
            %>
            <a href="InternshipApplications?id=<%= app.getId() %>"
               class="app-card border-bottom d-flex align-items-center p-3 text-decoration-none transition-all <%= isActive ? "bg-primary-subtle border-start border-primary border-4" : "text-dark" %>">
                <div class="position-relative me-3">
                    <img src="ProfilePicture?id=<%= pfpId %>&targetRole=<%= pfpRole %>"
                         class="<%= pfpShape %> border shadow-sm"
                         style="width: 52px; height: 52px; object-fit: cover;"
                        <%
                        // Logic: If target is Student, use Blue. If target is Company/Faculty, use Silver.
                        String fbColors = "Student".equalsIgnoreCase(pfpRole)
                          ? "&background=0E2B58&color=fff"
                          : "&background=F8F9FA&color=0E2B58";
                        String finalFallback = "https://ui-avatars.com/api/?name=" + displayName.replace(" ", "+") + fbColors;
                        %>
                         onerror="this.src='<%= finalFallback %>';">
                    <% if ("Discussion".equals(app.getStatus())) { %>
                    <span class="position-absolute bottom-0 end-0 p-1 bg-primary border border-light rounded-circle"></span>
                    <% } %>
                </div>
                <div class="flex-grow-1 overflow-hidden">
                    <div class="fw-bold text-truncate mb-0" style="font-size: 0.95rem;"><%= app.getPositionTitle() %></div>
                    <div class="small text-muted text-truncate mb-1"><%= displayName %></div>
                    <span class="status-badge <%= badgeClass %>"><%= status %></span>
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
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const toggle = document.getElementById('activeOnlyToggle');
        const activeGroup = document.getElementById('activeChatsGroup');
        const allGroup = document.getElementById('allChatsGroup');
        const countDisplay = document.getElementById('chatCountDisplay');

        function updateSidebarView() {
            const isChecked = toggle.checked;
            if (isChecked) {
                activeGroup.style.display = 'block';
                allGroup.style.display = 'none';
            } else {
                activeGroup.style.display = 'none';
                allGroup.style.display = 'block';
            }
            localStorage.setItem('sidebarFilterActive', isChecked);
        }

        // Initialize from LocalStorage
        const savedFilter = localStorage.getItem('sidebarFilterActive') === 'true';
        toggle.checked = savedFilter;
        updateSidebarView();

        toggle.addEventListener('change', updateSidebarView);
    });
</script>