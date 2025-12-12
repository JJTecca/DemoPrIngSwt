package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.AttachmentBean;
import com.internshipapp.ejb.UserAccountBean;
import com.internshipapp.entities.AccountActivity;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "DeleteCVServlet", value = "/DeleteCV")
public class DeleteCVServlet extends HttpServlet {
    @Inject
    private AttachmentBean attachmentBean;
    @Inject
    private UserAccountBean userAccountBean;
    @Inject
    private AccountActivityBean activityBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String email = (String) session.getAttribute("userEmail");
        if (email == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        try {
            // Get student by Session Email (Secure)
            StudentInfoDto student = userAccountBean.getStudentInfoByEmail(email);

            attachmentBean.deleteCv(student.getId());

            UserAccountDto user = userAccountBean.findByEmail(email);
            if (user != null) activityBean.logActivity(user.getUserId(), AccountActivity.Action.DeleteCV, null);

            response.sendRedirect(request.getContextPath() + "/StudentProfile");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}