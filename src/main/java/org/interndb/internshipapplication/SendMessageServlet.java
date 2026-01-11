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

            Long appId = Long.parseLong(request.getParameter("appId"));
            String messageText = request.getParameter("message");

            // This Bean call triggers the Message creation AND the status
            // transition to 'Discussion' if the sender is a Company.
            if (messageText != null && !messageText.trim().isEmpty()) {
                messageBean.sendMessage(appId, userId, messageText.trim(), role);
            }

            // REDIRECT: Redirect to the hub servlet (InternshipApplications)
            // and pass the 'id' so it loads as the active chat.
            response.sendRedirect("InternshipApplications?id=" + appId);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("InternshipApplications?error=msg_failed");
        }
    }
}