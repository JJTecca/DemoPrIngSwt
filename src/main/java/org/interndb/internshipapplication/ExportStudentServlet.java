package org.interndb.internshipapplication;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.ejb.ExcelParserBean;
import com.internshipapp.ejb.InternshipApplicationBean;
import jakarta.inject.Inject;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet(name = "ExportStudentServlet", value = "/ExportStudents")
public class ExportStudentServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(ExportStudentServlet.class.getName());

    @Inject
    private ExcelParserBean excelParserBean;

    @Inject
    private InternshipApplicationBean appBean; //

    private boolean checkAccess(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return true;
        }

        String role = (String) session.getAttribute("userRole");
        if (!"Faculty".equals(role)) {
            LOG.warning("Unauthorized access attempt by user: " + session.getAttribute("userEmail"));
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: Faculty role required.");
            return true;
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (checkAccess(request, response, session)) return;

        try {
            List<InternshipApplicationDto> allApps = appBean.findAllApplications();

            List<InternshipApplicationDto> completedApps = allApps.stream()
                    .filter(app -> "Completed".equalsIgnoreCase(app.getStudentStatus()))
                    .toList();

            byte[] excelBytes = excelParserBean.createStudentExport(completedApps);

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=note_practica_finalizate.xlsx");
            response.setContentLength(excelBytes.length);

            response.getOutputStream().write(excelBytes);
            response.getOutputStream().flush();

        } catch (Exception e) {
            LOG.severe("Export failed: " + e.getMessage());
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse
            response) throws ServletException, IOException {
    }
}