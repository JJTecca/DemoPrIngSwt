package org.interndb.internshipapplication;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.ejb.CompanyInfoBean;
import com.internshipapp.ejb.InternshipPositionBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "CompanyProfileServlet", value = "/CompanyProfile")
public class CompanyProfileServlet extends HttpServlet {

    @Inject
    CompanyInfoBean companyInfoBean;

    @Inject
    InternshipPositionBean positionBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        String idParam = request.getParameter("id");
        CompanyInfoDto company = null;

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // SCENARIO A: Viewing a specific company (e.g., Student browsing companies)
                Long companyId = Long.parseLong(idParam);
                company = companyInfoBean.findById(companyId);

            } else {
                // SCENARIO B: Viewing "My Profile" (Default for Company users)
                if ("Company".equals(role)) {
                    company = companyInfoBean.findByUserEmail(loggedInEmail);
                } else {
                    // If a Student clicks "Company Profile" without an ID, redirect them back
                    response.sendRedirect("Students");
                    return;
                }
            }

            if (company == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Company profile not found");
                return;
            }

            // Load the company's posted positions to display on their public profile
            List<InternshipPositionDto> positions = positionBean.findByCompanyId(company.getId());

            request.setAttribute("company", company);
            request.setAttribute("positions", positions);

            // Forward to the JSP
            request.getRequestDispatcher("/pages/profiles/companyProfile.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Company ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading profile");
        }
    }
}