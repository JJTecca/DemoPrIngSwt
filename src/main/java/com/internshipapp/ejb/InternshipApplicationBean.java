package com.internshipapp.ejb;

import com.internshipapp.commands.InterviewRequestCommand;
import com.internshipapp.commands.UpdateApplicationCommand;
import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.config.ApplicationConfig;
import com.internshipapp.entities.*;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.logging.Logger;

import static org.eclipse.tags.shaded.org.apache.xalan.lib.ExsltDatetime.date;

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

    @Inject
    private ApplicationConfig applicationConfig;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<InternshipApplicationDto> copyApplicationsToDto(List<InternshipApplication> applications) {
        List<InternshipApplicationDto> dtos = new ArrayList<>();

        for (InternshipApplication app : applications) {
            String posTitle = "Unknown Position";
            String compName = "Unknown Company";
            Long compId = null;
            String description = "No description available.";
            String requirements = "No requirements specified.";
            Date deadline = null;

            InternshipPosition pos = app.getInternshipPosition();

            if (pos != null) {
                if (pos.getTitle() != null) {
                    posTitle = pos.getTitle();
                }

                if (pos.getCompany() != null && pos.getCompany().getName() != null) {
                    compId = pos.getCompany().getId();
                    compName = pos.getCompany().getName();
                }

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

            String studentEmail = "N/A";
            if (app.getStudent() != null) {
                UserAccount ua = getUserAccountByStudentId(app.getStudent().getId());
                if (ua != null) {
                    studentEmail = ua.getEmail();
                }
            }

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
                    studentEmail,
                    app.getAppliedAt(),
                    app.getInterview(),
                    app.getInterviewLocation(),
                    app.isChatInitiated(),
                    posTitle,
                    compName,
                    compId,
                    description,
                    requirements,
                    deadline,
                    app.getFeedback()
            );
            dtos.add(dto);
        }
        return dtos;
    }

    public List<InternshipApplicationDto> findApplicationsByCompanyId(Long companyId) {
        try {
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

    public Long createApplication(Long studentId, Long positionId) throws Exception {
        if (!applicationConfig.isApplicationPeriodActive()) {
            throw new IllegalStateException(
                    "Applications are currently closed. " +
                            applicationConfig.getApplicationPeriodStatus()
            );
        }

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

        // Check if position is full
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
        entityManager.flush();

        return app.getId();
    }

    public List<InternshipApplicationDto> getApplicantsForPosition(Long positionId) {
        try {
            // Fetch applications with joined entities to prevent LazyInitializationException in the copier
            TypedQuery<InternshipApplication> query = entityManager.createQuery(
                    "SELECT a FROM InternshipApplication a " +
                            "JOIN FETCH a.student " +
                            "LEFT JOIN FETCH a.internshipPosition p " +
                            "LEFT JOIN FETCH p.company " +
                            "WHERE a.internshipPosition.id = :pid",
                    InternshipApplication.class
            );
            query.setParameter("pid", positionId);
            List<InternshipApplication> results = query.getResultList();

            // Use the centralized conversion method
            return copyApplicationsToDto(results);

        } catch (Exception e) {
            LOG.severe("Error fetching applicants for position " + positionId + ": " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public void updateApplicationStatus(UpdateApplicationCommand cmd) {
        try {
            InternshipApplication app = entityManager.find(InternshipApplication.class, cmd.appId);
            InternshipPosition pos = app.getInternshipPosition();
            StudentInfo student = app.getStudent();

            InternshipApplication.ApplicationStatus targetStatus =
                    InternshipApplication.ApplicationStatus.valueOf(cmd.statusName);

            // 1. RULE: Switching TO Interview requires Date and Location
            if (targetStatus == InternshipApplication.ApplicationStatus.Interview) {
                if (cmd.interviewDate == null || cmd.location == null || cmd.location.isEmpty()) {
                    throw new IllegalStateException("Interview Date and Location are required to schedule an interview.");
                }
                app.setInterview(cmd.interviewDate);
                app.setInterviewLocation(cmd.location);
            }

            // 2. RULE: Switching BACK to Discussion clears Date and Location
            if (targetStatus == InternshipApplication.ApplicationStatus.Discussion &&
                    app.getStatus() == InternshipApplication.ApplicationStatus.Interview) {
                app.setInterview(null);
                app.setInterviewLocation(null);
                LOG.info("Application " + cmd.appId + " moved back to Discussion. Interview data cleared.");
            }

            // 4. ILLEGAL SCENARIO: Status Regression
            if (app.getStatus() == InternshipApplication.ApplicationStatus.Accepted) {
                throw new IllegalStateException("Finalized applications cannot be modified.");
            }

            // 5. ILLEGAL SCENARIO: Prevent restoring a rejected app if the student is globally Accepted
            if (student.getStatus() == StudentInfo.StudentStatus.Accepted ||
                    student.getStatus() == StudentInfo.StudentStatus.Completed) {
                throw new IllegalStateException("Cannot restore application: Student is already accepted for another position.");
            }

            // 6. ILLEGAL SCENARIO: Restoring from Rejected
            if (app.getStatus() == InternshipApplication.ApplicationStatus.Rejected) {
                throw new IllegalStateException("Cannot restore application: Student is already rejected for this position.");
            }

            // 7. ILLEGAL SCENARIO: Update to Pending
            if (targetStatus == InternshipApplication.ApplicationStatus.Pending) {
                throw new IllegalStateException("Cannot regress to Pending.");
            }

            // 8. LOGIC: Moving to "Accepted" (Faculty can accept from any status)
            if (targetStatus == InternshipApplication.ApplicationStatus.Accepted &&
                    (app.getStatus() == InternshipApplication.ApplicationStatus.Interview ||
                            "Faculty".equals(cmd.role))) {

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

            app.setStatus(targetStatus);
            entityManager.merge(app);

        } catch (Exception e) {
            LOG.severe("Update failed: " + e.getMessage());
            throw new EJBException(e.getMessage());
        }
    }

    public void submitFinalEvaluation(Long appId, Float grade, String feedback, Long studentId) {
        InternshipApplication app = entityManager.find(InternshipApplication.class, appId);

        if (app != null) {
            app.setGrade(grade);
            app.setFeedback(feedback);
            entityManager.merge(app);

            if (studentId != null) {
                StudentInfo student = entityManager.find(StudentInfo.class, studentId);
                if (student != null) {
                    student.setStatus(StudentInfo.StudentStatus.Completed);
                    entityManager.merge(student);
                }
            }
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

    public InternshipApplicationDto findApplicationDto(Long studentId, Long positionId) {
        try {
            InternshipApplication result =  entityManager.createQuery(
                            "SELECT a FROM InternshipApplication a WHERE a.student.id = :sid AND a.internshipPosition.id = :pid",
                            InternshipApplication.class)
                    .setParameter("sid", studentId)
                    .setParameter("pid", positionId)
                    .getSingleResult();
            List<InternshipApplication> applications = new ArrayList<>();
            applications.add(result);
            return copyApplicationsToDto(applications).getFirst();
        } catch (NoResultException e) {
            return null;
        }
    }

    public void assignStudentAndCleanUp(Long studentId, Long positionId, String role) throws Exception {
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
        UpdateApplicationCommand cmd = new UpdateApplicationCommand(targetApp.getId(), "Accepted",
                null, null, role);
        updateApplicationStatus(cmd);
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

    public void initiateInterviewRequest(InterviewRequestCommand cmd) throws Exception {
        StudentInfo student = entityManager.find(StudentInfo.class, cmd.studentId);
        InternshipPosition position = entityManager.find(InternshipPosition.class, cmd.positionId);
        UserAccount sender = entityManager.find(UserAccount.class, cmd.senderUserId);

        if (student == null || position == null || sender == null) {
            throw new IllegalArgumentException("Invalid data provided for request.");
        }

        // Check if student is already hired elsewhere
        if (student.getStatus() != StudentInfo.StudentStatus.Available) {
            throw new IllegalStateException("Student is already accepted for another internship.");
        }

        int max = (position.getMaxSpots() != null) ? position.getMaxSpots() : 0;
        int current = (position.getAcceptedCount() != null) ? position.getAcceptedCount() : 0;
        if (current >= max && max > 0) {
            throw new IllegalStateException("Cannot initiate request: Position capacity reached.");
        }

        if (position.getStatus() == InternshipPosition.PositionStatus.Closed){
            throw new IllegalStateException("Cannot initiate request: Position closed.");
        }

        if (position.getDeadline() != null && position.getDeadline().before(new Date())) {
            throw new IllegalStateException("Cannot initiate request: The deadline for this position has passed.");
        }

        // Strict Duplicate Check
        if (findApplication(cmd.studentId, cmd.positionId) != null) {
            throw new IllegalStateException("An application record already exists for this student.");
        }

        InternshipApplication app = new InternshipApplication();
        app.setStudent(student);
        app.setInternshipPosition(position);
        app.setAppliedAt(LocalDateTime.now());
        app.setChatInitiated(true);
        app.setStatus(InternshipApplication.ApplicationStatus.Request);

        entityManager.persist(app);
        entityManager.flush(); // Necessary so the update method can find it in the DB

        // 4. If update succeeded, proceed with side effects
        position.setApplicationsCount((position.getApplicationsCount() != null ? position.getApplicationsCount() : 0) + 1);

        Message msg = new Message();
        msg.setApplication(app);
        msg.setSender(sender);
        msg.setMessageText(cmd.initialMessage);
        msg.setSenderRole(Message.SenderRole.Company);
        msg.setTimeSent(LocalDateTime.now());

        entityManager.persist(msg);
    }

    private UserAccount getUserAccountByStudentId(Long studentId) {
        try {
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.studentInfo.id = :sid",
                    UserAccount.class);

            query.setParameter("sid", studentId);
            return query.getSingleResult();

        } catch (NoResultException e) {
            // This happens if the student profile exists but is orphaned (no user account)
            return null;
        } catch (Exception e) {
            LOG.warning("Error fetching UserAccount for Student ID " + studentId + ": " + e.getMessage());
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