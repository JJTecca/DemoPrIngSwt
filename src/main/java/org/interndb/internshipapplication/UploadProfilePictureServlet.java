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

@WebServlet(name = "UploadProfilePictureServlet", value = "/UploadProfilePicture")
@MultipartConfig(maxFileSize = 1024 * 1024 * 5)
public class UploadProfilePictureServlet extends HttpServlet {
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
            Part filePart = request.getPart("file");
            if (filePart != null && filePart.getSize() > 0) {
                StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);
                byte[] fileBytes = filePart.getInputStream().readAllBytes();

                attachmentBean.updateProfilePicture(student.getId(), fileBytes);

                UserAccountDto user = userAccountBean.findByEmail(email);
                if (user != null) activityBean.logActivity(user.getUserId(), AccountActivity.Action.ChangePFP, null);
            }
            response.sendRedirect(request.getContextPath() + "/StudentProfile?t=" + System.currentTimeMillis());
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}