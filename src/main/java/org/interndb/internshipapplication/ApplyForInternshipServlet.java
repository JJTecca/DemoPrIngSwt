package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.InternshipPositionBean;
import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.config.ApplicationPeriodService;

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

    @Inject
    private ApplicationPeriodService applicationPeriodService;

    @Inject
    private InternshipPositionBean positionBean;

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
            applicationPeriodService.validateApplicationPeriod();

            // 2. Get Data
            String posIdStr = request.getParameter("positionId");
            if (posIdStr == null || posIdStr.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing Position ID");
                return;
            }
            Long positionId = Long.parseLong(posIdStr);

            StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
            UserAccountDto user = userAccountBean.findByEmail(email);

            if (student != null) {
                applicationBean.createApplication(student.getId(), positionId);
                String positionTitle = positionBean.findById(positionId).getTitle();

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
            String errorMessage = e.getMessage();
            if (errorMessage.contains("already applied")) {
                response.sendRedirect(request.getContextPath() + "/InternshipPositions?error=already_applied");
            } else if (errorMessage.contains("Applications") || errorMessage.contains("period")) {
                // Period-related error
                response.sendRedirect(request.getContextPath() + "/InternshipPositions?error=period_closed");
            } else {
                response.sendRedirect(request.getContextPath() + "/InternshipPositions?error=" +
                        java.net.URLEncoder.encode(errorMessage, "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Application failed.");
        }
    }
}