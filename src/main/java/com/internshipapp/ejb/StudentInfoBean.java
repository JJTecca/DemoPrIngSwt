package com.internshipapp.ejb;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.entities.StudentInfo;
import com.internshipapp.entities.UserAccount;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Logger;

/*******************************************************************
 *      Format of the Bean
 *      1. User proper java EE annotations
 *      2. Declare one log + entityManager
 *      3. Functions which involve calling DTO's
 *      4. CRUD Operations / Other SQL Statement Execution functions
 *      NOTE:  Follow consistent naming conventions and code organization
 *******************************************************************/
@Stateless
public class StudentInfoBean {
    private static final Logger LOG = Logger.getLogger(StudentInfoBean.class.getName());

    @PersistenceContext(unitName = "default")
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<StudentInfoDto> copyStudentsToDto(List<StudentInfo> students) {
        List<StudentInfoDto> dtos = new ArrayList<>();
        for (StudentInfo student : students) {
            dtos.add(copyStudentToDto(student));
        }
        return dtos;
    }

    public StudentInfoDto copyStudentToDto(StudentInfo student) {
        if (student == null) return null;

        // Get user account information by querying UserAccount table
        String userEmail = null;
        String username = null;
        Long userId = null;

        // Find the user account that references this student
        try {
            TypedQuery<UserAccount> userQuery = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.studentInfo = :student",
                    UserAccount.class
            );
            userQuery.setParameter("student", student);
            UserAccount userAccount = userQuery.getSingleResult();

            if (userAccount != null) {
                userEmail = userAccount.getEmail();
                username = userAccount.getUsername();
                userId = userAccount.getUserId();
            }
        } catch (Exception e) {
            LOG.info("No user account found for student ID: " + student.getId());
        }

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
                userEmail,
                username,
                userId
        );
    }

    // Add custom query methods for specific business requirements
    public List<StudentInfoDto> findAllStudents() {
        LOG.info("findAllStudents");
        try {
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery(
                    "SELECT s FROM StudentInfo s",
                    StudentInfo.class
            );
            List<StudentInfo> students = typedQuery.getResultList();
            return copyStudentsToDto(students);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public StudentInfoDto findById(Long studentId) {
        LOG.info("findById: " + studentId);
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            return copyStudentToDto(student);
        } catch (Exception ex) {
            LOG.warning("Student not found: " + studentId + " - " + ex.getMessage());
            return null;
        }
    }

    public StudentInfoDto findByUserId(Long userId) {
        LOG.info("findByUserId: " + userId);
        try {
            // Get the user account first
            UserAccount userAccount = entityManager.find(UserAccount.class, userId);
            if (userAccount != null && userAccount.getStudentInfo() != null) {
                return copyStudentToDto(userAccount.getStudentInfo());
            }
            return null;
        } catch (Exception ex) {
            LOG.warning("Student not found for user ID: " + userId + " - " + ex.getMessage());
            return null;
        }
    }

    public StudentInfoDto findByUserEmail(String email) {
        LOG.info("findByUserEmail: " + email);
        try {
            // Find user account by email, then get the student info
            TypedQuery<UserAccount> userQuery = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.email = :email",
                    UserAccount.class
            );
            userQuery.setParameter("email", email);
            UserAccount userAccount = userQuery.getSingleResult();

            if (userAccount != null && userAccount.getStudentInfo() != null) {
                return copyStudentToDto(userAccount.getStudentInfo());
            }
            return null;
        } catch (Exception ex) {
            LOG.warning("Student not found for email: " + email + " - " + ex.getMessage());
            return null;
        }
    }

    // The rest of the methods remain the same...
    // Only the find methods above need to be changed

    public long countStudents() {
        LOG.info("countStudents");
        try {
            TypedQuery<Long> typedQuery = entityManager.createQuery("SELECT COUNT(s) FROM StudentInfo s", Long.class);
            return typedQuery.getSingleResult();
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public long countAvailableStudents() {
        LOG.info("countAvailableStudents");
        try {
            TypedQuery<Long> typedQuery = entityManager.createQuery(
                    "SELECT COUNT(s) FROM StudentInfo s WHERE s.status = com.internshipapp.entities.StudentInfo.StudentStatus.Available",
                    Long.class
            );
            return typedQuery.getSingleResult();
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public void createStudent(String firstName, String middleName, String lastName,
                              Integer studyYear, Float lastYearGrade) {
        LOG.info("createStudent");
        try {
            StudentInfo student = new StudentInfo();
            student.setFirstName(firstName);
            student.setMiddleName(middleName);
            student.setLastName(lastName);
            student.setStudyYear(studyYear);
            student.setLastYearGrade(lastYearGrade);
            student.setStatus(StudentInfo.StudentStatus.Available);
            student.setEnrolled(true);

            entityManager.persist(student);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public void updateStudent(Long studentId, String firstName, String middleName,
                              String lastName, Integer studyYear, Float lastYearGrade,
                              String status, Boolean enrolled) {
        LOG.info("updateStudent: " + studentId);
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null) {
                student.setFirstName(firstName);
                student.setMiddleName(middleName);
                student.setLastName(lastName);
                student.setStudyYear(studyYear);
                student.setLastYearGrade(lastYearGrade);
                student.setStatus(StudentInfo.StudentStatus.valueOf(status));
                student.setEnrolled(enrolled);

                entityManager.merge(student);
            }
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public void deleteStudent(Long studentId) {
        LOG.info("deleteStudent: " + studentId);
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null) {
                entityManager.remove(student);
            }
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public List<StudentInfoDto> findByStatus(String status) {
        LOG.info("findByStatus: " + status);
        try {
            StudentInfo.StudentStatus studentStatus = StudentInfo.StudentStatus.valueOf(status);
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery(
                    "SELECT s FROM StudentInfo s WHERE s.status = :status",
                    StudentInfo.class
            );
            typedQuery.setParameter("status", studentStatus);
            List<StudentInfo> students = typedQuery.getResultList();
            return copyStudentsToDto(students);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public List<StudentInfoDto> findByStudyYear(Integer studyYear) {
        LOG.info("findByStudyYear: " + studyYear);
        try {
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery(
                    "SELECT s FROM StudentInfo s WHERE s.studyYear = :studyYear",
                    StudentInfo.class
            );
            typedQuery.setParameter("studyYear", studyYear);
            List<StudentInfo> students = typedQuery.getResultList();
            return copyStudentsToDto(students);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    // NEW METHODS FOR STATISTICS AND DASHBOARD

    public Map<String, Integer> getStatusDistribution() {
        LOG.info("getStatusDistribution");
        try {
            TypedQuery<Object[]> query = entityManager.createQuery(
                    "SELECT s.status, COUNT(s) FROM StudentInfo s GROUP BY s.status",
                    Object[].class
            );
            List<Object[]> results = query.getResultList();

            Map<String, Integer> distribution = new HashMap<>();
            for (Object[] result : results) {
                StudentInfo.StudentStatus status = (StudentInfo.StudentStatus) result[0];
                Long count = (Long) result[1];
                distribution.put(status.toString(), count.intValue());
            }
            return distribution;
        } catch (Exception ex) {
            LOG.warning("Error getting status distribution: " + ex.getMessage());
            return new HashMap<>();
        }
    }

    public Map<Integer, Integer> getYearDistribution() {
        LOG.info("getYearDistribution");
        try {
            TypedQuery<Object[]> query = entityManager.createQuery(
                    "SELECT s.studyYear, COUNT(s) FROM StudentInfo s GROUP BY s.studyYear ORDER BY s.studyYear",
                    Object[].class
            );
            List<Object[]> results = query.getResultList();

            Map<Integer, Integer> distribution = new TreeMap<>();
            for (Object[] result : results) {
                Integer year = (Integer) result[0];
                Long count = (Long) result[1];
                distribution.put(year, count.intValue());
            }
            return distribution;
        } catch (Exception ex) {
            LOG.warning("Error getting year distribution: " + ex.getMessage());
            return new TreeMap<>();
        }
    }

    public double getAverageGrade() {
        LOG.info("getAverageGrade");
        try {
            TypedQuery<Double> query = entityManager.createQuery(
                    "SELECT AVG(s.lastYearGrade) FROM StudentInfo s WHERE s.lastYearGrade IS NOT NULL",
                    Double.class
            );
            Double avg = query.getSingleResult();
            return avg != null ? avg : 0.0;
        } catch (Exception ex) {
            LOG.warning("Error getting average grade: " + ex.getMessage());
            return 0.0;
        }
    }

    public int getEnrolledCount() {
        LOG.info("getEnrolledCount");
        try {
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(s) FROM StudentInfo s WHERE s.enrolled = true",
                    Long.class
            );
            Long count = query.getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception ex) {
            LOG.warning("Error getting enrolled count: " + ex.getMessage());
            return 0;
        }
    }

    public Map<String, Object> getStudentStatistics() {
        LOG.info("getStudentStatistics");
        Map<String, Object> stats = new HashMap<>();

        try {
            stats.put("totalStudents", countStudents());
            stats.put("availableStudents", countAvailableStudents());
            stats.put("enrolledStudents", getEnrolledCount());
            stats.put("averageGrade", String.format("%.2f", getAverageGrade()));
            stats.put("statusDistribution", getStatusDistribution());
            stats.put("yearDistribution", getYearDistribution());

            // Calculate completion rate
            long total = countStudents();
            long completed = 0;
            Map<String, Integer> statusDist = getStatusDistribution();
            if (statusDist.containsKey("Completed")) {
                completed = statusDist.get("Completed");
            }
            double completionRate = total > 0 ? (completed * 100.0 / total) : 0;
            stats.put("completionRate", String.format("%.1f%%", completionRate));

        } catch (Exception ex) {
            LOG.warning("Error getting student statistics: " + ex.getMessage());
        }

        return stats;
    }
}