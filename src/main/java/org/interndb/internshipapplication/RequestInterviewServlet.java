package org.interndb.internshipapplication;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.*;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet(name = "RequestInterviewServlet", value = "/RequestInterview")
public class RequestInterviewServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(RequestInterviewServlet.class.getName());

    @Inject
    private UserAccountBean userAccountBean;

    @Inject
    private InternshipApplicationBean internshipApplicationBean;

    @Inject
    private InternshipPositionBean internshipPositionBean;

    @Inject
    private MessageBean messageBean;

    private boolean checkAuth(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return false;
        }
        String role = (String) session.getAttribute("userRole");
        if (!"Company".equals(role) && !"Faculty".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Insufficient Permissions");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!checkAuth(request, response)) return;

        try {
            HttpSession session = request.getSession();
            // 1. Get all student users (NO FILTERING - show everyone)
            List<StudentInfoDto> students = userAccountBean.getAllAvailableStudents();

            // 2. Get company's positions (from session companyId)
            Long companyId = (Long) request.getSession().getAttribute("companyId");
            String userEmail = (String) session.getAttribute("userEmail");
            CompanyInfoDto companyDto = userAccountBean.getCompanyInfoByEmail(userEmail);

            var companyPositions = internshipPositionBean.findByCompanyId(companyId);
            // Map studentUserId -> List of their Applications for THIS company
            // This prevents the JSP from having to do complex logic
            Map<Long, List<InternshipApplicationDto>> studentAppsMap = new HashMap<>();
            List<InternshipApplicationDto> companyApps = internshipApplicationBean.findApplicationsByCompanyId(companyId);

            for (StudentInfoDto student : students) {
                // Filter apps where the student internal ID matches
                List<InternshipApplicationDto> filteredApps = companyApps.stream()
                        .filter(a -> a.getStudentId().equals(student.getId()))
                        .collect(Collectors.toList());

                // IMPORTANT FIX: Use getUserId() as the key to match the JSP's JS call
                if (student.getUserId() != null) {
                    studentAppsMap.put(student.getUserId(), filteredApps);
                }
            }

            // Set attributes for JSP - use ALL students
            request.setAttribute("studentUsers", students);
            request.setAttribute("companyPositions", companyPositions);
            request.setAttribute("company", companyDto);
            request.setAttribute("studentAppsMap", studentAppsMap);
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
        String message = request.getParameter("message");

        HttpSession session = request.getSession();
        Long senderUserId = (Long) session.getAttribute("userId");
        String role = (String) session.getAttribute("userRole");

        try {
            Long studentUserId = Long.parseLong(studentUserIdStr);
            Long positionId = Long.parseLong(positionIdStr);

            // Fetch student info to get the internal studentId
            var studentUser = userAccountBean.getUserById(studentUserId);

            // Check for an existing application for this specific position
            var existingApp = internshipApplicationBean.findApplication(studentUser.getStudentId(), positionId);

            if (existingApp == null) {
                // SCENARIO 1: Brand New Interaction -> Formal Request
                internshipApplicationBean.initiateInterviewRequest(studentUser.getStudentId(), positionId, message, senderUserId);
                request.setAttribute("successMessage", "Interview request sent successfully.");
            }
            else if ("Pending".equals(existingApp.getStatus().toString())) {
                // SCENARIO 2: Student applied, Company is responding -> Initiate Chat
                // This triggers your MessageBean logic (Status -> Discussion)
                messageBean.sendMessage(existingApp.getId(), senderUserId, message, role);
                response.sendRedirect("InternshipApplications?id=" + existingApp.getId());
                return;
            }
            else {
                // SCENARIO 3: Already in Discussion/Interview -> Just go to Chat
                response.sendRedirect("InternshipApplications?id=" + existingApp.getId());
                return;
            }

        } catch (Exception e) {
            LOG.severe("Error processing interaction: " + e.getMessage());
            request.setAttribute("errorMessage", "Action failed: " + e.getMessage());
        }

        doGet(request, response);
    }
}