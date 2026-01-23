package org.interndb.internshipapplication;

import com.internshipapp.config.ApplicationPeriodService;
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
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import java.util.Map;

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

    @Inject
    ApplicationPeriodService periodService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String role = (String) session.getAttribute("userRole");

        if (!periodService.isPostingAllowed() && "Company".equals(role)) {
            // Redirect to appropriate dashboard
            String redirect = "CompanyDashboard";
            response.sendRedirect(redirect + "?error=posting_closed");
            return;
        }

        // Rule: At least 4 days from "Today" OR "Start Date" (whichever is later)
        Map<String, Object> periodStatus = periodService.getApplicationPeriodStatus();
        LocalDate startDate = (LocalDate) periodStatus.get("startDate");
        LocalDate endDate = (LocalDate) periodStatus.get("endDate");
        LocalDate today = LocalDate.now(ZoneId.of("Europe/Bucharest"));

        // If we are currently BEFORE the start date, the 4-day count starts from the Start Date.
        // If we are currently IN the period, it starts from Today.
        LocalDate calculationBase = today.isBefore(startDate) ? startDate : today;
        LocalDate minDeadline = calculationBase.plusDays(4);

        // Pass to JSP
        request.setAttribute("minDeadline", minDeadline.toString());
        request.setAttribute("maxDeadline", endDate.toString());

        // Forward to the form located in the new 'actions' directory
        request.getRequestDispatcher("/pages/actions/postInternship.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Basic Auth Check
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        // Retrieve required session attributes
        String role = (String) session.getAttribute("userRole");
        Long companyId = (Long) session.getAttribute("companyId");
        Long userId = (Long) session.getAttribute("userId");

        // Block companies from posting after 5 days are left
        if ("Company".equals(role) && !periodService.isPostingAllowed()) {
            response.sendRedirect("CompanyDashboard?error=posting_closed");
            return;
        }

        // Strict Validation: If IDs are missing, stop immediately
        if (userId == null || companyId == null) {
            System.err.println("CRITICAL: Post attempt by " + session.getAttribute("userEmail") + " failed because IDs were missing in session.");
            response.sendRedirect(request.getContextPath() + "/PostPosition?error=session_expired");
            return;
        }

        // Role Security Check
        if (!"Company".equals(role) && !"Faculty".equals(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            // Parse Parameters
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String requirements = request.getParameter("requirements");
            int maxSpots = Integer.parseInt(request.getParameter("maxSpots"));
            String deadlineStr = request.getParameter("deadline");

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            Date deadline = sdf.parse(deadlineStr);

            Map<String, Object> periodStatus = periodService.getApplicationPeriodStatus();
            LocalDate startDate = (LocalDate) periodStatus.get("startDate");
            LocalDate endDate = (LocalDate) periodStatus.get("endDate");
            LocalDate today = LocalDate.now(ZoneId.of("Europe/Bucharest"));

            LocalDate calculationBase = today.isBefore(startDate) ? startDate : today;
            LocalDate minDeadline = calculationBase.plusDays(4);

            LocalDate inputDeadline = new java.sql.Date(deadline.getTime()).toLocalDate();

            if (inputDeadline.isBefore(minDeadline)) {
                // Fail if deadline is too soon
                response.sendRedirect(request.getContextPath() + "/PostPosition?error=invalid_date");
                return;
            }

            if (inputDeadline.isAfter(endDate)) {
                response.sendRedirect(request.getContextPath() + "/PostPosition?error=date_too_late");
                return;
            }

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

            // Log Activity
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