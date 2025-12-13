package org.interndb.internshipapplication;

import com.internshipapp.ejb.RequestBean;
import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "TokenApprovalServlet", value = "/TokenApproval")
public class TokenApprovalServlet extends HttpServlet {

    @PersistenceContext
    private EntityManager entityManager;

    @Inject
    private RequestBean requestBean;

    @Inject
    private UserAccountBean userAccountBean;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null ||
                !"Admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");

        if (action == null || idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing parameters");
            return;
        }

        try {
            Long requestId = Long.parseLong(idParam);

            if ("approve".equals(action)) {
                // Get the FULL request entity (not just DTO) to access password
                com.internshipapp.entities.Request requestEntity =
                        entityManager.find(com.internshipapp.entities.Request.class, requestId);

                if (requestEntity == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Request not found");
                    return;
                }
                // Use the ACTUAL password, not the token
                String actualPassword = requestEntity.getPassword();

                // Create company user account with ACTUAL password
                userAccountBean.createCompanyUserFromRequest(
                        requestEntity.getCompanyName(),
                        requestEntity.getCompanyEmail(),
                        actualPassword  // This should be "10Cristi2025"
                );

                //Approve the request
                boolean approved = requestBean.approveRequest(requestId);

                if (approved) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Request approved and company account created successfully");
                } else {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "Failed to approve request");
                }

            } else if ("reject".equals(action)) {
                // Just reject the request
                boolean rejected = requestBean.rejectRequest(requestId);

                if (rejected) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Request rejected successfully");
                } else {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "Failed to reject request");
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Error processing request: " + e.getMessage());
        }
    }
}