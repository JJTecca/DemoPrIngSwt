package org.interndb.internshipapplication;

import com.internshipapp.common.*;
import com.internshipapp.config.ApplicationPeriodService;
import com.internshipapp.ejb.*;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   4. Redirect to render the companyPanel.jsp
 **********************************************************/
@WebServlet(name = "CompanyDashboardServlet", value = "/CompanyDashboard")
public class CompanyDashboardServlet extends HttpServlet {
    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    UserAccountBean userAccountBean;

    @Inject
    CompanyInfoBean companyDtoInfoBean;

    @Inject
    InternshipPositionBean positionBean;

    @Inject
    InternshipApplicationBean applicationBean;

    @Inject
    AccountActivityBean accountActivityBean;

    @Inject
    ApplicationPeriodService periodService;

    /******************************************************************
     * @param request an {@link HttpServletRequest}
     * @param response an {@link HttpServletResponse}
     * doGet functions implementation to retrieve data from the server
     * Display a webpage or form
     * doPost to handle form submissions : Insert, update, or delete data
     *****************************************************************/

    public boolean checkAuth(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws ServletException, IOException {
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return true;
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session & Security Check
        HttpSession session = request.getSession(false);
        if (checkAuth(request, response, session)) { return; }

        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        // Ensure only Companies access this page
        if (!"Company".equals(role)) {
            // If an Admin or Student tries to access, kick them out
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return;
        }

        try {
            // 2. Fetch User Account & Company Profile
            UserAccountDto userDto = userAccountBean.findByEmail(email);

            // You need to implement this method in CompanyInfoBean
            // It should find the CompanyInfo entity linked to the UserAccount email
            CompanyInfoDto companyDto = companyDtoInfoBean.findByUserEmail(email);
            CompanyInfoDto facultyProfile = companyDtoInfoBean.findFacultyProfile();
            if (facultyProfile != null) {
                request.setAttribute("facultyId", facultyProfile.getId());
            }

            if (companyDto == null) {
                // Handle case where account exists but CompanyInfo is missing
                request.setAttribute("errorMessage", "Company profile not found.");
                request.getRequestDispatcher("/pages/error.jsp").forward(request, response);
                return;
            }

            // 3. Fetch Data for Dashboard

            // A. Activities (Recent logs for this user)
            List<AccountActivityDto> activities = accountActivityBean.findActivitiesByUserId(userDto.getUserId());

            // B. Posted Positions
            // You need to implement this in InternshipPositionBean: findByCompanyId(Long companyId)
            List<InternshipPositionDto> myPositions = positionBean.findByCompanyId(companyDto.getId());

            if (myPositions != null) {
                for (InternshipPositionDto pos : myPositions) {
                    List<InternshipApplicationDto> applicants = applicationBean.getApplicantsForPosition(pos.getId());
                    pos.setApplicants(applicants);
                }
            }

            // C. Received Applications
            // You need to implement this in InternshipApplicationBean: findApplicationsByCompanyId(Long companyId)
            // This method must join Application -> Position -> Company to filter correctly
            List<InternshipApplicationDto> applications = applicationBean.findApplicationsByCompanyId(companyDto.getId());
            Long activeChats = 0L;
            for (InternshipApplicationDto app : applications){
                if (app.isChatInitiated() && (app.getStatus().equals("Discussion") || app.getStatus().equals("Interview"))){
                    activeChats++;
                }
            }

            boolean isPostingAllowed = periodService.isPostingAllowed();

            String postingDeadline = periodService.getFormattedCutoffDate();

            request.setAttribute("isPostingAllowed", isPostingAllowed);
            request.setAttribute("postingDeadline", postingDeadline);

            // Check for error flag
            String errorParam = request.getParameter("error");
            boolean showPostingError = "posting_closed".equals(errorParam);
            request.setAttribute("showPostingError", showPostingError);

            // 4. Set Attributes for JSP
            request.setAttribute("userAccount", userDto);
            request.setAttribute("company", companyDto);
            request.setAttribute("activities", activities);
            request.setAttribute("myPositions", myPositions);
            request.setAttribute("activeChats", activeChats);
            request.setAttribute("applications", applications);

            // 5. Forward to JSP
            request.getRequestDispatcher("/pages/panels/companyPanel.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading company dashboard.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (checkAuth(request, response, session)) { return; }

        String email = (String) session.getAttribute("userEmail");
        String phoneNumber = request.getParameter("phoneNumber");

        // 2. Logic: If a phone number was submitted via the modal
        if (phoneNumber != null) {
            // Strict Romanian Validation: 02, 03, or 07 followed by 8 digits
            if (phoneNumber.matches("^(02|03|07)\\d{8}$")) {
                CompanyInfoDto company = companyDtoInfoBean.findByUserEmail(email);

                if (company != null) {
                    // Call the monolith update method, keeping all other fields as they are
                    companyDtoInfoBean.updateCompany(
                            company.getId(),
                            company.getName(),
                            company.getShortName(),
                            company.getWebsite(),
                            company.getCompDescription(),
                            company.getOpenedPositions(),
                            company.getStudentsApplied(),
                            company.getBiography(),
                            company.getContactEmail(),
                            phoneNumber
                    );
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/CompanyDashboard");
    }
}