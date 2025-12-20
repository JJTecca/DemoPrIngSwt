package org.interndb.internshipapplication;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.ejb.AccountActivityBean;
import com.internshipapp.ejb.StudentInfoBean;
import com.internshipapp.ejb.UserAccountBean;

import jakarta.inject.Inject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "StudentProfileServlet", value = "/StudentProfile")
public class StudentProfileServlet extends HttpServlet {

    @Inject
    StudentInfoBean studentInfoBean;

    @Inject
    UserAccountBean userAccountBean;

    @Inject
    AccountActivityBean activityBean;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userEmail") == null) {
            response.sendRedirect("UserLogin");
            return;
        }

        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");

        String idParam = request.getParameter("id");
        StudentInfoDto student = null;

        try {
            if (idParam != null && !idParam.isEmpty()) {
                // View specific student (Admin/Faculty/Company view)
                Long studentId = Long.parseLong(idParam);
                student = studentInfoBean.findById(studentId);
            } else {
                // View own profile
                if ("Student".equals(role)) {
                    student = userAccountBean.getStudentInfoByEmail(loggedInEmail);
                } else {
                    if ("Company".equals(role)) {
                        response.sendRedirect("pages/panels/companyPanel.jsp");
                        return;
                    }
                    response.sendRedirect("AdminDashboard");
                    return;
                }
            }

            if (student == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Student profile not found");
                return;
            }

            request.setAttribute("student", student);
            request.getRequestDispatcher("/pages/public/studentProfile.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Student ID");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading profile");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String loggedInEmail = (String) session.getAttribute("userEmail");
        String role = (String) session.getAttribute("userRole");
        String action = request.getParameter("action");

        if (loggedInEmail == null || action == null || (!"Student".equals(role) && !"Faculty".equals(role))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied.");
            return;
        }

        try {
            StudentInfoDto studentDto;
            String studentIdParam = request.getParameter("studentId");

            if ("Faculty".equals(role) && studentIdParam != null) {
                studentDto = studentInfoBean.findById(Long.parseLong(studentIdParam));
            } else {
                studentDto = userAccountBean.getStudentInfoByEmail(loggedInEmail);
            }

            if (studentDto == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Student profile not found.");
                return;
            }

            UserAccountDto userDto = userAccountBean.findByEmail(loggedInEmail);
            if (userDto == null) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "User account data missing.");
                return;
            }

            // 3. ACTION DISPATCHER
            if ("update_bio".equals(action)) {
                String newBiography = request.getParameter("biography");

                if (newBiography != null) {
                    newBiography = newBiography.trim();
                    if (newBiography.length() > 255) {
                        newBiography = newBiography.substring(0, 255);
                    }
                } else {
                    newBiography = "";
                }

                studentInfoBean.updateStudent(
                        studentDto.getId(),
                        studentDto.getFirstName(),
                        studentDto.getMiddleName(),
                        studentDto.getLastName(),
                        studentDto.getStudyYear(),
                        studentDto.getLastYearGrade(),
                        studentDto.getStatus(),
                        studentDto.getEnrolled(),
                        newBiography,
                        studentDto.getGradeVisibility()
                );

                // 4. Log the Activity (Layer-Safe using String key)
                activityBean.logActivity(
                        userDto.getUserId(),
                        "UpdateBiography",
                        "Updated profile biography."
                );

                response.sendRedirect(request.getContextPath() + "/StudentProfile?update=bio_success");

            } else if ("toggle_grade_visibility".equals(action)) {
                String visibilityParam = request.getParameter("gradeVisibility");
                boolean newVisibility = (visibilityParam != null);

                studentInfoBean.updateStudent(
                        studentDto.getId(),
                        studentDto.getFirstName(),
                        studentDto.getMiddleName(),
                        studentDto.getLastName(),
                        studentDto.getStudyYear(),
                        studentDto.getLastYearGrade(),
                        studentDto.getStatus(),
                        studentDto.getEnrolled(),
                        studentDto.getBiography(),
                        newVisibility
                );

                if (!newVisibility) {
                    // FIX: Pass "HideStudyGrade" as a String key
                    activityBean.logActivity(
                            userDto.getUserId(),
                            "HideStudyGrade",
                            "Student restricted grade visibility for companies."
                    );
                }
                response.sendRedirect(request.getContextPath() + "/StudentProfile?update=visibility_success");
            }else if ("update_student_grade".equals(action) && "Faculty".equals(role)) {
                // Action 1: Update only the grade
                String newGradeStr = request.getParameter("studyGrade");
                if (newGradeStr != null) {
                    Float newGrade = Float.parseFloat(newGradeStr);
                    studentInfoBean.updateStudent(
                            studentDto.getId(), studentDto.getFirstName(), studentDto.getMiddleName(),
                            studentDto.getLastName(), studentDto.getStudyYear(), newGrade,
                            studentDto.getStatus(), studentDto.getEnrolled(),
                            studentDto.getBiography(), studentDto.getGradeVisibility()
                    );
                    // No activity log saved as requested
                }
                response.sendRedirect(request.getContextPath() + "/StudentProfile?id=" + studentDto.getId() + "&update=grade_success");

            } else if ("update_student_year".equals(action) && "Faculty".equals(role)) {
                // Action 2: Update only the year
                String newYearStr = request.getParameter("studyYear");
                if (newYearStr != null) {
                    Integer newYear = Integer.parseInt(newYearStr);
                    studentInfoBean.updateStudent(
                            studentDto.getId(), studentDto.getFirstName(), studentDto.getMiddleName(),
                            studentDto.getLastName(), newYear, studentDto.getLastYearGrade(),
                            studentDto.getStatus(), studentDto.getEnrolled(),
                            studentDto.getBiography(), studentDto.getGradeVisibility()
                    );
                    // No activity log saved as requested
                }
                response.sendRedirect(request.getContextPath() + "/StudentProfile?id=" + studentDto.getId() + "&update=year_success");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unrecognized profile update action: " + action);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Profile update failed.");
        }
    }
}