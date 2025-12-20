package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.AttachmentBean;
import com.internshipapp.ejb.UserAccountBean;

import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "DeleteProfilePictureServlet", value = "/DeleteProfilePicture")
public class DeleteProfilePictureServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(DeleteProfilePictureServlet.class.getName());

    @Inject
    private AttachmentBean attachmentBean;
    @Inject
    private UserAccountBean userAccountBean;
    @Inject
    private AccountActivityBean activityBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        if (email == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        // UPDATED: Redirect Faculty to CompanyProfile (Department view)
        String redirectUrl = (role.equals("Company") || role.equals("Faculty")) ? "/CompanyProfile" : "/StudentProfile";

        try {
            Long profileId = null;

            // --- Determine Profile ID and call correct EJB method ---
            if ("Student".equals(role)) {
                StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
                if (student != null) {
                    profileId = student.getId();
                    attachmentBean.deletePfpForStudent(profileId);
                }
            }
            // UPDATED: Allowed Faculty to follow the Company/Department logic path
            else if ("Company".equals(role) || "Faculty".equals(role)) {
                CompanyInfoDto company = userAccountBean.getCompanyInfoByEmail(email);
                if (company != null) {
                    profileId = company.getId();
                    attachmentBean.deletePfpForCompany(profileId);
                }
            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Role not authorized for PFP deletion.");
                return;
            }

            if (profileId == null) {
                LOG.warning("Profile ID not found for email: " + email);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Profile ID not found.");
                return;
            }

            // --- Log Activity (Layer-Safe using String key) ---
            UserAccountDto user = userAccountBean.findByEmail(email);
            if (user != null) {
                activityBean.logActivity(user.getUserId(), "DeletePFP", "Deleted Profile Picture.");
            }

            response.sendRedirect(request.getContextPath() + redirectUrl + "?t=" + System.currentTimeMillis());

        } catch (Exception e) {
            LOG.severe("Failed to delete profile picture: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to delete profile picture.");
        }
    }
}