package org.interndb.internshipapplication;

import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "UserLoginServlet", value = "/UserLogin")
public class UserLoginServlet extends HttpServlet {
    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    private UserAccountBean userAccountBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/pages/auth/userLogin.jsp").forward(request, response);
    }

    /******************************************************************
     * @param request an {@link HttpServletRequest}
     * @param response an {@link HttpServletResponse}
     * doGet functions implementation to retrieve data from the server
     * Display a webpage or form
     * doPost to handle form submissions : Insert, update, or delete data
     *****************************************************************/
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // 2. Check if user exists and password matches
        boolean auth = userAccountBean.authenticate(email, password);

        if (!auth) {
            request.setAttribute("errorMessage", "Invalid email or password");
            request.getRequestDispatcher("/pages/auth/userLogin.jsp").forward(request, response);
            return;
        }

        // 3. Get role from database
        String role = userAccountBean.getUserRoleByEmail(email);

        // If role is null, determine from email
        if (role == null) {
            if (email.toLowerCase().endsWith("@ulbs.ro")) {
                role = "Admin";
            } else if (email.toLowerCase().endsWith("@ulbsibiu.ro") || email.toLowerCase().contains("student")) {
                role = "Student";
            } else {
                role = "Company";
            }
            System.out.println("Determined role from email: " + role);
        }

        // 4. Create session
        HttpSession session = request.getSession();
        session.setAttribute("userEmail", email);
        session.setAttribute("userRole", role);

        // 5. Redirect based on role
        if ("Admin".equals(role)) {
            response.sendRedirect("AdminDashboard");
        } else if ("Student".equals(role)) {
            response.sendRedirect("StudentDashboard");
        } else if ("Company".equals(role)) {
            response.sendRedirect("CompanyDashboard");
        } else if ("Faculty".equals(role)) {
            response.sendRedirect("FacultyDashboard");
        }
    }
}