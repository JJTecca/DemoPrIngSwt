package com.internshipapp.ejb;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.entities.*;
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
                    app.getInterview(),
                    app.getInterviewLocation(),
                    app.isChatInitiated(),
                    posTitle,
                    compName,
                    compId,
                    description,
                    requirements,
                    deadline
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
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        InternshipPosition position = entityManager.find(InternshipPosition.class, positionId);

        if (student == null || position == null) {
            throw new IllegalArgumentException("Invalid Student or Position ID");
        }

        if (position.getStatus() == InternshipPosition.PositionStatus.Closed) {
            throw new IllegalStateException("This position is no longer accepting applications.");
        }

        if (position.getDeadline() != null && position.getDeadline().before(new Date())) {
            position.setStatus(InternshipPosition.PositionStatus.Closed);
            entityManager.merge(position);
            throw new IllegalStateException("The application deadline has passed.");
        }

        // NEW HARDLOCK: Check if position is full
        int max = (position.getMaxSpots() != null) ? position.getMaxSpots() : 0;
        int accepted = (position.getAcceptedCount() != null) ? position.getAcceptedCount() : 0;

        if (accepted >= max && max > 0) {
            throw new IllegalStateException("This position has already been filled (" + accepted + "/" + max + ").");
        }

        // Existing Student Status check
        if (student.getStatus() != StudentInfo.StudentStatus.Available) {
            throw new IllegalStateException("Your current status is " + student.getStatus() + ".");
        }

        // Duplicate check...
        Long count = entityManager.createQuery(
                        "SELECT COUNT(a) FROM InternshipApplication a WHERE a.student.id = :sid AND a.internshipPosition.id = :pid", Long.class)
                .setParameter("sid", studentId)
                .setParameter("pid", positionId)
                .getSingleResult();

        if (count > 0) throw new IllegalStateException("Already applied");

        InternshipApplication app = new InternshipApplication();
        app.setStudent(student);
        app.setInternshipPosition(position);
        app.setStatus(InternshipApplication.ApplicationStatus.Pending);
        app.setAppliedAt(LocalDateTime.now());

        if (position.getApplicationsCount() == null) position.setApplicationsCount(0);
        position.setApplicationsCount(position.getApplicationsCount() + 1);

        entityManager.persist(app);
        entityManager.merge(position);

        return position.getTitle();
    }

    public void updateApplicationStatus(Long appId, String statusName) {
        try {
            InternshipApplication app = entityManager.find(InternshipApplication.class, appId);
            InternshipPosition pos = app.getInternshipPosition();
            StudentInfo student = app.getStudent();

            InternshipApplication.ApplicationStatus targetStatus =
                    InternshipApplication.ApplicationStatus.valueOf(statusName);

            // 1. ILLEGAL SCENARIO: If trying to move to 'Discussion' (Student clicked "Accept")
            if (targetStatus == InternshipApplication.ApplicationStatus.Discussion) {
                if (app.getStatus() != InternshipApplication.ApplicationStatus.Request) {
                    LOG.warning("BLOCKED: Attempt to move App " + appId + " to Discussion from " + app.getStatus());
                    throw new IllegalStateException("You can only accept an interview if it was explicitly requested.");
                }
            }

            // 3. ILLEGAL SCENARIO: If the application is currently a 'Request'
            if (app.getStatus() == InternshipApplication.ApplicationStatus.Request) {

                // Block Company from moving it back to Pending or straight to Interview
                if (targetStatus == InternshipApplication.ApplicationStatus.Pending ||
                        targetStatus == InternshipApplication.ApplicationStatus.Interview) {

                    LOG.warning("SECURITY ALERT: Attempt to bypass workflow. Cannot move 'Request' to '" + statusName + "'");
                    throw new IllegalStateException("This application is waiting for a student response. You cannot change the state manually.");
                }
            }

            // 4. ILLEGAL SCENARIO: Status Regression
            if (app.getStatus() == InternshipApplication.ApplicationStatus.Accepted ||
                    student.getStatus() == StudentInfo.StudentStatus.Completed) {
                throw new IllegalStateException("Finalized applications cannot be modified.");
            }

            // 5. ILLEGAL SCENARIO: Prevent restoring a rejected app if the student is globally Accepted
            if (app.getStatus() == InternshipApplication.ApplicationStatus.Rejected &&
                    targetStatus == InternshipApplication.ApplicationStatus.Pending) {

                if (student.getStatus() == StudentInfo.StudentStatus.Accepted) {
                    throw new IllegalStateException("Cannot restore application: Student is already accepted for another position.");
                }
            }

            // 6. LOGIC: Moving to "Accepted"
            if (targetStatus == InternshipApplication.ApplicationStatus.Accepted &&
                    app.getStatus() != InternshipApplication.ApplicationStatus.Accepted) {

                // Availability Check
                if (student.getStatus() != StudentInfo.StudentStatus.Available) {
                    throw new IllegalStateException("Cannot accept: Student is already committed elsewhere.");
                }

                // Capacity Check
                int max = (pos.getMaxSpots() != null) ? pos.getMaxSpots() : 0;
                int current = (pos.getAcceptedCount() != null) ? pos.getAcceptedCount() : 0;

                // A. Is it filled?
                if (current >= max && max > 0) {
                    // Just in case the status didn't sync, force close it now
                    pos.setStatus(InternshipPosition.PositionStatus.Closed);
                    entityManager.merge(pos);
                    throw new IllegalStateException("Cannot accept student: Position capacity reached.");
                }

                // B. Increment accepted count
                pos.setAcceptedCount(current + 1);

                // C. SYNC: If position is now full, Close it AND Reject ALL OTHER APPLICANTS FOR THIS POSITION
                if (pos.getAcceptedCount() >= max && max > 0) {
                    pos.setStatus(InternshipPosition.PositionStatus.Closed);

                    entityManager.createQuery(
                                    "UPDATE InternshipApplication a SET a.status = :rejected " +
                                            "WHERE a.internshipPosition.id = :pid " +
                                            "AND a.id <> :currentAppId " +
                                            "AND a.status <> :accepted") // Leave accepted applicants alone
                            .setParameter("rejected", InternshipApplication.ApplicationStatus.Rejected)
                            .setParameter("pid", pos.getId())
                            .setParameter("currentAppId", app.getId())
                            .setParameter("accepted", InternshipApplication.ApplicationStatus.Accepted)
                            .executeUpdate();
                }

                // D. CASCADE REJECTION: Reject all other applications for THIS STUDENT
                entityManager.createQuery(
                                "UPDATE InternshipApplication a SET a.status = :rejected " +
                                        "WHERE a.student.id = :sid " +
                                        "AND a.id <> :currentAppId " +
                                        "AND a.status <> :accepted")
                        .setParameter("rejected", InternshipApplication.ApplicationStatus.Rejected)
                        .setParameter("sid", student.getId())
                        .setParameter("currentAppId", app.getId())
                        .setParameter("accepted", InternshipApplication.ApplicationStatus.Accepted)
                        .executeUpdate();

                // E. Final Student/Position Sync
                student.setStatus(StudentInfo.StudentStatus.Accepted);
                entityManager.merge(pos);
                entityManager.merge(student);
            }

            // the company can use the "Initial Message" flow again to move back to Discussion.
            if (targetStatus == InternshipApplication.ApplicationStatus.Rejected) {
                app.setChatInitiated(false);
                LOG.info("Chat reset for Application ID: " + appId + " due to Rejection.");
            }

            app.setStatus(targetStatus);
            entityManager.merge(app);

        } catch (Exception e) {
            LOG.severe("Update failed: " + e.getMessage());
            throw new EJBException(e.getMessage());
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
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        InternshipPosition pos = entityManager.find(InternshipPosition.class, positionId);

        if (student == null || pos == null) {
            throw new IllegalArgumentException("Invalid Student or Position ID");
        }

        // Faculty-level validation
        if (student.getStatus() != StudentInfo.StudentStatus.Available) {
            throw new IllegalStateException("Student is already accepted for another role.");
        }

        if (pos.getAcceptedCount() >= pos.getMaxSpots()) {
            throw new IllegalStateException("Tutoring position is already full.");
        }

        // Ensure application exists
        InternshipApplication targetApp = findApplication(studentId, positionId);
        if (targetApp == null) {
            createApplication(studentId, positionId);
            targetApp = findApplication(studentId, positionId);
        }

        // DELEGATE: Use the centralized logic to handle rejections, counts, and status sync
        updateApplicationStatus(targetApp.getId(), "Accepted");
    }

    public List<InternshipApplicationDto> getApplicationsForUser(Long userId, String role) {
        // 1. Resolve the specific Info ID from the UserAccount
        UserAccount user = entityManager.find(UserAccount.class, userId);
        if (user == null) return new ArrayList<>();

        // 2. Route based on role
        if ("Student".equals(role) && user.getStudentInfo() != null) {
            return findApplicationsByStudentId(user.getStudentInfo().getId());
        }

        // Faculty and Company both use the CompanyInfo relationship
        if (("Company".equals(role) || "Faculty".equals(role)) && user.getCompanyInfo() != null) {
            return findApplicationsByCompanyId(user.getCompanyInfo().getId());
        }

        return new ArrayList<>();
    }

    public InternshipApplicationDto getApplicationDtoById(Long appId) {
        try {
            // Fetch with all necessary joins to prevent LazyInitializationException in the DTO copier
            TypedQuery<InternshipApplication> query = entityManager.createQuery(
                    "SELECT a FROM InternshipApplication a " +
                            "JOIN FETCH a.student s " +
                            "JOIN FETCH a.internshipPosition p " +
                            "JOIN FETCH p.company c " +
                            "WHERE a.id = :appId", InternshipApplication.class);

            query.setParameter("appId", appId);
            InternshipApplication entity = query.getSingleResult();

            // Wrap in a list because copyApplicationsToDto expects a list
            List<InternshipApplication> list = new ArrayList<>();
            list.add(entity);

            List<InternshipApplicationDto> dtos = copyApplicationsToDto(list);
            return dtos.isEmpty() ? null : dtos.get(0);

        } catch (NoResultException e) {
            LOG.warning("No application found with ID: " + appId);
            return null;
        } catch (Exception e) {
            LOG.severe("Error fetching application DTO: " + e.getMessage());
            return null;
        }
    }

    public void initiateInterviewRequest(Long studentId, Long positionId, String initialMessage, Long senderUserId) throws Exception {
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        InternshipPosition position = entityManager.find(InternshipPosition.class, positionId);
        UserAccount sender = entityManager.find(UserAccount.class, senderUserId);

        // 1. Fetch current application if it exists
        TypedQuery<InternshipApplication> query = entityManager.createQuery(
                "SELECT a FROM InternshipApplication a WHERE a.student.id = :sid AND a.internshipPosition.id = :pid",
                InternshipApplication.class);
        query.setParameter("sid", studentId).setParameter("pid", positionId);

        List<InternshipApplication> results = query.getResultList();

        if (!results.isEmpty()) {
            InternshipApplication existing = results.get(0);
            // HARDLOCK: If it's already Pending, do NOT allow moving to Request
            if (existing.getStatus() == InternshipApplication.ApplicationStatus.Pending) {
                throw new IllegalStateException("Student already applied. Please use the Chat function.");
            }
        }

        if (student == null || position == null || sender == null) {
            throw new IllegalArgumentException("Invalid data provided for request.");
        }

        // Check if student is already hired elsewhere
        if (student.getStatus() == StudentInfo.StudentStatus.Accepted) {
            throw new IllegalStateException("Student is already accepted for another internship.");
        }

        // Check if an application already exists
        InternshipApplication app = findApplication(studentId, positionId);

        if (app == null) {
            // Create NEW application with 'Request' status
            app = new InternshipApplication();
            app.setStudent(student);
            app.setInternshipPosition(position);
            app.setStatus(InternshipApplication.ApplicationStatus.Request); // Critical Change
            app.setAppliedAt(LocalDateTime.now());
            app.setChatInitiated(true); // Since company is messaging first

            // Update position application count
            position.setApplicationsCount((position.getApplicationsCount() != null ? position.getApplicationsCount() : 0) + 1);

            entityManager.persist(app);
            entityManager.merge(position);
        } else {
            // If it exists (e.g. Student applied earlier), we move it to Discussion/Interview
            // depending on your preference. For now, let's just update the existing one to Request
            app.setStatus(InternshipApplication.ApplicationStatus.Request);
            entityManager.merge(app);
        }

        // Persist the initial message in the Chat system
        Message msg = new Message();
        msg.setApplication(app);
        msg.setSender(sender);
        msg.setMessageText(initialMessage);
        msg.setSenderRole(Message.SenderRole.Company); // Assuming sender is company/faculty
        msg.setTimeSent(LocalDateTime.now());

        entityManager.persist(msg);
    }

    public UserAccount getUserAccountById(Long userId) {
        try {
            // We use LEFT JOIN FETCH because a user will have either studentInfo or companyInfo, but not both.
            // This ensures the associated objects are loaded in a single database hit.
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u " +
                            "LEFT JOIN FETCH u.studentInfo " +
                            "LEFT JOIN FETCH u.companyInfo " +
                            "WHERE u.id = :userId", UserAccount.class);

            query.setParameter("userId", userId);
            return query.getSingleResult();

        } catch (NoResultException e) {
            LOG.warning("UserAccount not found for ID: " + userId);
            return null;
        } catch (Exception e) {
            LOG.severe("Error retrieving UserAccount: " + e.getMessage());
            return null;
        }
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