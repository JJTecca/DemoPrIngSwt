package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.ejb.StudentInfoBean;
import com.internshipapp.ejb.UserAccountBean;
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
}