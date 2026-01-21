package org.interndb.internshipapplication;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.MessageBean;
import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.logging.Logger;

@WebServlet(name = "SendMessageServlet", value = "/SendMessage")
public class SendMessageServlet extends HttpServlet {

    Logger log = Logger.getLogger(SendMessageServlet.class.getName());

    @Inject
    private MessageBean messageBean;

    @Inject
    private InternshipApplicationBean applicationBean;

    @Inject
    private UserAccountBean userAccountBean;

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

            String appIdParam = request.getParameter("appId");
            Long appId = null;
            String messageText = request.getParameter("message");

            if (appIdParam == null || appIdParam.isEmpty()) {
                Long targetStudentId = null;

                if ("Student".equals(role)) {
                    // 1. Student initiating: Resolve their own Student ID from their UserAccount
                    UserAccountDto user = userAccountBean.getUserById(userId);
                    if (user != null) targetStudentId = user.getStudentId();
                } else {
                    // 2. Faculty/Company initiating: Use the 'studentId' parameter from the Modal
                    String sidParam = request.getParameter("studentId");
                    if (sidParam != null && !sidParam.isEmpty()) {
                        targetStudentId = Long.parseLong(sidParam);
                    }
                }

                // Only proceed if we actually have a valid Student ID
                if (targetStudentId != null) {
                    String posIdStr = request.getParameter("positionId");

                    if (posIdStr == null || posIdStr.isEmpty()) {
                        log.severe("Missing positionId parameter for student: " + targetStudentId);
                        response.sendRedirect("InternshipApplications?error=missing_params");
                        return;
                    }

                    Long positionId = Long.parseLong(posIdStr);

                    // LOOKUP FIRST: Prevent transaction rollback
                    InternshipApplicationDto existing = applicationBean.findApplicationDto(targetStudentId, positionId);

                    if (existing != null) {
                        appId = existing.getId();
                    } else {
                        try {
                            appId = applicationBean.createApplication(targetStudentId, positionId);
                        } catch (Exception e) {
                            // This is where your "null" warning was coming from
                            log.warning("EJB Failure for student " + targetStudentId + ": " + e.getClass().getName());
                            e.printStackTrace();
                        }
                    }
                }
            } else {
                appId = Long.parseLong(appIdParam);
            }

            if (appId != null && messageText != null && !messageText.trim().isEmpty()) {
                messageBean.sendMessage(appId, userId, messageText.trim(), role);
                com.internshipapp.websocket.ChatSocket.notify(appId);
            }

            if (appId != null) {
                response.sendRedirect("InternshipApplications?id=" + appId);
            } else {
                // Fallback if no application was created/found
                response.sendRedirect("InternshipApplications?error=not_found");
            }
        } catch (Exception e) {

            e.printStackTrace();
            response.sendRedirect("InternshipApplications?error=msg_failed");
        }
    }
}