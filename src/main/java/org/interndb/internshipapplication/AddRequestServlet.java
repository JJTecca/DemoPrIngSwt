package org.interndb.internshipapplication;

import com.internshipapp.common.RequestDto;
import com.internshipapp.ejb.RequestBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.security.MessageDigest;
import java.util.Base64;
import java.util.logging.Logger;
/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   5. /doPost to handle specific CRUD operations
 **********************************************************/

/***********************************************************
 * AddRequestServlet logic:
 *  -doGet : redirect to /pages/auth/companyRegister.jsp
 *  -doPost : RequestDTO Obj creation + SHA-512 Encryption
 ************************************************************/
@WebServlet(name = "AddRequestServlet", value = "/CompanyRegister")
public class AddRequestServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(AddRequestServlet.class.getName());

    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    RequestBean requestBean;

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
        request.getRequestDispatcher("/pages/auth/companyRegister.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get form parameters
            String companyName = request.getParameter("companyName");
            String companyEmail = request.getParameter("companyEmail");
            String companyAddress = request.getParameter("companyAddress");
            String phoneNumber = request.getParameter("phoneNumber");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");

            // Validate
            if (!password.equals(confirmPassword)) {
                request.setAttribute("errorMessage", "Passwords do not match!");
                request.getRequestDispatcher("/pages/auth/companyRegister.jsp").forward(request, response);
                return;
            }

            // SHA-512 token
            String timestamp = String.valueOf(System.currentTimeMillis());
            String token = sha512(companyEmail + timestamp);
            String hashedPassword = sha512(password);

            // Create and save request - Update to pass status correctly
            RequestDto requestDto = new RequestDto(
                    null, // id will be generated
                    companyName,
                    companyEmail,
                    companyAddress,
                    phoneNumber,
                    hashedPassword,
                    token,
                    "pending" // status as string
            );

            RequestDto savedRequest = requestBean.createRequest(requestDto);

            if (savedRequest.getId() != null) {
                LOG.info("Company registration created: " + companyName);

                // Set success attributes for the SAME PAGE
                request.setAttribute("showSuccessModal", "true");
                request.setAttribute("companyName", companyName);
                request.setAttribute("companyEmail", companyEmail);
                request.setAttribute("successMessage",
                        "Registration submitted successfully! Your request is pending admin approval.");

                // Forward back to the SAME JSP with success attributes
                request.getRequestDispatcher("/pages/auth/companyRegister.jsp").forward(request, response);
            } else {
                throw new ServletException("Failed to save registration");
            }

        } catch (Exception e) {
            LOG.severe("Registration error: " + e.getMessage());
            request.setAttribute("errorMessage", "Registration failed: " + e.getMessage());
            request.getRequestDispatcher("/pages/auth/companyRegister.jsp").forward(request, response);
        }
    }

    private String sha512(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-512");
            byte[] hash = md.digest(input.getBytes());
            return Base64.getUrlEncoder().withoutPadding().encodeToString(hash);
        } catch (Exception e) {
            throw new RuntimeException("SHA-512 hashing failed", e);
        }
    }
}