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
            request.getRequestDispatcher("/pages/blocks/requestInterview.jsp").forward(request, response);

        } catch (Exception e) {
            LOG.severe("Error loading student users: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading student list: " + e.getMessage());
            request.getRequestDispatcher("/pages/company/companyPanel.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get parameters
        String studentUserIdStr = request.getParameter("studentUserId");
        String positionIdStr = request.getParameter("positionId");
        String studentEmail = request.getParameter("studentEmail");

        // Get company info from session
        Long companyId = (Long) request.getSession().getAttribute("companyId");
        String userEmail = (String) request.getSession().getAttribute("userEmail");

        LOG.info("Attempting to request interview for student email: " + studentEmail);

        try {
            Long studentUserId = Long.parseLong(studentUserIdStr);
            Long positionId = Long.parseLong(positionIdStr);

            LOG.info("Interview requested for student User ID: " + studentUserId +
                    " by company ID: " + companyId +
                    " for position ID: " + positionId);

            // IMPORTANT: We need to get the StudentInfo ID from the UserAccount
            var studentUser = userAccountBean.findByEmail(studentEmail);
            if (studentUser == null || studentUser.getStudentId() == null) {
                throw new ServletException("Student info not found");
            }

            Long studentId = studentUser.getStudentId();

            // Check if application already exists
            var existingApp = internshipApplicationBean.findApplication(studentId, positionId);
            if (existingApp != null) {
                // If exists, just update status to Interview
                internshipApplicationBean.updateApplicationStatus(existingApp.getId(), "Interview");
                request.setAttribute("successMessage",
                        "Interview request updated for " + studentEmail);
            } else {
                try {
                    // Create new internship application with "Interview" status
                    String positionTitle = internshipApplicationBean.createApplication(studentId, positionId);

                    // Immediately update status to "Interview"
                    var application = internshipApplicationBean.findApplication(studentId, positionId);
                    if (application != null) {
                        internshipApplicationBean.updateApplicationStatus(application.getId(), "Interview");
                    }

                    request.setAttribute("successMessage",
                            "Interview request sent to " + studentEmail +
                                    " for position: " + positionTitle);
                } catch (IllegalStateException e) {
                    // Student is already Accepted elsewhere
                    LOG.warning("Cannot send interview request: " + e.getMessage());
                    request.setAttribute("errorMessage",
                            "Cannot send interview request to " + studentEmail +
                                    " because they are already accepted in another internship.");

                    // Forward back to student list with error message
                    doGet(request, response);
                    return;
                }
            }

            // Forward back to student list
            doGet(request, response);

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid student or position ID");
            doGet(request, response);
        } catch (Exception e) {
            LOG.severe("Error requesting interview: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to send interview request: " + e.getMessage());
            doGet(request, response);
        }
    }
}