package com.internshipapp.ejb;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.entities.InternshipApplication;
import com.internshipapp.entities.InternshipPosition;
import com.internshipapp.entities.StudentInfo;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
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
public class InternshipApplicationBean {
    private static final Logger LOG = Logger.getLogger(InternshipApplicationBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<InternshipApplicationDto> copyApplicationsToDto(List<InternshipApplication> applications) {
        List<InternshipApplicationDto> dtos = new ArrayList<>();

        for (InternshipApplication app : applications) {
            // Default values to avoid NullPointerExceptions
            String posTitle = "Unknown Position";
            String compName = "Unknown Company";
            String description = "No description available.";
            String requirements = "No requirements specified.";
            Date deadline = null;

            // 1. Get the Position Entity
            InternshipPosition pos = app.getInternshipPosition();

            if (pos != null) {
                // 2. Get Basic Details
                if (pos.getTitle() != null) {
                    posTitle = pos.getTitle();
                }

                // 3. Get Company Name
                if (pos.getCompany() != null && pos.getCompany().getName() != null) {
                    compName = pos.getCompany().getName();
                }

                // 4. Get Extended Details for Popup (NEW LOGIC)
                if (pos.getDescription() != null) {
                    description = pos.getDescription();
                }
                if (pos.getRequirements() != null) {
                    requirements = pos.getRequirements();
                }
                if (pos.getDeadline() != null) {
                    deadline = pos.getDeadline();
                }
            }

            // 5. Create DTO using the NEW 12-parameter constructor
            InternshipApplicationDto dto = new InternshipApplicationDto(
                    app.getId(),
                    pos != null ? pos.getId() : null,
                    app.getStudent().getId(),
                    app.getStatus().toString(),
                    app.getGrade(),
                    app.getAppliedAt(),
                    app.getChatIds(),
                    posTitle,
                    compName,
                    description,   // Passed here
                    requirements,  // Passed here
                    deadline       // Passed here
            );
            dtos.add(dto);
        }
        return dtos;
    }

    public List<InternshipApplicationDto> findApplicationsByCompanyId(Long companyId) {
        try {
            // We JOIN FETCH the student so the name is available in memory
            TypedQuery<InternshipApplication> query = entityManager.createQuery(
                    "SELECT a FROM InternshipApplication a " +
                            "JOIN FETCH a.student " +
                            "JOIN FETCH a.internshipPosition p " +
                            "WHERE p.company.id = :companyId",
                    InternshipApplication.class
            );
            query.setParameter("companyId", companyId);
            List<InternshipApplication> entities = query.getResultList();

            List<InternshipApplicationDto> dtos = new ArrayList<>();
            for (InternshipApplication entity : entities) {
                // Use the empty constructor + setters to be safe and clear
                InternshipApplicationDto dto = new InternshipApplicationDto();
                dto.setId(entity.getId());
                dto.setStudentId(entity.getStudent().getId());

                // CONSTRUCT THE NAME HERE
                dto.setStudentName(entity.getStudent().getFirstName() + " " + entity.getStudent().getLastName());

                dto.setStatus(entity.getStatus().name());
                dto.setPositionTitle(entity.getInternshipPosition().getTitle());
                dtos.add(dto);
            }
            return dtos;
        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    public long countApplicationsByCompanyId(Long companyId) {
        try {
            // JPQL COUNT Query: Efficiently calculates the number of applications
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(a) FROM InternshipApplication a JOIN a.internshipPosition p " +
                            "WHERE p.company.id = :companyId",
                    Long.class
            );
            query.setParameter("companyId", companyId);

            return query.getSingleResult();

        } catch (Exception ex) {
            // Log the exception, but return 0 gracefully.
            // LOG.log(Level.SEVERE, "Error counting applications for company ID " + companyId, ex);
            return 0L;
        }
    }

    public List<InternshipApplicationDto> findApplicationsByStudentId(Long studentId) {
        LOG.info("findApplicationsByStudentId: " + studentId);
        try {
            // Join Fetch ensures we load the Position and Company data in one query (Performance optimization)
            TypedQuery<InternshipApplication> query = entityManager.createQuery(
                    "SELECT a FROM InternshipApplication a " +
                            "LEFT JOIN FETCH a.internshipPosition p " +
                            "LEFT JOIN FETCH p.company " +
                            "WHERE a.student.id = :studentId " +
                            "ORDER BY a.appliedAt DESC",
                    InternshipApplication.class
            );
            query.setParameter("studentId", studentId);
            return copyApplicationsToDto(query.getResultList());
        } catch (Exception ex) {
            LOG.warning("Error finding applications: " + ex.getMessage());
            return new ArrayList<>();
        }
    }

    public List<Long> getAppliedPositionIds(Long studentId) {
        return entityManager.createQuery(
                        "SELECT a.internshipPosition.id FROM InternshipApplication a WHERE a.student.id = :sid", Long.class)
                .setParameter("sid", studentId)
                .getResultList();
    }

    public String createApplication(Long studentId, Long positionId) throws Exception {
        // 1. Find Entities
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        InternshipPosition position = entityManager.find(InternshipPosition.class, positionId);

        if (student == null || position == null) {
            throw new IllegalArgumentException("Invalid Student or Position ID");
        }

        // 2. Check for Duplicates (Prevent applying twice)
        Long count = entityManager.createQuery(
                        "SELECT COUNT(a) FROM InternshipApplication a WHERE a.student.id = :sid AND a.internshipPosition.id = :pid", Long.class)
                .setParameter("sid", studentId)
                .setParameter("pid", positionId)
                .getSingleResult();

        if (count > 0) {
            throw new IllegalStateException("Already applied");
        }

        // 3. Create Entity
        InternshipApplication app = new InternshipApplication();
        app.setStudent(student);
        app.setInternshipPosition(position);
        app.setStatus(InternshipApplication.ApplicationStatus.Pending); // Assuming Enum exists
        app.setChatIds("[]");
        app.setAppliedAt(LocalDateTime.now());

        // 4. Update Position Counters (Optional but recommended)
        if (position.getApplicationsCount() == null) position.setApplicationsCount(0);
        position.setApplicationsCount(position.getApplicationsCount() + 1);

        entityManager.persist(app);
        entityManager.merge(position);

        // Return title for the Activity Log
        return position.getTitle();
    }

    public List<InternshipApplicationDto> findAllApplications() {
        LOG.info("findAllApplications");
        try {
            TypedQuery<InternshipApplication> typedQuery = entityManager.createQuery("SELECT a FROM InternshipApplication a", InternshipApplication.class);
            List<InternshipApplication> applications = typedQuery.getResultList();
            return copyApplicationsToDto(applications);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}