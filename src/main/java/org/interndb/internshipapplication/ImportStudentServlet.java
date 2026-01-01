package org.interndb.internshipapplication;

import com.internshipapp.ejb.ExcelParserBean;
import com.internshipapp.ejb.StudentInfoBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   5. /doPost to handle specific CRUD operations
 **********************************************************/
@WebServlet(name = "ImportStudentServlet", value = "/ImportStudents")
public class ImportStudentServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(ImportStudentServlet.class.getName());

    /**************************************************************
     * Inject Java Beans that performs CRUD OPERATIONS and filtering
     *************************************************************/
    @Inject
    private ExcelParserBean excelParserBean;

    @Inject
    private StudentInfoBean studentInfoBean;

    // Fixed Excel file name
    private static final String EXCEL_FILE = "Import.xlsx";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();


        // Check for preview data
        List<Map<String, String>> previewData = (List<Map<String, String>>) session.getAttribute("previewData");
        java.util.Enumeration<String> attrNames = session.getAttributeNames();
        while (attrNames.hasMoreElements()) {
            String name = attrNames.nextElement();
            LOG.info("Session attr: " + name + " = " + session.getAttribute(name));
        }

        if (previewData != null) {
            request.setAttribute("previewData", previewData);
            request.setAttribute("studentCount", previewData.size());
        }

        request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        LOG.info("=== DEBUG doPost() ===");
        LOG.info("Action: " + action);
        LOG.info("Session ID: " + session.getId());

        if ("confirmImport".equals(action)) {
            handleConfirmImport(request, response, session);
        } else if ("cancelImport".equals(action)) {
            handleCancelImport(request, response, session);
        } else {
            handleLoadExcel(request, response, session);
        }
    }

    private void handleLoadExcel(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            LOG.info("Loading Excel file: " + EXCEL_FILE);

            // Load Excel file from resources
            try (InputStream excelStream = getClass().getClassLoader()
                    .getResourceAsStream(EXCEL_FILE)) {

                if (excelStream == null) {
                    request.setAttribute("errorMessage", "Excel file not found: " + EXCEL_FILE +
                            ". Please make sure the file is in the resources folder.");
                    request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                    return;
                }

                // Parse Excel to get preview data
                List<Map<String, String>> excelData = studentInfoBean.parseExcelForPreview(excelStream);

                if (excelData.isEmpty()) {
                    request.setAttribute("errorMessage", "No student data found in " + EXCEL_FILE);
                    request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                    return;
                }

                // Store in session for confirmation
                session.setAttribute("previewData", excelData);

                // Use FORWARD instead of REDIRECT to keep data in the same request cycle
                request.setAttribute("previewData", excelData);
                request.setAttribute("studentCount", excelData.size());
                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);

            } catch (Exception e) {
                request.setAttribute("errorMessage", "Error parsing Excel: " + e.getMessage());
                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
        }
    }

    private void handleConfirmImport(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            List<Map<String, String>> excelData = (List<Map<String, String>>) session.getAttribute("previewData");

            java.util.Enumeration<String> attrNames = session.getAttributeNames();
            while (attrNames.hasMoreElements()) {
                String name = attrNames.nextElement();
            }

            if (excelData == null || excelData.isEmpty()) {

                // Try request attribute as fallback (if we forwarded instead of redirected)
                excelData = (List<Map<String, String>>) request.getAttribute("previewData");

                if (excelData == null || excelData.isEmpty()) {
                    session.removeAttribute("previewData");
                    request.setAttribute("errorMessage", "No data to import. Please load the Excel file first.");
                    request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                    return;
                }
            }

            // Import students
            StudentInfoBean.ImportResult importResult = studentInfoBean.importStudentsFromExcelData(excelData);

            session.removeAttribute("previewData");

            request.setAttribute("importResult", importResult);
            request.setAttribute("successMessage",
                    "Successfully imported " + importResult.imported + " students from " + EXCEL_FILE);

            request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Import failed: " + e.getMessage());
            request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
        }
    }

    private void handleCancelImport(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        // Clear session data
        session.removeAttribute("previewData");
        LOG.info("Import cancelled. Cleared previewData from session.");

        // Redirect to clear the form
        response.sendRedirect(request.getContextPath() + "/ImportStudents");
    }
}