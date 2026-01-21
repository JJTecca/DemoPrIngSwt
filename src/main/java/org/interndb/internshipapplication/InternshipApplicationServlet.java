package org.interndb.internshipapplication;

import com.internshipapp.commands.UpdateApplicationCommand;
import com.internshipapp.common.*;
import com.internshipapp.ejb.*;
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

    @Inject
    private StudentInfoBean studentInfoBean;

    @Inject
    private UserAccountBean userAccountBean;

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

            e.printStackTrace();
            response.sendRedirect(redirect + "?error=load_failed");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String action = request.getParameter("action");

        // 1. Handle Status Updates (The Management Form)
        if ("updateStatus".equals(action)) {
            handleStatusUpdate(request, response);
            return;
        }

        if ("gradeInternship".equals(action)) {
            try {
                Long appId = Long.parseLong(request.getParameter("id"));
                Float grade = Float.parseFloat(request.getParameter("grade"));
                String feedback = request.getParameter("feedback");

                InternshipApplicationDto appDto = applicationBean.getApplicationDtoById(appId);

                if (appDto != null) {

                    // 1. Fetch Student Info
                    StudentInfoDto student = studentInfoBean.findStudentByAppId(appDto.getStudentId());

                    // 2. Perform the database updates
                    applicationBean.submitFinalEvaluation(appId, grade, feedback, student.getId());

                    // 3. Log the Activity
                    Long currentUserId = (Long) session.getAttribute("userId");
                    String logDetails = String.format("Graded student %s: %.1f/10. Feedback: %s",
                            student.getFullName(), grade, feedback);

                    // "GradeInternship" matches the enum value Action.GradeInternship
                    activityBean.logActivity(currentUserId, "GradeInternship", logDetails);
                }

                response.sendRedirect("InternshipApplications?id=" + appId + "&success=graded");
            } catch (Exception e) {
                response.sendRedirect("InternshipApplications?error=eval_failed");
            }
        }
    }

    private boolean isAuthorized(InternshipApplicationDto app, Long sessionUserId, String role) {
        if (app == null) return false;
        if ("Admin".equals(role)) return true;

        UserAccountDto user = userAccountBean.getUserById(sessionUserId);
        if (user == null) return false;

        if ("Student".equals(role)) {
            return user.getStudentId() != null && user.getStudentId().equals(app.getStudentId());
        } else {
            // Log these values to your GlassFish console to see the discrepancy
            System.out.println("DEBUG Auth - User Dept ID: " + user.getCompanyId());
            System.out.println("DEBUG Auth - App Dept ID: " + app.getCompanyId());

            return user.getCompanyId() != null && user.getCompanyId().equals(app.getCompanyId());
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
            applicationBean.assignStudentAndCleanUp(studentId, positionId, role);

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

            InternshipApplicationDto app = applicationBean.getApplicationDtoById(appId);
            if ("Request".equals(app.getStatus())) {
                // Block Companies
                throw new IllegalStateException("This application is waiting for a student response. You cannot change the state manually.");
            }

            UpdateApplicationCommand cmd = new UpdateApplicationCommand(appId, newStatus,
                    null, null, role);
            if ("Interview".equals(newStatus)){
                cmd.setInterviewDate(interviewDateTime);
                cmd.setLocation(loc);
                applicationBean.updateApplicationStatus(cmd);
            } else {
                // Perform the update
                applicationBean.updateApplicationStatus(cmd);
            }

            String redirectUrl = "CompanyDashboard";
            if ("Faculty".equals(role)) {
                redirectUrl = "FacultyDashboard";
            }

            response.sendRedirect(redirectUrl + "?update=success");
        } catch (Exception e) {
            String redirectUrl = "CompanyDashboard";
            if ("Faculty".equals(role)) {
                redirectUrl = "FacultyDashboard";
            }
            response.sendRedirect(redirectUrl + "?update=error");
        }
    }
}