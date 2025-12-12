package org.interndb.internshipapplication;

import com.internshipapp.common.FileDto;
import com.internshipapp.ejb.AttachmentBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.OutputStream;

@WebServlet(name = "DownloadCVServlet", value = "/DownloadCV")
public class DownloadCVServlet extends HttpServlet {
    @Inject
    private AttachmentBean attachmentBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Long studentId = Long.parseLong(idParam);
            FileDto file = attachmentBean.getCvFile(studentId);

            if (file != null && file.getFileData() != null) {
                response.setContentType(file.getContentType());
                response.setHeader("Content-Disposition", "attachment; filename=\"" + file.getFileName() + "\"");
                response.setContentLength(file.getFileData().length);
                response.getOutputStream().write(file.getFileData());
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}