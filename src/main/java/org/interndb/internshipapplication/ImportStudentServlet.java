package org.interndb.internshipapplication;

import com.internshipapp.ejb.ExcelParserBean;
import com.internshipapp.ejb.StudentInfoBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet(name = "ImportStudentServlet", value = "/ImportStudents")
@MultipartConfig(
        maxFileSize = 10485760,      // 10MB = 10 * 1024 * 1024
        maxRequestSize = 20971520,   // 20MB
        fileSizeThreshold = 1048576, // 1MB
        location = ""
)
public class ImportStudentServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(ImportStudentServlet.class.getName());

    @Inject
    private ExcelParserBean excelParserBean;

    @Inject
    private StudentInfoBean studentInfoBean;

    private boolean checkAccess(HttpServletRequest request, HttpServletResponse response, HttpSession session) throws IOException {
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect(request.getContextPath() + "/UserLogin");
            return true;
        }

        String role = (String) session.getAttribute("userRole");
        if (!"Faculty".equals(role)) {
            // Log the unauthorized attempt
            LOG.warning("Unauthorized access attempt to ImportStudents by user: " + session.getAttribute("userEmail"));
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
            String fileName = (String) session.getAttribute("uploadedFileName");
            if (fileName != null) {
                request.setAttribute("fileName", fileName);
            }
        }

        request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        if (checkAccess(request, response, session)) return;

        LOG.info("=== DEBUG doPost() ===");
        LOG.info("Action: " + action);
        LOG.info("Session ID: " + session.getId());

        if ("confirmImport".equals(action)) {
            handleConfirmImport(request, response, session);
        } else if ("cancelImport".equals(action)) {
            handleCancelImport(request, response, session);
        } else {
            // Default action: handle file upload
            handleUploadExcel(request, response, session);
        }
    }

    private void handleUploadExcel(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            // Check if this is a multipart request (file upload)
            String contentType = request.getContentType();
            LOG.info("Content-Type: " + contentType);

            if (contentType == null || !contentType.toLowerCase().startsWith("multipart/")) {
                // This is the old "Load Excel" action - you can remove this if you want
                request.setAttribute("errorMessage", "Please use the file upload form");
                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                return;
            }

            // Get the uploaded file part
            Part filePart = request.getPart("excelFile");

            if (filePart == null || filePart.getSize() == 0) {
                request.setAttribute("errorMessage", "Please select an Excel file to upload");
                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                return;
            }

            // Validate file type
            String fileName = filePart.getSubmittedFileName();
            if (fileName == null || !fileName.toLowerCase().endsWith(".xlsx")) {
                request.setAttribute("errorMessage", "Please upload an Excel file (.xlsx format)");
                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                return;
            }

            try (InputStream excelStream = filePart.getInputStream()) {
                // Parse Excel using StudentInfoBean (which uses ExcelParserBean internally)
                List<Map<String, String>> excelData = studentInfoBean.parseExcelForPreview(excelStream);

                if (excelData.isEmpty()) {
                    request.setAttribute("errorMessage", "No student data found in the uploaded file");
                    request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                    return;
                }

                // Store original filename and data in session
                session.setAttribute("uploadedFileName", fileName);
                session.setAttribute("previewData", excelData);

                // Set request attributes for immediate display
                request.setAttribute("previewData", excelData);
                request.setAttribute("studentCount", excelData.size());
                request.setAttribute("fileName", fileName);

                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);

            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("errorMessage", "Error parsing Excel file: " + e.getMessage());
                request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error uploading file: " + e.getMessage());
            request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
        }
    }

    private void handleConfirmImport(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        try {
            List<Map<String, String>> excelData = (List<Map<String, String>>) session.getAttribute("previewData");
            String fileName = (String) session.getAttribute("uploadedFileName");

            if (excelData == null || excelData.isEmpty()) {
                excelData = (List<Map<String, String>>) request.getAttribute("previewData");

                if (excelData == null || excelData.isEmpty()) {
                    session.removeAttribute("previewData");
                    session.removeAttribute("uploadedFileName");
                    request.setAttribute("errorMessage", "No data to import. Please upload an Excel file first.");
                    request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
                    return;
                }
            }

            // Import students using your existing method
            StudentInfoBean.ImportResult importResult = studentInfoBean.importStudentsFromExcelData(excelData);

            // Clear session data
            session.removeAttribute("previewData");
            session.removeAttribute("uploadedFileName");

            request.setAttribute("importResult", importResult);
            request.setAttribute("successMessage",
                    "Successfully imported " + importResult.getImported() + " students from " +
                            (fileName != null ? fileName : "the uploaded file"));

            request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);

        } catch (Exception e) {
            LOG.severe("Import failed: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Import failed: " + e.getMessage());
            request.getRequestDispatcher("/pages/actions/import.jsp").forward(request, response);
        }
    }

    private void handleCancelImport(HttpServletRequest request, HttpServletResponse response, HttpSession session)
            throws ServletException, IOException {
        // Clear session data
        session.removeAttribute("previewData");
        session.removeAttribute("uploadedFileName");
        LOG.info("Import cancelled. Cleared uploaded data from session.");

        // Redirect to clear the form
        response.sendRedirect(request.getContextPath() + "/ImportStudents");
    }
}