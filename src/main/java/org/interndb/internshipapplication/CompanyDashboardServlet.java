package org.interndb.internshipapplication;

import com.internshipapp.common.*;
import com.internshipapp.ejb.*;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CompanyDashboardServlet", value = "/CompanyDashboard")
public class CompanyDashboardServlet extends HttpServlet {

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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session & Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

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

            // C. Received Applications
            // You need to implement this in InternshipApplicationBean: findApplicationsByCompanyId(Long companyId)
            // This method must join Application -> Position -> Company to filter correctly
            List<InternshipApplicationDto> applications = applicationBean.findApplicationsByCompanyId(companyDto.getId());

            // 4. Set Attributes for JSP
            request.setAttribute("userAccount", userDto);
            request.setAttribute("company", companyDto);
            request.setAttribute("activities", activities);
            request.setAttribute("myPositions", myPositions);
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
        doGet(request, response);
    }
}