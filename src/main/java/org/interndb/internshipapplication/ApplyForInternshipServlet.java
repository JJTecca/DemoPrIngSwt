package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.UserAccountBean;

import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "ApplyForInternshipServlet", value = "/ApplyForInternship")
public class ApplyForInternshipServlet extends HttpServlet {

    @Inject
    private InternshipApplicationBean applicationBean;

    @Inject
    private UserAccountBean userAccountBean;

    @Inject
    private AccountActivityBean activityBean;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        // 1. Security: Only Students can apply
        if (!"Student".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only students can apply.");
            return;
        }

        try {
            // 2. Get Data
            String posIdStr = request.getParameter("positionId");
            if (posIdStr == null || posIdStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing Position ID");
                return;
            }
            Long positionId = Long.parseLong(posIdStr);

            // Get the Student ID and User Account linked to this email
            StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
            UserAccountDto user = userAccountBean.findByEmail(email);

            if (student != null) {
                String positionTitle = applicationBean.createApplication(student.getId(), positionId);

                if (user != null && positionTitle != null) {
                    activityBean.logActivity(
                            user.getUserId(),
                            "AppliedForPosition",
                            positionTitle // Details stored in newData
                    );
                }

                // Success: Back to the list with a success flag
                response.sendRedirect(request.getContextPath() + "/InternshipPositions?success=true");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Student profile not found.");
            }

        } catch (IllegalStateException e) {
            // Handle case where they already applied (Duplicate)
            response.sendRedirect(request.getContextPath() + "/InternshipPositions?error=already_applied");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Application failed.");
        }
    }
}