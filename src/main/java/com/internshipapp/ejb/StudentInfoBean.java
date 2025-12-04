package com.internshipapp.ejb;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.entities.StudentInfo;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.ArrayList;
import java.util.List;
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
            StudentInfoDto studentDto = new StudentInfoDto(
                    student.getId(),
                    student.getAttachment() != null ? student.getAttachment().getId() : null,
                    student.getFirstName(),
                    student.getMiddleName(),
                    student.getLastName(),
                    student.getStudyYear(),
                    student.getLastYearGrade(),
                    student.getStatus().toString(),
                    student.getEnrolled()
            );
            dtos.add(studentDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
    public List<StudentInfoDto> findAllStudents() {
        LOG.info("findAllStudents");
        try {
            TypedQuery<StudentInfo> typedQuery = entityManager.createQuery("SELECT s FROM StudentInfo s", StudentInfo.class);
            List<StudentInfo> students = typedQuery.getResultList();
            return copyStudentsToDto(students);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

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

    public StudentInfoDto findById(Long studentId) {
        LOG.info("findById: " + studentId);
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null) {
                return new StudentInfoDto(
                        student.getId(),
                        student.getAttachment() != null ? student.getAttachment().getId() : null,
                        student.getFirstName(),
                        student.getMiddleName(),
                        student.getLastName(),
                        student.getStudyYear(),
                        student.getLastYearGrade(),
                        student.getStatus().toString(),
                        student.getEnrolled()
                );
            }
            return null;
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
}