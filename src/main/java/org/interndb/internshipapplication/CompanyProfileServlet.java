package org.interndb.internshipapplication;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.CompanyInfoBean;
import com.internshipapp.ejb.InternshipPositionBean;
import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.entities.AccountActivity;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet(name = "CompanyProfileServlet", value = "/CompanyProfile")
public class CompanyProfileServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(CompanyProfileServlet.class.getName());

    @Inject
    CompanyInfoBean companyInfoBean;

    @Inject
    InternshipPositionBean positionBean;

    @Inject
    UserAccountBean userAccountBean;

    @Inject
    AccountActivityBean activityBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        String idParam = request.getParameter("id");
        CompanyInfoDto company = null;

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // SCENARIO A: Viewing a specific company
                Long companyId = Long.parseLong(idParam);
                company = companyInfoBean.findById(companyId);

            } else {
                // SCENARIO B: Viewing "My Profile"
                if ("Company".equals(role)) {
                    company = companyInfoBean.findByUserEmail(loggedInEmail);
                } else {
                    response.sendRedirect("Students");
                    return;
                }
            }

            if (company == null) {
                // Critical data error: profile expected but not found
                request.setAttribute("errorMessage", "Company profile data could not be loaded. This is a system error. Please contact administration.");
                request.getRequestDispatcher("/pages/error.jsp").forward(request, response);
                return;
            }

            List<InternshipPositionDto> positions = positionBean.findByCompanyId(company.getId());

            request.setAttribute("company", company);
            request.setAttribute("myPositions", positions);

            request.getRequestDispatcher("/pages/public/companyProfile.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Company ID");
        } catch (Exception e) {
            LOG.severe("Error in CompanyProfileServlet doGet: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading profile");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");

        // 1. SECURITY CHECK
        if (loggedInEmail == null || !"Company".equals(role) || action == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied or missing action parameter.");
            return;
        }

        try {
            // Fetch ALL existing data to pass back to the bulk update EJB method
            CompanyInfoDto companyDto = companyInfoBean.findByUserEmail(loggedInEmail);
            UserAccountDto userDto = userAccountBean.findByEmail(loggedInEmail);

            if (companyDto == null || userDto == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Company or User profile not found.");
                return;
            }

            // --- Initialization for Bulk Update ---
            // These variables hold the current (old) values, and will be updated
            // only if the corresponding action is triggered.
            String finalName = companyDto.getName();
            String finalShortName = companyDto.getShortName();
            String finalWebsite = companyDto.getWebsite();
            String finalCompDescription = companyDto.getCompDescription();
            String finalOpenedPositions = companyDto.getOpenedPositions();
            String finalStudentsApplied = companyDto.getStudentsApplied();
            String finalBiography = companyDto.getBiography();

            AccountActivity.Action logAction = null;
            String logDetails = "";


            // 2. ACTION DISPATCHER & DATA CLEANING/MAPPING
            if ("update_biography".equals(action)) {

                String newBiography = request.getParameter("biography");

                // Validation and Cleaning (Max 255 chars)
                if (newBiography != null) {
                    newBiography = newBiography.trim();
                    if (newBiography.length() > 255) {
                        newBiography = newBiography.substring(0, 255);
                    }
                } else {
                    newBiography = "";
                }

                finalBiography = newBiography;

                logAction = AccountActivity.Action.UpdateBiography;
                logDetails = "Updated profile biography.";

            } else if ("update_description".equals(action)) {

                String newCompDescription = request.getParameter("compDescription");

                // Validation and Cleaning (Max 50 chars)
                if (newCompDescription != null) {
                    newCompDescription = newCompDescription.trim();
                    if (newCompDescription.length() > 50) {
                        newCompDescription = newCompDescription.substring(0, 50);
                    }
                } else {
                    newCompDescription = "";
                }

                finalCompDescription = newCompDescription;

                logAction = AccountActivity.Action.UpdateDescription;
                logDetails = "Updated company short description.";

            } else if ("update_website".equals(action)) {

                String newWebsite = request.getParameter("website");

                // Validation and Cleaning (Max 510 chars as per entity definition)
                if (newWebsite != null) {
                    newWebsite = newWebsite.trim();
                    if (newWebsite.length() > 510) {
                        newWebsite = newWebsite.substring(0, 510);
                    }
                } else {
                    newWebsite = "";
                }

                finalWebsite = newWebsite;

                // LOGGING THE NEW ACTION
                logAction = AccountActivity.Action.UpdateWebsiteURL; // USING THE NEW ENUM
                logDetails = "Updated company website URL.";

            } else if ("update_shortname".equals(action)) {
                String newShortName = request.getParameter("shortName");

                // Validation: Usually short names are brief (e.g., "ULBS" or "Google")
                if (newShortName != null) {
                    newShortName = newShortName.trim();
                    // Enforce the new 10-character limit
                    if (newShortName.length() > 10) {
                        newShortName = newShortName.substring(0, 10);
                    }
                } else {
                    newShortName = "N/A";
                }
                finalShortName = newShortName;

                logAction = AccountActivity.Action.UpdateShortName; // USING THE NEW ENUM
                logDetails = "Updated company short name.";

            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unrecognized company update action: " + action);
                return;
            }

            // 3. BULK EJB CALL: Pass ALL fields (updated field + current/unchanged fields)
            //
            companyInfoBean.updateCompany(
                    companyDto.getId(),
                    finalName,
                    finalShortName,
                    finalWebsite, // Pass finalWebsite
                    finalCompDescription,
                    finalOpenedPositions,
                    finalStudentsApplied,
                    finalBiography
            );

            // 4. LOG ACTIVITY
            if (logAction != null) {
                activityBean.logActivity(userDto.getUserId(), logAction, logDetails);
            }

            response.sendRedirect(request.getContextPath() + "/CompanyProfile?update=success");

        } catch (Exception e) {
            LOG.severe("Error in CompanyProfileServlet doPost: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Company profile update failed.");
        }
    }
}