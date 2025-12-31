package org.interndb.internshipapplication;

import com.internshipapp.common.*;
import com.internshipapp.ejb.*;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "FacultyDashboardServlet", value = "/FacultyDashboard")
public class FacultyDashboardServlet extends HttpServlet {

    @Inject
    UserAccountBean userAccountBean;

    @Inject
    StudentInfoBean studentInfoBean;

    @Inject
    AccountActivityBean activityBean;

    @Inject
    CompanyInfoBean companyInfoBean; // Injected to handle Department Info

    @Inject
    InternshipPositionBean positionBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Session & Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        // GUARD: Ensure only Faculty can access this dashboard
        if (!"Faculty".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return;
        }

        try {
            // 2. Fetch Faculty Account Data (Contains companyId link)
            UserAccountDto userDto = userAccountBean.findByEmail(email);

            // 3. Fetch Department Info via the linked ID
            CompanyInfoDto facultyDeptDto = null;
            if (userDto.getCompanyId() != null) {
                facultyDeptDto = companyInfoBean.findById(userDto.getCompanyId());
            }

            // 4. Fetch Data for Faculty Panel
            List<AccountActivityDto> activities = activityBean.findActivitiesByUserId(userDto.getUserId());

            // All students for the central roster
            List<StudentInfoDto> allStudents = studentInfoBean.findAllStudents();

            // Tutoring Positions linked to this Faculty's Department ID
            List<InternshipPositionDto> tutoringPositions = null;
            if (facultyDeptDto != null) {
                tutoringPositions = positionBean.findByCompanyId(facultyDeptDto.getId());

                // NEW: Hydrate each position with its candidates list
                if (tutoringPositions != null) {
                    for (InternshipPositionDto pos : tutoringPositions) {
                        pos.setApplicants(positionBean.getApplicantsForPosition(pos.getId()));
                    }
                }
            }

            // 5. Set Attributes for JSP
            request.setAttribute("userAccount", userDto);
            request.setAttribute("facultyDept", facultyDeptDto); // Added attribute
            request.setAttribute("allStudents", allStudents);
            request.setAttribute("tutoringPositions", tutoringPositions);
            request.setAttribute("activities", activities);

            // 6. Forward to the facultyPanel JSP
            request.getRequestDispatcher("/pages/panels/facultyPanel.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading faculty dashboard.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}