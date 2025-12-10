package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.AccountActivityDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.PermissionBean;
import com.internshipapp.ejb.StudentInfoBean;
import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**********************************************************
 *              STUDENT DASHBOARD SERVLET:
 *    Displays comprehensive student information including:
 *    1. Student personal details
 *    2. Account information
 *    3. Recent activities
 *    4. Statistics
 **********************************************************/
@WebServlet(name = "StudentsServlet", value = "/Students")
public class StudentsServlet extends HttpServlet {
    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    StudentInfoBean studentInfoBean;

    @Inject
    PermissionBean  permissionBean;

    @Inject
    AccountActivityBean accountActivityBean;

    @Inject
    UserAccountBean userAccountBean;

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
            // For STUDENT role: Show only their own details
            if ("Student".equals(role)) {
                // Use UserAccountBean to get student info (since it has the relationship)
                StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);

                if (student == null) {
                    System.out.println("DEBUG: No student found for email: " + email);
                    request.setAttribute("errorMessage", "No student profile found for your account");
                } else {
                    System.out.println("DEBUG: Student found - ID: " + student.getId() +
                            ", Name: " + student.getFullName());

                    UserAccountDto userDto = userAccountBean.findByEmail(email);
                    List<AccountActivityDto> activities = getRecentActivities(student.getUserId());
                    Map<String, Object> studentStats = calculateStudentStats(student);

                    // Set attributes for JSP
                    request.setAttribute("student", student);
                    request.setAttribute("userAccount", userDto);
                    request.setAttribute("activities", activities);
                    request.setAttribute("studentStats", studentStats);

                    System.out.println("DEBUG: Student data loaded successfully");
                }
            }
            // For FACULTY/ADMIN role: Show all students with statistics
            else if ("Faculty".equals(role) || "Admin".equals(role)) {
                List<StudentInfoDto> allStudents = studentInfoBean.findAllStudents();
                Map<String, Object> statistics = studentInfoBean.getStudentStatistics();
                List<AccountActivityDto> recentActivities = getRecentActivities(null);

                // Set attributes for JSP
                request.setAttribute("allStudents", allStudents);
                request.setAttribute("statistics", statistics);
                request.setAttribute("recentActivities", recentActivities);

                System.out.println("DEBUG: Loaded " + allStudents.size() + " students");
                System.out.println("DEBUG: Statistics: " + statistics);
            }
            else {
                // For other roles (Company), redirect to appropriate panel
                response.sendRedirect("UserLogin");
                return;
            }

            // Set common attributes
            request.setAttribute("userEmail", email);
            request.setAttribute("userRole", role);

        } catch (Exception e) {
            System.err.println("ERROR in StudentsServlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Error loading student data: " + e.getMessage());
        }

        // Forward to appropriate JSP based on role
        if ("Student".equals(role)) {
            request.getRequestDispatcher("pages/panels/studentPanel.jsp").forward(request, response);
        } else if ("Faculty".equals(role) || "Admin".equals(role)) {
            request.getRequestDispatcher("pages/panels/facultyStudentView.jsp").forward(request, response);
        }
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
                // Return all activities (for faculty/admin)
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
}