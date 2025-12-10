package org.interndb.internshipapplication;

import com.internshipapp.ejb.RequestBean;
import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   4. Redirect to render the adminPanel.jsp
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
        // Get pending requests
        List<com.internshipapp.common.RequestDto> pendingRequests = requestBean.getPendingRequests();

        for (com.internshipapp.common.RequestDto req : pendingRequests) {
            System.out.println("Request: " + req.getCompanyName() + " - " + req.getCompanyEmail());
        }

        request.setAttribute("pendingRequests", pendingRequests);
        request.setAttribute("pendingRequestsCount", pendingRequests.size());

        // Get total users count (you need to add this method to UserAccountBean)
        // For now, we'll use placeholder
        request.setAttribute("totalUsers", 10);
        request.setAttribute("activeStudents", 6);
        request.setAttribute("totalCompanies", 4);

        // Forward to admin panel
        request.getRequestDispatcher("/pages/panels/adminPanel.jsp").forward(request, response);
    }
}