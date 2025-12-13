package org.interndb.internshipapplication;

import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(name = "TokenApprovalServlet", value = "/TokenApproval")
public class TokenApprovalServlet extends HttpServlet {

    @Inject
    private UserAccountBean userAccountBean;  // Only need this one

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
                // Use UserAccountBean's method that handles everything
                boolean approved = userAccountBean.approveRequestAndCreateAccount(requestId);

                if (approved) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().write("Request approved and company account created successfully");
                } else {
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                            "Failed to approve request");
                }

            } else if ("reject".equals(action)) {
                // Use UserAccountBean's reject method
                boolean rejected = userAccountBean.rejectRequest(requestId);

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