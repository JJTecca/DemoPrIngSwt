package com.internshipapp.ejb;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.entities.InternshipApplication;
import com.internshipapp.entities.InternshipPosition;
import com.internshipapp.entities.StudentInfo;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
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
            Long compId = null;
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
                    compId = pos.getCompany().getId();
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
                    app.getStudent().getFullName(),
                    app.getStudent().getStatus().toString(),
                    app.getStatus().toString(),
                    app.getGrade(),
                    app.getStudent().getLastYearGrade(),
                    app.getStudent().getGradeVisibility(),
                    app.getAppliedAt(),
                    app.getChatIds(),
                    posTitle,
                    compName,
                    compId,
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
            // 1. Fetch the Entities with JOIN FETCH
            TypedQuery<InternshipApplication> query = entityManager.createQuery(
                    "SELECT a FROM InternshipApplication a " +
                            "JOIN FETCH a.student " +
                            "JOIN FETCH a.internshipPosition p " +
                            "LEFT JOIN FETCH p.company " + // Good for fetching company details too
                            "WHERE p.company.id = :companyId",
                    InternshipApplication.class
            );
            query.setParameter("companyId", companyId);
            List<InternshipApplication> entities = query.getResultList();

            // 2. CRITICAL CHANGE: Use the helper method!
            // This method contains the line: app.getStudent().getLastYearGrade()
            return copyApplicationsToDto(entities);

        } catch (Exception e) {
            LOG.warning("Error in findApplicationsByCompanyId: " + e.getMessage());
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

        // HARDLOCK: Prevent applications if the student is already "Accepted" or "Completed"
        // This handles Rule #2: A student cannot apply if they already have an internship.
        if (student.getStatus() != StudentInfo.StudentStatus.Available) {
            throw new IllegalStateException("Your current status is " + student.getStatus() +
                    ". You can only apply for new positions if your status is 'Available'.");
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

    public void updateApplicationStatus(Long appId, String statusName) {
        LOG.info("Updating application #" + appId + " to status: " + statusName);
        try {
            // 1. Find the managed entity
            InternshipApplication app = entityManager.find(InternshipApplication.class, appId);
            StudentInfo.StudentStatus studentStatus = app.getStudent().getStatus();
            if (statusName.equalsIgnoreCase("Pending") && app.getStatus().name().equalsIgnoreCase("Rejected")) {
                if (studentStatus != StudentInfo.StudentStatus.Available) {
                    throw new IllegalStateException("Cannot restore application: Student is already accepted to another position.");
                }
            }

            // 2. Convert String to Enum (Case-insensitive check is safer)
            // This assumes your Enum is named ApplicationStatus inside InternshipApplication
            InternshipApplication.ApplicationStatus targetStatus =
                    InternshipApplication.ApplicationStatus.valueOf(statusName);

            // 3. Apply the update
            app.setStatus(targetStatus);

            // 4. Persistence
            entityManager.merge(app);

            LOG.info("Successfully updated application #" + appId + " to " + targetStatus);
        } catch (IllegalArgumentException e) {
            LOG.severe("Invalid status value provided: " + statusName);
            throw new EJBException("Invalid status update: " + statusName);
        } catch (Exception e) {
            LOG.severe("Failed to update application status: " + e.getMessage());
            throw new EJBException(e);
        }
    }

    public InternshipApplication findApplication(Long studentId, Long positionId) {
        try {
            return entityManager.createQuery(
                            "SELECT a FROM InternshipApplication a WHERE a.student.id = :sid AND a.internshipPosition.id = :pid",
                            InternshipApplication.class)
                    .setParameter("sid", studentId)
                    .setParameter("pid", positionId)
                    .getSingleResult();
        } catch (NoResultException e) {
            return null;
        }
    }

    public void assignStudentAndCleanUp(Long studentId, Long positionId) throws Exception {
        // 1. Fetch Student first to verify eligibility
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        if (student == null) {
            throw new IllegalArgumentException("Student not found.");
        }

        // RULE 1: Hardlock - Prevent assigning Tutoring roles to students already accepted elsewhere
        if (student.getStatus() != StudentInfo.StudentStatus.Available) {
            throw new IllegalStateException("Student is already accepted for an internship and cannot take a tutoring role.");
        }

        // 2. Get or Create the application
        InternshipApplication targetApp = findApplication(studentId, positionId);

        if (targetApp == null) {
            // This will now also trigger the check in createApplication (if you updated it)
            createApplication(studentId, positionId);
            targetApp = findApplication(studentId, positionId);
        }

        // 3. Force application status to Accepted
        targetApp.setStatus(InternshipApplication.ApplicationStatus.Accepted);
        entityManager.merge(targetApp);

        // 4. Update Student Table status to Accepted
        student.setStatus(StudentInfo.StudentStatus.Accepted);
        entityManager.merge(student);

        // 5. Cascade Rejection: Reject all other pending applications for this student
        entityManager.createQuery(
                        "UPDATE InternshipApplication a SET a.status = :rejectedStatus " +
                                "WHERE a.student.id = :sid " +
                                "AND a.id <> :currentId " +
                                "AND a.status <> :acceptedStatus")
                .setParameter("rejectedStatus", InternshipApplication.ApplicationStatus.Rejected)
                .setParameter("sid", studentId)
                .setParameter("currentId", targetApp.getId())
                .setParameter("acceptedStatus", InternshipApplication.ApplicationStatus.Accepted)
                .executeUpdate();
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