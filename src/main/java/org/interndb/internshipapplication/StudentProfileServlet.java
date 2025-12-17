package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.StudentInfoBean;
import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.entities.AccountActivity;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "StudentProfileServlet", value = "/StudentProfile")
public class StudentProfileServlet extends HttpServlet {

    @Inject
    StudentInfoBean studentInfoBean;

    @Inject
    UserAccountBean userAccountBean;

    @Inject
    AccountActivityBean activityBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        String idParam = request.getParameter("id");
        StudentInfoDto student = null;

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // View specific student (Admin/Faculty/Company view)
                Long studentId = Long.parseLong(idParam);
                student = studentInfoBean.findById(studentId);
            } else {
                // View own profile
                if ("Student".equals(role)) {
                    student = userAccountBean.getStudentInfoByEmail(loggedInEmail);
                } else {
                    // Non-students without an ID param get redirected
                    if ("Company".equals(role)) {
                        response.sendRedirect("pages/panels/companyPanel.jsp");
                        return;
                    }
                    response.sendRedirect("AdminDashboard");
                    return;
                }
            }

            if (student == null) {
                // Handle case where profile doesn't exist
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Student profile not found");
                request.getRequestDispatcher("/pages/error.jsp").forward(request, response);
                return;
            }

            request.setAttribute("student", student);

            // --- UPDATED PATH HERE ---
            // Points to: webapp/pages/profiles/studentProfile.jsp
            request.getRequestDispatcher("/pages/public/studentProfile.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Student ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading profile");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");

        // 1. GENERIC SECURITY CHECK
        if (loggedInEmail == null || !"Student".equals(role) || action == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied or missing action parameter.");
            return;
        }

        try {
            // 2. GENERIC DATA FETCH
            StudentInfoDto studentDto = userAccountBean.getStudentInfoByEmail(loggedInEmail);

            if (studentDto == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Student profile not found.");
                return;
            }

            // Fetch UserAccount data for logging purposes
            UserAccountDto userDto = userAccountBean.findByEmail(loggedInEmail);

            if (userDto == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "User account data missing.");
                return;
            }

            // 3. ACTION DISPATCHER
            if ("update_bio".equals(action)) {

                String newBiography = request.getParameter("biography");

                // Data Cleaning and Validation for Biography (Max 255 chars)
                if (newBiography != null) {
                    newBiography = newBiography.trim();
                    if (newBiography.length() > 255) {
                        newBiography = newBiography.substring(0, 255);
                    }
                } else {
                    newBiography = "";
                }

                // Call EJB method with ALL fields
                studentInfoBean.updateStudent(
                        studentDto.getId(),
                        studentDto.getFirstName(),
                        studentDto.getMiddleName(),
                        studentDto.getLastName(),
                        studentDto.getStudyYear(),
                        studentDto.getLastYearGrade(),
                        studentDto.getStatus(),
                        studentDto.getEnrolled(),
                        newBiography
                );

                // 4. Log the Activity (NEW)
                activityBean.logActivity(
                        userDto.getUserId(),
                        AccountActivity.Action.UpdateBiography, // USING the new enum value
                        "Updated profile biography." // Dynamic data, or null/fixed string
                );

                response.sendRedirect(request.getContextPath() + "/StudentProfile?update=bio_success");

            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unrecognized profile update action: " + action);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Profile update failed.");
        }
    }
}