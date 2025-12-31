package org.interndb.internshipapplication;

import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.ejb.InternshipPositionBean;
import com.internshipapp.ejb.RequestBean;
import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**********************************************************
 * GENERAL SERVLET STRUCTURE :
 * 1. @WebServlet with it's value set to redirect webpage
 * 2. @Inject the bean Class
 * 3. /doGet function at first with debugging context (optional)
 * 4. Redirect to render the adminPanel.jsp
 **********************************************************/

/***********************************************************
 * AdminDashboardServlet logic:
 * -doGet  : Get pending registration requests & pending positions
 * -doPost : TODO
 **********************************************************/
@WebServlet(name = "AdminDashboardServlet", value = "/AdminDashboard")
public class AdminDashboardServlet extends HttpServlet {

    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    private RequestBean requestBean;

    @Inject
    private UserAccountBean userAccountBean;

    @Inject
    private InternshipPositionBean internshipPositionBean;

    /******************************************************************
     * @param request an {@link HttpServletRequest}
     * @param response an {@link HttpServletResponse}
     * doGet functions implementation to retrieve data from the server
     * Display a webpage or form
     * doPost to handle form submissions : Insert, update, or delete data
     *****************************************************************/
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userRole") == null ||
                !"Admin".equals(session.getAttribute("userRole"))) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return;
        }

        try {
            // 1. Get pending Company Registration requests (Existing)
            List<com.internshipapp.common.RequestDto> pendingRequests = requestBean.getPendingRequests();

            // 2. Get pending Internship Position requests (New Action-based logic)
            List<InternshipPositionDto> pendingPositions = internshipPositionBean.findPendingPositions();

            // 3. Set Attributes for Registration Requests
            request.setAttribute("pendingRequests", pendingRequests);
            request.setAttribute("pendingRequestsCount", pendingRequests.size());

            // 4. Set Attributes for Position Requests (Used by the new scroll container)
            request.setAttribute("pendingPositions", pendingPositions);

            // 5. Dashboard Stats (Placeholder logic preserved, updated with real position count)
            request.setAttribute("totalUsers", 10);
            request.setAttribute("activeStudents", 6);
            request.setAttribute("totalCompanies", 4);

            System.out.println("DEBUG Admin: Found " + pendingRequests.size() + " reg requests and " +
                    pendingPositions.size() + " position requests.");

        } catch (Exception e) {
            System.err.println("ERROR in AdminDashboardServlet: " + e.getMessage());
            e.printStackTrace();
        }

        // Forward to admin panel
        request.getRequestDispatcher("/pages/panels/adminPanel.jsp").forward(request, response);
    }
}