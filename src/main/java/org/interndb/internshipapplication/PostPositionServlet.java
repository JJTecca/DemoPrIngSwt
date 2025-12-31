package org.interndb.internshipapplication;

import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.InternshipPositionBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**********************************************************
 * GENERAL SERVLET STRUCTURE :
 * 1. @WebServlet with it's value set to redirect webpage
 * 2. @Inject the bean Class
 * 3. /doGet function at first with debugging context (optional)
 * 4. Redirect to render the postInternship.jsp
 **********************************************************/

/****************************************************************************
 * PostPositionServlet logic:
 * -doGet  : Forward to the creation form in /pages/actions/
 * -doPost : Capture form data, assign status (Open/Pending), and persist
 ****************************************************************************/
@WebServlet(name = "PostPositionServlet", value = "/PostPosition")
public class PostPositionServlet extends HttpServlet {

    @Inject
    AccountActivityBean accountActivityBean;

    @Inject
    InternshipPositionBean internshipPositionBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        // Forward to the form located in the new 'actions' directory
        request.getRequestDispatcher("/pages/actions/postInternship.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // 1. Basic Auth Check
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        // 2. Retrieve required session attributes
        String role = (String) session.getAttribute("userRole");
        Long companyId = (Long) session.getAttribute("companyId");
        Long userId = (Long) session.getAttribute("userId");

        // 3. Strict Validation: If IDs are missing, stop immediately
        if (userId == null || companyId == null) {
            System.err.println("CRITICAL: Post attempt by " + session.getAttribute("userEmail") + " failed because IDs were missing in session.");
            response.sendRedirect(request.getContextPath() + "/PostPosition?error=session_expired");
            return;
        }

        // 4. Role Security Check
        if (!"Company".equals(role) && !"Faculty".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            // 5. Parse Parameters
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String requirements = request.getParameter("requirements");
            int maxSpots = Integer.parseInt(request.getParameter("maxSpots"));
            String deadlineStr = request.getParameter("deadline");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date deadline = sdf.parse(deadlineStr);

            // Faculty bypasses the 'Pending' status
            String initialStatus = "Faculty".equals(role) ? "Open" : "Pending";

            // 6. Create Position
            internshipPositionBean.createPosition(
                    companyId,
                    title,
                    description,
                    requirements,
                    deadline,
                    maxSpots,
                    initialStatus
            );

            // 7. Log Activity
            String details = "Posted new position: " + title + " (Status: " + initialStatus + ")";
            accountActivityBean.logActivity(userId, "PostPosition", details);

            response.sendRedirect(request.getContextPath() + "/PostPosition?success=true");

        } catch (Exception e) {
            System.err.println("ERROR in PostPositionServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/PostPosition?error=true");
        }
    }
}