package org.interndb.internshipapplication;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.MessageBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "SendMessageServlet", value = "/SendMessage")
public class SendMessageServlet extends HttpServlet {

    @Inject
    private MessageBean messageBean;

    @Inject
    private InternshipApplicationBean applicationBean;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        try {
            Long userId = (Long) session.getAttribute("userId");
            String role = (String) session.getAttribute("userRole");

            // Get data from the chat form
            Long appId = Long.parseLong(request.getParameter("appId"));
            String messageText = request.getParameter("message");

            // 1. Fetch the application details to check status
            InternshipApplicationDto app = applicationBean.getApplicationDtoById(appId);

            // 2. If student tries to message on a Rejected app, block it
            if ("Student".equals(role) && "Rejected".equals(app.getStatus())) {
                response.sendRedirect("InternshipApplications?id=" + appId + "&error=rejected_access");
                return;
            }

            if (messageText != null && !messageText.trim().isEmpty()) {
                // This call triggers the "Discussion" status update logic we wrote in the Bean
                messageBean.sendMessage(appId, userId, messageText.trim(), role);
            }

            // Redirect back to the conversation to refresh the view
            response.sendRedirect("InternshipApplication?id=" + appId);

        } catch (Exception e) {
            // Log error and redirect back with a generic error state
            response.sendRedirect("InternshipApplication?error=msg_failed");
        }
    }
}