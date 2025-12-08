package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.ejb.StudentInfoBean;
import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**********************************************************
 *              GENERAL SERVLET STRUCTURE :
 *   1. @WebServlet with it's value set to redirect webpage
 *   2. @Inject the bean Class
 *   3. /doGet function at first with debugging context (optional)
 *   4. Redirect to render the test.jsp
 **********************************************************/
@WebServlet(name = "StudentsServlet", value = "/Students")
class StudentsServlet extends HttpServlet {

    @Inject
    StudentInfoBean studentInfoBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // Get data
            List<StudentInfoDto> students = studentInfoBean.findAllStudents();
            long totalStudents = studentInfoBean.countStudents();

            System.out.println("DEBUG: Total students from count: " + totalStudents);
            System.out.println("DEBUG: Students list size: " + (students != null ? students.size() : "null"));

            // Debug each student
            if (students != null && !students.isEmpty()) {
                for (int i = 0; i < students.size(); i++) {
                    StudentInfoDto s = students.get(i);
                    System.out.println("Student " + i + ": " +
                            "ID=" + s.getId() + ", " +
                            "Name=" + s.getFirstName() + " " + s.getLastName() + ", " +
                            "Status=" + s.getStatus() + ", " +
                            "Enrolled=" + s.getEnrolled());
                }
            } else {
                System.out.println("DEBUG: Students list is empty or null");
            }

            // Check if attributes are being set
            request.setAttribute("students", students);
            request.setAttribute("totalStudents", totalStudents);

            System.out.println("DEBUG: Attributes set - students: " + (students != null));
            System.out.println("DEBUG: Forwarding to JSP...");

        } catch (Exception e) {
            System.err.println("ERROR in servlet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", e.toString());
        }

        // Forward to JSP
        request.getRequestDispatcher("/pages/test.jsp").forward(request, response);
    }
}