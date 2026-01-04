package org.interndb.internshipapplication;

import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "InternshipApplicationServlet", value = "/InternshipApplication")
public class InternshipApplicationServlet extends HttpServlet {

    @Inject
    private InternshipApplicationBean applicationBean;

    @Inject
    private AccountActivityBean activityBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            response.sendRedirect("CompanyDashboard");
            return;
        }

        switch (action) {
            case "updateStatus":
                handleStatusUpdate(request, response);
                break;
            case "assignTutoring":
                handleFacultyAssignment(request, response);
                break;
            default:
                response.sendRedirect("CompanyDashboard");
                break;
        }
    }

    private void handleFacultyAssignment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("userRole");

        // Authorization: Only Faculty can use this specific fast-track tool
        if (session == null || !"Faculty".equals(role)) {
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
        if (session == null || (!"Company".equals(role) && !"Faculty".equals(role))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            Long appId = Long.parseLong(request.getParameter("id"));
            String newStatus = request.getParameter("status");
            Long userId = (Long) session.getAttribute("userId");

            // Perform the update
            applicationBean.updateApplicationStatus(appId, newStatus);

            // Log activity
            activityBean.logActivity(userId, "UPDATE_APP_STATUS",
                    "Application ID: " + appId + " moved to " + newStatus);

            response.sendRedirect("CompanyDashboard?update=success");
        } catch (Exception e) {
            response.sendRedirect("CompanyDashboard?update=error");
        }
    }
}