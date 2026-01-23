package org.interndb.internshipapplication;

import com.internshipapp.common.*;
import com.internshipapp.config.ApplicationPeriodService;
import com.internshipapp.ejb.*;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   4. Redirect to render the facultyPanel.jsp
 **********************************************************/
@WebServlet(name = "FacultyDashboardServlet", value = "/FacultyDashboard")
public class FacultyDashboardServlet extends HttpServlet {
    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    UserAccountBean userAccountBean;

    @Inject
    StudentInfoBean studentInfoBean;

    @Inject
    AccountActivityBean activityBean;

    @Inject
    CompanyInfoBean companyInfoBean;

    @Inject
    InternshipPositionBean positionBean;

    @Inject
    InternshipApplicationBean applicationBean;

    @Inject
    ApplicationPeriodService periodService;

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

        // Session & Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        // Ensure only Faculty can access this dashboard
        if (!"Faculty".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return;
        }

        try {
            // Fetch Faculty Account Data (Contains companyId link)
            UserAccountDto userDto = userAccountBean.findByEmail(email);

            // Fetch Department Info via the linked ID
            CompanyInfoDto facultyDeptDto = null;
            if (userDto.getCompanyId() != null) {
                facultyDeptDto = companyInfoBean.findById(userDto.getCompanyId());
            }

            // Fetch Data for Faculty Panel
            List<AccountActivityDto> activities = activityBean.findActivitiesByUserId(userDto.getUserId());

            // All students for the central roster
            List<StudentInfoDto> allStudents = studentInfoBean.findAllStudents();

            // Tutoring Positions linked to this Faculty's Department ID
            List<InternshipPositionDto> tutoringPositions = null;
            if (facultyDeptDto != null) {
                tutoringPositions = positionBean.findByCompanyId(facultyDeptDto.getId());

                // Hydrate each position with its candidates list
                if (tutoringPositions != null) {
                    for (InternshipPositionDto pos : tutoringPositions) {
                        pos.setApplicants(applicationBean.getApplicantsForPosition(pos.getId()));
                    }
                }
            }
            boolean isPostingAllowed = periodService.isPostingAllowed();
            String postingDeadline = periodService.getFormattedCutoffDate();

            String errorParam = request.getParameter("error");
            boolean showPostingError = "posting_closed".equals(errorParam);

            request.setAttribute("isPostingAllowed", isPostingAllowed);
            request.setAttribute("postingDeadline", postingDeadline);
            request.setAttribute("showPostingError", showPostingError);

            // Set Attributes for JSP
            request.setAttribute("userAccount", userDto);
            request.setAttribute("facultyDept", facultyDeptDto);
            request.setAttribute("allStudents", allStudents);
            request.setAttribute("tutoringPositions", tutoringPositions);
            request.setAttribute("activities", activities);

            // Forward to the facultyPanel JSP
            request.getRequestDispatcher("/pages/panels/facultyPanel.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading faculty dashboard.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}