package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.AttachmentBean;
import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.entities.AccountActivity;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "UploadCVServlet", value = "/UploadCV")
@MultipartConfig(maxFileSize = 1024 * 1024 * 10)
public class UploadCVServlet extends HttpServlet {
    @Inject
    private AttachmentBean attachmentBean;
    @Inject
    private UserAccountBean userAccountBean;
    @Inject
    private AccountActivityBean activityBean;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String email = (String) session.getAttribute("userEmail");
        if (email == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        try {
            Part filePart = request.getPart("cvFile");
            if (filePart != null && filePart.getSize() > 0) {
                StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
                boolean alreadyHadCv = student.getAttachment().isCvAvailable();

                String fileName = filePart.getSubmittedFileName();
                String contentType = filePart.getContentType();
                byte[] fileBytes = filePart.getInputStream().readAllBytes();

                attachmentBean.updateCvForStudent(student.getId(), fileBytes, fileName, contentType);

                UserAccountDto user = userAccountBean.findByEmail(email);
                if (user != null) {
                    AccountActivity.Action action = alreadyHadCv
                            ? AccountActivity.Action.ChangeCV
                            : AccountActivity.Action.UploadCV;

                    activityBean.logActivity(user.getUserId(), action, null);
                }
            }
            response.sendRedirect(request.getContextPath() + "/StudentProfile");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}