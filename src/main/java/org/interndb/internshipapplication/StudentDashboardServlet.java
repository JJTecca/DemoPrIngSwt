package org.interndb.internshipapplication;

import com.internshipapp.commands.UpdateApplicationCommand;
import com.internshipapp.common.*;
import com.internshipapp.ejb.*;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   4. Redirect to render the studentPanel.jsp
 **********************************************************/

/****************************************************************************
 * StudentsServlet logic:
 *  -doGet :  Set User Attributes we want to display 
 *  -doPost : Handle Students Update Requested Applications
 ****************************************************************************/
@WebServlet(name = "StudentDashboardServlet", value = "/StudentDashboard")
public class StudentDashboardServlet extends HttpServlet {
    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    StudentInfoBean studentInfoBean;

    @Inject
    InternshipApplicationBean internshipAppBean;

    @Inject
    PermissionBean permissionBean;

    @Inject
    AccountActivityBean accountActivityBean;

    @Inject
    UserAccountBean userAccountBean;

    @Inject
    CompanyInfoBean companyInfoBean;

    /******************************************************************
     * @param request an {@link HttpServletRequest}
     * @param response an {@link HttpServletResponse}
     * doGet functions implementation to retrieve data from the server
     * Display a webpage or form
     * doPost to handle form submissions : Insert, update, or delete data
     *****************************************************************/
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        try {
            // Show only their own details
            if ("Student".equals(role)) {
                // Use UserAccountBean to get student info (since it has the relationship)
                StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
                CompanyInfoDto facultyProfile = companyInfoBean.findFacultyProfile();
                if (facultyProfile != null) {
                    request.setAttribute("facultyId", facultyProfile.getId());
                }

                if (student == null) {
                    System.out.println("DEBUG: No student found for email: " + email);
                    request.setAttribute("errorMessage", "No student profile found for your account");
                } else {
                    System.out.println("DEBUG: Student found - ID: " + student.getId() +
                            ", Name: " + student.getFullName());

                    UserAccountDto userDto = userAccountBean.findByEmail(email);
                    List<AccountActivityDto> activities = getRecentActivities(student.getUserId());
                    Map<String, Object> studentStats = calculateStudentStats(student);
                    List<InternshipApplicationDto> myApplications = internshipAppBean.findApplicationsByStudentId(student.getId());

                    // Set attributes for JSP
                    request.setAttribute("myApplications", myApplications);
                    request.setAttribute("student", student);
                    request.setAttribute("userAccount", userDto);
                    request.setAttribute("activities", activities);
                    request.setAttribute("studentStats", studentStats);

                    System.out.println("DEBUG: Student data loaded successfully");
                }
            }
            request.setAttribute("userEmail", email);
            request.setAttribute("userRole", role);

        } catch (Exception e) {
            System.err.println("ERROR in StudentsServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error loading student data: " + e.getMessage());
        }

        request.getRequestDispatcher("pages/panels/studentPanel.jsp").forward(request, response);
    }

    private List<AccountActivityDto> getRecentActivities(Long userId) {
        try {
            List<AccountActivityDto> allActivities = accountActivityBean.findAllActivities();
            List<AccountActivityDto> filteredActivities = new ArrayList<>();

            if (userId != null) {
                // Filter activities for specific user
                for (AccountActivityDto activity : allActivities) {
                    if (activity.getUserId() != null && activity.getUserId().equals(userId)) {
                        filteredActivities.add(activity);
                    }
                }
            } else {
                filteredActivities = allActivities;
            }

            // Sort by date (newest first) and limit to 10
            filteredActivities.sort((a1, a2) -> a2.getActionTime().compareTo(a1.getActionTime()));

            return filteredActivities.size() > 10 ? filteredActivities.subList(0, 10) : filteredActivities;

        } catch (Exception e) {
            System.err.println("Error getting recent activities: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    private Map<String, Object> calculateStudentStats(StudentInfoDto student) {
        Map<String, Object> stats = new HashMap<>();

        try {
            // Calculate status badge color
            String statusColor = "secondary";
            if ("Available".equals(student.getStatus())) {
                statusColor = "success";
            } else if ("Accepted".equals(student.getStatus())) {
                statusColor = "primary";
            } else if ("Completed".equals(student.getStatus())) {
                statusColor = "info";
            }
            stats.put("statusColor", statusColor);

            // Calculate enrollment status
            stats.put("enrollmentStatus", student.getEnrolled() ? "Enrolled" : "Not Enrolled");
            stats.put("enrollmentColor", student.getEnrolled() ? "success" : "danger");

            // Calculate grade status
            String gradeColor = "secondary";
            if (student.getLastYearGrade() != null) {
                if (student.getLastYearGrade() >= 8.0) {
                    gradeColor = "success";
                } else if (student.getLastYearGrade() >= 6.0) {
                    gradeColor = "warning";
                } else {
                    gradeColor = "danger";
                }
            }
            stats.put("gradeColor", gradeColor);

            // Full name is already available via getFullName() method
            stats.put("fullName", student.getFullName());

        } catch (Exception e) {
            System.err.println("Error calculating student stats: " + e.getMessage());
        }

        return stats;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String role = (String) session.getAttribute("userRole");
        if (session == null || !"Student".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        // If the current status is NOT 'Request', block the student from Rejecting/Declining via this specific dashboard flow
        // (This prevents students from changing an application that has already moved to Interview/Accepted/Discussion)

        String action = request.getParameter("action");
        if ("updateStatus".equals(action)) {
            try {
                Long appId = Long.parseLong(request.getParameter("id"));
                String newStatus = request.getParameter("status");

                InternshipApplicationDto app = internshipAppBean.getApplicationDtoById(appId);

                if (!"Discussion".equals(newStatus) && !"Rejected".equals(newStatus)) {
                    throw new IllegalStateException("You can only accept to Discussion or Reject.");
                }

                if (!"Request".equals(app.getStatus())) {
                    throw new IllegalStateException("You can only change from Request.");
                }

                // Perform update via Bean
                UpdateApplicationCommand cmd = new UpdateApplicationCommand(appId, newStatus,
                        null, null, role);
                internshipAppBean.updateApplicationStatus(cmd);

                // Log the acceptance/rejection
                System.out.println("DEBUG: Student " + session.getAttribute("userEmail") +
                        " updated App ID " + appId + " to " + newStatus);

                response.sendRedirect("StudentDashboard?update=success");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("StudentDashboard?update=error");
            }
        } else {
            // Fallback for other post actions if necessary
            doGet(request, response);
        }
    }
}