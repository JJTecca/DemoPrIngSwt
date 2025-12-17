package org.interndb.internshipapplication;

import com.internshipapp.common.FileDto;
import com.internshipapp.ejb.AttachmentBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "ProfilePictureServlet", value = "/ProfilePicture")
public class ProfilePictureServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(ProfilePictureServlet.class.getName());

    @Inject
    private AttachmentBean attachmentBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String targetRoleParam = request.getParameter("targetRole"); // NEW: Required for bug-proof lookup
        HttpSession session = request.getSession(false);

        // 1. Basic Parameter Checks
        if (idParam == null || targetRoleParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing profile ID or target role.");
            return;
        }

        // 2. Authentication Check (Must be logged in to view any profile picture)
        if (session == null || session.getAttribute("userRole") == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Authentication required to view this resource.");
            return;
        }

        try {
            Long profileId = Long.parseLong(idParam);
            FileDto file = null;

            // --- BUG-PROOF DISPATCH using Target Role ---
            if ("Student".equalsIgnoreCase(targetRoleParam)) {
                // Guaranteed to look only in Student-related tables
                file = attachmentBean.getPfpForStudent(profileId);
            } else if ("Company".equalsIgnoreCase(targetRoleParam)) {
                // Guaranteed to look only in Company-related tables
                file = attachmentBean.getPfpForCompany(profileId);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid target role specified.");
                return;
            }
            // ---------------------------------------------

            if (file != null && file.getFileData() != null) {
                response.setContentType(file.getContentType());
                response.setContentLength(file.getFileData().length);
                response.setHeader("Cache-Control", "max-age=3600");
                response.getOutputStream().write(file.getFileData());
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Profile picture not found for ID/Role: " + profileId + "/" + targetRoleParam);
            }
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid profile ID format.");
        } catch (Exception e) {
            LOG.severe("Error fetching profile picture: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}