package org.interndb.internshipapplication;

import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.ejb.InternshipPositionBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   4. Redirect to render the positions.jsp
 **********************************************************/

/****************************************************************************
 * AdminDashboardServlet logic:
 *  -doGet :  Get all the Positions from Backend + redirect to /pages/positions
 *  -doPost : TODO
 ****************************************************************************/
@WebServlet(name = "InternshipPosServlet", value = "/InternshipPositions")
class InternshipPosServlet extends HttpServlet {

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

        try {
            // Get data
            List<InternshipPositionDto> positions = internshipPositionBean.findAllPositions();
            long totalPositions = internshipPositionBean.countAllPositions();

            System.out.println("DEBUG: Total positions from count: " + totalPositions);
            System.out.println("DEBUG: Positions list size: " + (positions != null ? positions.size() : "null"));

            if (positions != null && !positions.isEmpty()) {
                for (int i = 0; i < positions.size(); i++) {
                    InternshipPositionDto p = positions.get(i);
                    System.out.println("Position " + i + ": " +
                            "ID=" + p.getId() + ", " +
                            "Title=" + p.getTitle() + ", " +
                            "Company=" + p.getCompanyName() + ", " +
                            "Spots=" + p.getFilledSpots() + "/" + p.getMaxSpots());
                }
            } else {
                System.out.println("DEBUG: Positions list is empty or null");
            }

            // Check if attributes are being set
            request.setAttribute("positions", positions);
            request.setAttribute("totalPositions", totalPositions);

            System.out.println("DEBUG: Attributes set - positions: " + (positions != null));

        } catch (Exception e) {
            System.err.println("ERROR in servlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.toString());
        }

        //Forward to internshipPositions.jsp
        request.getRequestDispatcher("/pages/public/internshipPositions.jsp").forward(request, response);
    }
}