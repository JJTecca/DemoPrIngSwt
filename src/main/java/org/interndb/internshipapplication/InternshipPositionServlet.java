package org.interndb.internshipapplication;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.ejb.InternshipApplicationBean;
import com.internshipapp.ejb.InternshipPositionBean;
import com.internshipapp.ejb.UserAccountBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**********************************************************
 * GENERAL SERVLET STRUCTURE :
 * 1. @WebServlet with it's value set to redirect webpage
 * 2. @Inject the bean Class
 * 3. /doGet function at first with debugging context (optional)
 * 4. Redirect to render the positions.jsp
 **********************************************************/

/****************************************************************************
 * AdminDashboardServlet logic:
 * -doGet :  Get all the Positions from Backend + redirect to /pages/positions
 * -doPost : TODO
 ****************************************************************************/
@WebServlet(name = "InternshipPositionServlet", value = "/InternshipPositions")
public class InternshipPositionServlet extends HttpServlet {

    @Inject
    InternshipPositionBean internshipPositionBean;

    // Added for Application Logic
    @Inject
    InternshipApplicationBean internshipApplicationBean;

    // Added to find studentId from Email
    @Inject
    UserAccountBean userAccountBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String email = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");
        // Retrieve companyId for ownership check
        Long sessionCompanyId = (Long) session.getAttribute("companyId");

        try {
            // 1. Get ALL data initially
            List<InternshipPositionDto> allPositions = internshipPositionBean.findAllPositions();

            // 2. Filter logic: Exclude 'Pending' and handle any specific filter requests (like 'Open' only)
            // This follows the Open-Closed principle by filtering the stream here.
            String filterStatus = request.getParameter("filterStatus"); // e.g., "Open"

            List<InternshipPositionDto> positions = allPositions.stream()
                    .filter(pos -> {
                        // Hard rule: No one sees Pending positions on this page
                        if ("Pending".equals(pos.getStatus())) {
                            return false;
                        }
                        // If user requested only 'Open' positions via UI
                        if ("Open".equals(filterStatus)) {
                            return "Open".equals(pos.getStatus());
                        }
                        return true; // Keep 'Open' and 'Closed'
                    })
                    .collect(Collectors.toList());

            // Recalculate count based on filtered list
            long totalPositions = (long) positions.size();

            // Handle Student "Already Applied" logic
            if ("Student".equals(role) && email != null) {
                StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
                if (student != null) {
                    List<Long> appliedIds = internshipApplicationBean.getAppliedPositionIds(student.getId());
                    if (appliedIds != null && !appliedIds.isEmpty()) {
                        for (InternshipPositionDto pos : positions) {
                            if (appliedIds.contains(pos.getId())) {
                                pos.setAlreadyApplied(true);
                            }
                        }
                    }
                }
            }

            // --- ADDED: Role-Based Applicant Visibility Logic ---
            if (positions != null) {
                for (InternshipPositionDto pos : positions) {
                    boolean isAdminOrFaculty = "Admin".equals(role) || "Faculty".equals(role);
                    boolean isOwningCompany = "Company".equals(role) && pos.getCompanyId().equals(sessionCompanyId);

                    if (isAdminOrFaculty || isOwningCompany) {
                        List<InternshipApplicationDto> applicants = internshipPositionBean.getApplicantsForPosition(pos.getId());
                        pos.setApplicants(applicants);
                    }
                }
            }
            // --- END OF ADDED LOGIC ---

            System.out.println("DEBUG: Filtered positions size: " + totalPositions);
            System.out.println("DEBUG: Original list size: " + (allPositions != null ? allPositions.size() : "null"));

            if (positions != null && !positions.isEmpty()) {
                for (int i = 0; i < positions.size(); i++) {
                    InternshipPositionDto p = positions.get(i);
                    System.out.println("Position " + i + ": " +
                            "ID=" + p.getId() + ", " +
                            "Title=" + p.getTitle() + ", " +
                            "Status=" + p.getStatus() + ", " +
                            "Company=" + p.getCompanyName() + ", " +
                            "Spots=" + p.getAcceptedCount() + "/" + p.getMaxSpots());
                }
            } else {
                System.out.println("DEBUG: Positions list is empty or null after filtering");
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