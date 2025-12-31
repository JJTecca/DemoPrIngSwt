package org.interndb.internshipapplication;

import com.internshipapp.ejb.InternshipPositionBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(name = "PositionRequestServlet", value = "/PositionRequestServlet")
public class PositionRequestServlet extends HttpServlet {

    @Inject
    private InternshipPositionBean positionBean;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Security Guard
        HttpSession session = request.getSession(false);
        if (session == null || !"Admin".equals(session.getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            Long posId = Long.parseLong(request.getParameter("id"));
            String action = request.getParameter("action");

            if ("approve".equals(action)) {
                // Change status from 'Pending' to 'Open'
                positionBean.updateStatus(posId, "Open");
            } else if ("reject".equals(action)) {
                // Remove the record
                positionBean.deletePosition(posId);
            }

            // Status 200 tells the JavaScript 'response.ok' is true
            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}