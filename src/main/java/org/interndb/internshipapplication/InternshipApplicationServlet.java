package org.interndb.internshipapplication;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.common.MessageDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.CompanyInfoBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.MessageBean;
import com.internshipapp.entities.UserAccount;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "InternshipApplicationServlet", value = "/InternshipApplications")
public class InternshipApplicationServlet extends HttpServlet {

    @Inject
    private InternshipApplicationBean applicationBean;

    @Inject
    private AccountActivityBean activityBean;

    @Inject
    private MessageBean messageBean;

    @Inject
    private CompanyInfoBean companyBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        // 1. Session Check
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        Long userId = (Long) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");
        String appIdParam = request.getParameter("id");

        // 2. Handle specific POST-like actions sent via GET (Legacy Support)
        if (action != null) {
            switch (action) {
                case "updateStatus":
                    handleStatusUpdate(request, response);
                    return; // Exit after handling
                case "assignTutoring":
                    handleFacultyAssignment(request, response);
                    return; // Exit after handling
            }
        }

        try {
            // Load the Sidebar List for the logged-in user
            List<InternshipApplicationDto> sidebarList = applicationBean.getApplicationsForUser(userId, role);
            request.setAttribute("applications", sidebarList);

            // 4. Load Active Discussion (If an ID is selected)
            if (appIdParam != null && !appIdParam.isEmpty()) {
                Long appId = Long.parseLong(appIdParam);
                InternshipApplicationDto activeApp = applicationBean.getApplicationDtoById(appId);

                // Security: Ensure the user belongs to this application
                if (isAuthorized(activeApp, userId, role)) {
                    request.setAttribute("activeApplication", activeApp);
                    request.setAttribute("selectedAppId", appId);

                    // Fetch Chat History
                    List<MessageDto> history = messageBean.getChatHistory(appId);
                    request.setAttribute("chatHistory", history);

                    // Fetch Company Info (for contact details in the header)
                    CompanyInfoDto companyInfo = companyBean.findById(activeApp.getCompanyId());
                    request.setAttribute("companyInfo", companyInfo);
                }
            }

            // Forward to the new 3-pane JSP
            request.getRequestDispatcher("/pages/social/internshipApplications.jsp").forward(request, response);

        } catch (Exception e) {
            // If something fails, fall back to the dashboard based on role
            String redirect = "StudentDashboard";
            if ("Company".equals(role)) redirect = "CompanyDashboard";
            if ("Faculty".equals(role)) redirect = "FacultyDashboard";

            response.sendRedirect(redirect + "?error=load_failed");
        }
    }

    private boolean isAuthorized(InternshipApplicationDto app, Long sessionUserId, String role) {
        if (app == null) return false;
        if ("Admin".equals(role)) return true;

        // We must find the UserAccount to see which Student/Company info it owns
        UserAccount user = applicationBean.getUserAccountById(sessionUserId);
        if (user == null) return false;

        if ("Student".equals(role)) {
            return user.getStudentInfo() != null && user.getStudentInfo().getId().equals(app.getStudentId());
        } else {
            // Faculty and Company both check against the CompanyInfo ID
            return user.getCompanyInfo() != null && user.getCompanyInfo().getId().equals(app.getCompanyId());
        }
    }

    private void handleFacultyAssignment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("userRole");

        // Authorization: Only Faculty can use this specific fast-track tool
        if (!"Faculty".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            Long studentId = Long.parseLong(request.getParameter("studentId"));
            Long positionId = Long.parseLong(request.getParameter("positionId"));

            // Call the new transactional method in the Bean
            applicationBean.assignStudentAndCleanUp(studentId, positionId);

            response.sendRedirect("FacultyDashboard?update=assigned");
        } catch (Exception e) {
            response.sendRedirect("FacultyDashboard?update=error");
        }
    }

    private void handleStatusUpdate(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("userRole");

        // Authorization check: Only Companies or Faculty can change statuses
        if (!"Company".equals(role) && !"Faculty".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            Long appId = Long.parseLong(request.getParameter("id"));
            String newStatus = request.getParameter("status");
            String dateStr = request.getParameter("interviewDate");
            String loc = request.getParameter("location");
            LocalDateTime interviewDateTime = (dateStr != null && !dateStr.isEmpty())
                    ? LocalDateTime.parse(dateStr) : null;

            if ("Interview".equals(newStatus)){
                applicationBean.updateApplicationStatus(appId, newStatus, interviewDateTime, loc);
            } else {
                // Perform the update
                applicationBean.updateApplicationStatus(appId, newStatus);
            }

            response.sendRedirect("CompanyDashboard?update=success");
        } catch (Exception e) {
            response.sendRedirect("CompanyDashboard?update=error");
        }
    }
}