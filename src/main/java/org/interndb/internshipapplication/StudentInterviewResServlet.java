package org.interndb.internshipapplication;

import com.internshipapp.ejb.InternshipApplicationBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "StudentInterviewResServlet", value = "/StudentInterviewResponse")
public class StudentInterviewResServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(StudentInterviewResServlet.class.getName());

    @Inject
    private InternshipApplicationBean internshipApplicationBean;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String applicationIdStr = request.getParameter("applicationId");
        String responseAction = request.getParameter("response"); // "accept" or "reject"

        try {
            Long applicationId = Long.parseLong(applicationIdStr);

            // Get the current user ID from session to ensure authorization
            Long studentId = (Long) request.getSession().getAttribute("studentId");

            if (studentId == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"Not authorized\"}");
                return;
            }

            // Verify the application belongs to this student
            var applicationDto = internshipApplicationBean.getApplicationDtoById(applicationId);
            if (applicationDto == null || !applicationDto.getStudentId().equals(studentId)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"Application not found or access denied\"}");
                return;
            }

            // Verify current status is "Interview"
            if (!"Interview".equals(applicationDto.getStatus())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Application is not in interview status\"}");
                return;
            }

            // Update status based on student's response
            String newStatus = "accept".equalsIgnoreCase(responseAction) ? "Accepted" : "Rejected";

            // Use existing update method
            internshipApplicationBean.updateApplicationStatus(applicationId, newStatus);

            LOG.info("Student " + studentId + " " + responseAction + "ed interview for application " + applicationId);

            // Return success response
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": true, \"message\": \"Interview " + responseAction + "ed successfully\"}");

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"success\": false, \"message\": \"Invalid application ID\"}");
        } catch (Exception e) {
            LOG.severe("Error processing interview response: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error: " + e.getMessage() + "\"}");
        }
    }
}