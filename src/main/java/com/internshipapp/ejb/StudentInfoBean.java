package com.internshipapp.ejb;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.entities.Attachment;
import com.internshipapp.entities.StudentInfo;
import com.internshipapp.entities.UserAccount;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
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

        // 1. Get User Account Info
        String userEmail = null;
        String username = null;
        Long userId = null;

        try {
            TypedQuery<UserAccount> userQuery = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.studentInfo = :student",
                    UserAccount.class
            );
            userQuery.setParameter("student", student);
            List<UserAccount> accounts = userQuery.getResultList();

            if (!accounts.isEmpty()) {
                userEmail = accounts.get(0).getEmail();
                username = accounts.get(0).getUsername();
                userId = accounts.get(0).getUserId();
            }
        } catch (Exception e) {
            // Log silently
        }

        // 2. ATTACHMENT LOGIC (Simplified: Using your Entity Flags)
        com.internshipapp.common.AttachmentDto attachmentDto = null;

        if (student.getAttachment() != null) {
            // We reload the attachment to ensure we have the latest boolean flags
            // and avoid any stale proxy state.
            Attachment att = entityManager.find(Attachment.class, student.getAttachment().getId());

            if (att != null) {
                // DIRECTLY READ THE FLAGS from your Entity
                // This avoids all complex SQL queries and syntax errors.
                boolean hasCv = (att.hasCv() != null && att.hasCv());
                boolean hasPfp = (att.hasProfilePic() != null && att.hasProfilePic());

                attachmentDto = new com.internshipapp.common.AttachmentDto(
                        att.getId(),
                        hasCv,
                        hasPfp
                );
            }
        }

        // 3. Return StudentInfoDto
        return new StudentInfoDto(
                student.getId(),
                student.getFirstName(),
                student.getMiddleName(),
                student.getLastName(),
                student.getStudyYear(),
                student.getLastYearGrade(),
                student.getStatus().toString(),
                student.getEnrolled(),
                userEmail,
                username,
                userId,
                attachmentDto,
                student.getBiography()
        );
    }

    // --- Standard CRUD Methods ---

    public List<StudentInfoDto> findAllStudents() {
        LOG.info("findAllStudents");
        try {
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery(
                    "SELECT s FROM StudentInfo s", StudentInfo.class);
            return copyStudentsToDto(typedQuery.getResultList());
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
            TypedQuery<UserAccount> userQuery = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.email = :email", UserAccount.class);
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

    // --- Operations ---

    public long countStudents() {
        try {
            return entityManager.createQuery("SELECT COUNT(s) FROM StudentInfo s", Long.class).getSingleResult();
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public long countAvailableStudents() {
        try {
            return entityManager.createQuery(
                    "SELECT COUNT(s) FROM StudentInfo s WHERE s.status = com.internshipapp.entities.StudentInfo.StudentStatus.Available",
                    Long.class
            ).getSingleResult();
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public void createStudent(String firstName, String middleName, String lastName, Integer studyYear, Float lastYearGrade) {
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

    private Object[] getAttachmentStatusByStudentId(Long studentId) {
        try {
            // Query to get the Attachment ID and the boolean flags directly
            TypedQuery<Object[]> query = entityManager.createQuery(
                    "SELECT s.attachment.id, s.attachment.hasCv, s.attachment.hasProfilePic " +
                            "FROM StudentInfo s WHERE s.id = :sid",
                    Object[].class
            );
            query.setParameter("sid", studentId);

            // Use getSingleResult() because we expect one row
            return query.getSingleResult();

        } catch (Exception e) {
            // Log quietly if no attachment is linked or other fetch error
            return null;
        }
    }

    public void updateStudent(Long studentId, String firstName, String middleName, String lastName,
                              Integer studyYear, Float lastYearGrade, String status, Boolean enrolled,
                              String biography) {
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

                student.setBiography(biography);

                entityManager.merge(student);
            }
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public void deleteStudent(Long studentId) {
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
        try {
            StudentInfo.StudentStatus studentStatus = StudentInfo.StudentStatus.valueOf(status);
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery(
                    "SELECT s FROM StudentInfo s WHERE s.status = :status", StudentInfo.class);
            typedQuery.setParameter("status", studentStatus);
            return copyStudentsToDto(typedQuery.getResultList());
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public List<StudentInfoDto> findByStudyYear(Integer studyYear) {
        try {
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery(
                    "SELECT s FROM StudentInfo s WHERE s.studyYear = :studyYear", StudentInfo.class);
            typedQuery.setParameter("studyYear", studyYear);
            return copyStudentsToDto(typedQuery.getResultList());
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    // --- Statistics ---

    public Map<String, Integer> getStatusDistribution() {
        try {
            List<Object[]> results = entityManager.createQuery(
                    "SELECT s.status, COUNT(s) FROM StudentInfo s GROUP BY s.status", Object[].class).getResultList();
            Map<String, Integer> distribution = new HashMap<>();
            for (Object[] result : results) {
                distribution.put(result[0].toString(), ((Long) result[1]).intValue());
            }
            return distribution;
        } catch (Exception ex) {
            return new HashMap<>();
        }
    }

    public Map<Integer, Integer> getYearDistribution() {
        try {
            List<Object[]> results = entityManager.createQuery(
                    "SELECT s.studyYear, COUNT(s) FROM StudentInfo s GROUP BY s.studyYear ORDER BY s.studyYear",
                    Object[].class).getResultList();
            Map<Integer, Integer> distribution = new TreeMap<>();
            for (Object[] result : results) {
                distribution.put((Integer) result[0], ((Long) result[1]).intValue());
            }
            return distribution;
        } catch (Exception ex) {
            return new TreeMap<>();
        }
    }

    public double getAverageGrade() {
        try {
            Double avg = entityManager.createQuery(
                    "SELECT AVG(s.lastYearGrade) FROM StudentInfo s WHERE s.lastYearGrade IS NOT NULL",
                    Double.class).getSingleResult();
            return avg != null ? avg : 0.0;
        } catch (Exception ex) {
            return 0.0;
        }
    }

    public int getEnrolledCount() {
        try {
            Long count = entityManager.createQuery(
                    "SELECT COUNT(s) FROM StudentInfo s WHERE s.enrolled = true", Long.class).getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception ex) {
            return 0;
        }
    }

    public Map<String, Object> getStudentStatistics() {
        Map<String, Object> stats = new HashMap<>();
        try {
            stats.put("totalStudents", countStudents());
            stats.put("availableStudents", countAvailableStudents());
            stats.put("enrolledStudents", getEnrolledCount());
            stats.put("averageGrade", String.format("%.2f", getAverageGrade()));
            stats.put("statusDistribution", getStatusDistribution());
            stats.put("yearDistribution", getYearDistribution());

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