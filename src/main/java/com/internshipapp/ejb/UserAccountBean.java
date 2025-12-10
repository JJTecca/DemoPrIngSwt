package com.internshipapp.ejb;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.entities.StudentInfo;
import com.internshipapp.entities.UserAccount;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Stateless
public class UserAccountBean {
    private static final Logger LOG = Logger.getLogger(UserAccountBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    public List<UserAccountDto> copyUsersToDto(List<UserAccount> users) {
        List<UserAccountDto> dtos = new ArrayList<>();
        for (UserAccount user : users) {
            UserAccountDto userDto = new UserAccountDto(
                    user.getUserId(),
                    user.getUsername(),
                    user.getPassword(),
                    user.getEmail(),
                    user.getStudentInfo() != null ? user.getStudentInfo().getId() : null,
                    user.getStudentInfo() != null ? user.getStudentInfo().getFirstName() + " " + user.getStudentInfo().getLastName() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getId() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getName() : null
            );
            dtos.add(userDto);
        }
        return dtos;
    }

    public UserAccountDto findByEmail(String email) {
        LOG.info("findByEmail: " + email);
        try {
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.email = :email", UserAccount.class);
            query.setParameter("email", email);
            UserAccount user = query.getSingleResult();

            return new UserAccountDto(
                    user.getUserId(),
                    user.getUsername(),
                    user.getPassword(),
                    user.getEmail(),
                    user.getStudentInfo() != null ? user.getStudentInfo().getId() : null,
                    user.getStudentInfo() != null ? user.getStudentInfo().getFirstName() + " " + user.getStudentInfo().getLastName() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getId() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getName() : null
            );
        } catch (Exception ex) {
            LOG.info("User not found with email: " + email + " - Error: " + ex.getMessage());
            return null;
        }
    }

    /**************************************************************************
     * NOTE : In database password are encrypted already, remove the BCrypt prefix
     * Admin is hardcoded in the database with proper password
     ****************************************************************************/
    public boolean authenticate(String email, String password) {
        LOG.info("authenticate: " + email);

        // Hardcoded admin check
        if ("admin@ulbs.ro".equals(email) && "password123".equals(password)) {
            LOG.info("Hardcoded admin authentication successful");
            return true;
        }

        UserAccountDto user = findByEmail(email);
        if (user == null) {
            LOG.info("User not found: " + email);
            return false;
        }

        String storedPassword = user.getPassword();

        // Handle BCrypt format: $2a$10$studpass1
        // Remove the BCrypt prefix to get the actual password
        if (storedPassword != null && storedPassword.startsWith("$2a$10$")) {
            // Remove the "$2a$10$" prefix (7 characters)
            String extractedPassword = storedPassword.substring(7);
            LOG.info("Extracted password after removing BCrypt prefix: " + extractedPassword);

            boolean match = password.equals(extractedPassword);
            LOG.info("Password match after BCrypt extraction: " + match);
            return match;
        }

        // If not BCrypt format, do direct comparison
        boolean authenticated = password.equals(storedPassword);
        LOG.info("Direct comparison result: " + authenticated);
        return authenticated;
    }

    public String getUserRoleByEmail(String email) {
        try {
            TypedQuery<String> query = entityManager.createQuery(
                    "SELECT p.role FROM Permission p WHERE p.user.email = :email", String.class);
            query.setParameter("email", email);
            String role = query.getSingleResult();
            return role;
        } catch (Exception ex) {
            // If no role in database, determine from email
            if (email.toLowerCase().endsWith("@ulbs.ro")) {
                return "Admin";
            } else if (email.toLowerCase().contains("student") || email.toLowerCase().endsWith("@ulbsibiu.ro")) {
                return "Student";
            } else {
                return "Company";
            }
        }
    }

    public StudentInfoDto getStudentInfoByEmail(String email) {
        LOG.info("getStudentInfoByEmail: " + email);
        try {
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u LEFT JOIN FETCH u.studentInfo WHERE u.email = :email",
                    UserAccount.class
            );
            query.setParameter("email", email);
            UserAccount user = query.getSingleResult();

            if (user != null && user.getStudentInfo() != null) {
                StudentInfo student = user.getStudentInfo();
                return new StudentInfoDto(
                        student.getId(),
                        student.getAttachment() != null ? student.getAttachment().getId() : null,
                        student.getFirstName(),
                        student.getMiddleName(),
                        student.getLastName(),
                        student.getStudyYear(),
                        student.getLastYearGrade(),
                        student.getStatus().toString(),
                        student.getEnrolled(),
                        user.getEmail(),
                        user.getUsername(),
                        user.getUserId()
                );
            }
            return null;
        } catch (Exception ex) {
            LOG.info("Student info not found for email: " + email + " - Error: " + ex.getMessage());
            return null;
        }
    }

    public List<UserAccountDto> findAllUsers() {
        LOG.info("findAllUsers");
        try {
            TypedQuery<UserAccount> typedQuery = entityManager.createQuery("SELECT u FROM UserAccount u", UserAccount.class);
            List<UserAccount> users = typedQuery.getResultList();
            return copyUsersToDto(users);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}