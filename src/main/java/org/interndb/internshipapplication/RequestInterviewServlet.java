package org.interndb.internshipapplication;

import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.InternshipPositionBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "RequestInterviewServlet", value = "/RequestInterview")
public class RequestInterviewServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(RequestInterviewServlet.class.getName());

    @Inject
    private UserAccountBean userAccountBean;

    @Inject
    private InternshipApplicationBean internshipApplicationBean;

    @Inject
    private InternshipPositionBean internshipPositionBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1. Get all student users (NO FILTERING - show everyone)
            var allStudentUsers = userAccountBean.getAllStudentUsers();

            // 2. Get company's positions (from session companyId)
            Long companyId = (Long) request.getSession().getAttribute("companyId");
            var companyPositions = internshipPositionBean.findByCompanyId(companyId);

            // Set attributes for JSP - use ALL students
            request.setAttribute("studentUsers", allStudentUsers);
            request.setAttribute("companyPositions", companyPositions);
            request.setAttribute("pageTitle", "Request Interview - Student List");

            // Forward to JSP
            request.getRequestDispatcher("/pages/social/requestInterview.jsp").forward(request, response);

        } catch (Exception e) {
            LOG.severe("Error loading student users: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading student list: " + e.getMessage());
            request.getRequestDispatcher("/pages/panels/companyPanel.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String studentUserIdStr = request.getParameter("studentUserId");
        String positionIdStr = request.getParameter("positionId");
        String message = request.getParameter("message"); // Capturing from the new textarea

        Long senderUserId = (Long) request.getSession().getAttribute("userId");

        try {
            Long studentUserId = Long.parseLong(studentUserIdStr);
            Long positionId = Long.parseLong(positionIdStr);

            // Get student info using the helper we just built
            var studentUser = userAccountBean.getUserById(studentUserId);
            if (studentUser == null || studentUser.getStudentId() == null) {
                throw new ServletException("Student profile is incomplete.");
            }

            // Execute Request logic
            internshipApplicationBean.initiateInterviewRequest(studentUser.getStudentId(), positionId, message, senderUserId);

            request.setAttribute("successMessage", "Interview request sent successfully to " + studentUser.getUsername());

        } catch (Exception e) {
            LOG.severe("Error in RequestInterview: " + e.getMessage());
            request.setAttribute("errorMessage", "Failed to send request: " + e.getMessage());
        }

        // Refresh the list
        doGet(request, response);
    }
}