package org.interndb.internshipapplication;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.CompanyInfoBean;
import com.internshipapp.ejb.InternshipPositionBean;
import com.internshipapp.ejb.UserAccountBean;
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
                }
                // ADDED: Condition for Faculty Role
                else if ("Faculty".equals(role)) {
                    UserAccountDto user = userAccountBean.findByEmail(loggedInEmail);
                    if (user != null && user.getCompanyId() != null) {
                        company = companyInfoBean.findById(user.getCompanyId());
                    } else {
                        company = companyInfoBean.findByUserEmail(loggedInEmail);
                    }
                }
                else {
                    response.sendRedirect(request.getContextPath() + "/StudentDashboard");
                    return;
                }
            }

            if (company == null) {
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

        if (loggedInEmail == null || action == null || (!"Company".equals(role) && !"Faculty".equals(role))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied or missing action parameter.");
            return;
        }

        try {
            UserAccountDto userDto = userAccountBean.findByEmail(loggedInEmail);
            CompanyInfoDto companyDto = null;

            if (userDto != null && userDto.getCompanyId() != null) {
                companyDto = companyInfoBean.findById(userDto.getCompanyId());
            } else {
                companyDto = companyInfoBean.findByUserEmail(loggedInEmail);
            }

            if (companyDto == null || userDto == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Company or User profile not found.");
                return;
            }

            // --- Initialization for Bulk Update ---
            String finalName = companyDto.getName();
            String finalShortName = companyDto.getShortName();
            String finalWebsite = companyDto.getWebsite();
            String finalCompDescription = companyDto.getCompDescription();
            String finalOpenedPositions = companyDto.getOpenedPositions();
            String finalStudentsApplied = companyDto.getStudentsApplied();
            String finalBiography = companyDto.getBiography();
            String finalContactEmail = companyDto.getContactEmail();

            // FIX: Use String keys instead of Entity Enums
            String logActionKey = null;
            String logDetails = "";

            if ("update_biography".equals(action)) {
                String newBiography = request.getParameter("biography");
                if (newBiography != null) {
                    newBiography = newBiography.trim();
                    if (newBiography.length() > 255) {
                        newBiography = newBiography.substring(0, 255);
                    }
                } else {
                    newBiography = "";
                }
                finalBiography = newBiography;
                logActionKey = "UpdateBiography";
                logDetails = "Updated profile biography.";

            } else if ("update_description".equals(action)) {
                String newCompDescription = request.getParameter("compDescription");
                if (newCompDescription != null) {
                    newCompDescription = newCompDescription.trim();
                    if (newCompDescription.length() > 50) {
                        newCompDescription = newCompDescription.substring(0, 50);
                    }
                } else {
                    newCompDescription = "";
                }
                finalCompDescription = newCompDescription;
                logActionKey = "UpdateDescription";
                logDetails = "Updated short description.";

            } else if ("update_website".equals(action)) {
                String newWebsite = request.getParameter("website");
                if (newWebsite != null) {
                    newWebsite = newWebsite.trim();
                    if (newWebsite.length() > 510) {
                        newWebsite = newWebsite.substring(0, 510);
                    }
                } else {
                    newWebsite = "";
                }
                finalWebsite = newWebsite;
                logActionKey = "UpdateWebsiteURL";
                logDetails = "Updated website URL.";

            } else if ("update_shortname".equals(action)) {
                String newShortName = request.getParameter("shortName");
                if (newShortName != null) {
                    newShortName = newShortName.trim();
                    if (newShortName.length() > 10) {
                        newShortName = newShortName.substring(0, 10);
                    }
                } else {
                    newShortName = "N/A";
                }
                finalShortName = newShortName;
                logActionKey = "UpdateShortName";
                logDetails = "Updated short name.";

            } else if ("update_contact_email".equals(action)) {
                String newContactEmail = request.getParameter("contactEmail");
                if (newContactEmail != null) {
                    newContactEmail = newContactEmail.trim();
                    if (newContactEmail.length() > 255) {
                        newContactEmail = newContactEmail.substring(0, 255);
                    }
                } else {
                    newContactEmail = "";
                }
                finalContactEmail = newContactEmail;
                logActionKey = "UpdateContactEmail";
                logDetails = "Updated contact email.";

            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unrecognized action: " + action);
                return;
            }

            companyInfoBean.updateCompany(
                    companyDto.getId(),
                    finalName,
                    finalShortName,
                    finalWebsite,
                    finalCompDescription,
                    finalOpenedPositions,
                    finalStudentsApplied,
                    finalBiography,
                    finalContactEmail
            );

            // 4. LOG ACTIVITY (Layer-Safe Call using the new String overload)
            if (logActionKey != null) {
                activityBean.logActivity(userDto.getUserId(), logActionKey, logDetails);
            }

            response.sendRedirect(request.getContextPath() + "/CompanyProfile?update=success");

        } catch (Exception e) {
            LOG.severe("Error in CompanyProfileServlet doPost: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Profile update failed.");
        }
    }
}