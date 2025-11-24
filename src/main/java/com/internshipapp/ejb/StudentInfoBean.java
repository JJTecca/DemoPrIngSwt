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

    @PersistenceContext
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
}