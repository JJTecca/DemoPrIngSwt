package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.entities.AccountActivity;
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
            Long positionId = Long.parseLong(request.getParameter("positionId"));

            // Get the Student ID linked to this email
            StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
            UserAccountDto user = userAccountBean.findByEmail(email);

            if (student != null) {
                // 3. Create Application in Bean
                // We make this method return the Position Title so we can log it nicely
                String positionTitle = applicationBean.createApplication(student.getId(), positionId);

                // 4. Log Activity with Title
                if (user != null && positionTitle != null) {
                    activityBean.logActivity(
                            user.getUserId(),
                            AccountActivity.Action.AppliedForPosition,
                            positionTitle // "Java Dev @ Google" stored in newData
                    );
                }

                // Success: Back to the list with a success flag
                response.sendRedirect("InternshipPositions?success=true");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Student profile not found.");
            }

        } catch (IllegalStateException e) {
            // Handle case where they already applied (Duplicate)
            response.sendRedirect("InternshipPositions?error=already_applied");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Application failed.");
        }
    }
}