package com.internshipapp.ejb;

import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.entities.Attachment;
import com.internshipapp.entities.Permission;
import com.internshipapp.entities.StudentInfo;
import com.internshipapp.entities.UserAccount;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.TreeMap;
import java.util.logging.Logger;

@Stateless
public class StudentInfoBean {
    private static final Logger LOG = Logger.getLogger(StudentInfoBean.class.getName());

    @PersistenceContext(unitName = "default")
    EntityManager entityManager;

    @Inject
    private ExcelParserBean excelParserBean;

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
            Attachment att = entityManager.find(Attachment.class, student.getAttachment().getId());

            if (att != null) {
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
                student.getBiography(),
                student.getGradeVisibility()
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
            TypedQuery<Object[]> query = entityManager.createQuery(
                    "SELECT s.attachment.id, s.attachment.hasCv, s.attachment.hasProfilePic " +
                            "FROM StudentInfo s WHERE s.id = :sid",
                    Object[].class
            );
            query.setParameter("sid", studentId);
            return query.getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    public void updateStudent(Long studentId, String firstName, String middleName, String lastName,
                              Integer studyYear, Float lastYearGrade, String status, Boolean enrolled,
                              String biography, boolean gradeVisibility) {
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
                student.setGradeVisibility(gradeVisibility);
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

    public List<Map<String, String>> parseExcelForPreview(InputStream excelInputStream) throws Exception {
        LOG.info("Parsing Excel for preview");
        try {
            return excelParserBean.parseExcel(excelInputStream);
        } catch (Exception e) {
            LOG.severe("Error parsing Excel for preview: " + e.getMessage());
            throw new Exception("Failed to parse Excel file: " + e.getMessage(), e);
        }
    }

    /**
     * Import students from parsed Excel data
     */
    public ImportResult importStudentsFromExcelData(List<Map<String, String>> excelData) throws Exception {
        LOG.info("Starting student import from parsed Excel data");

        ImportResult result = new ImportResult();
        result.totalInFile = excelData.size();
        LOG.info("Total students to process: " + result.totalInFile);

        // Process each row
        for (Map<String, String> row : excelData) {
            LOG.info("Processing row: " + row);
            try {
                // Extract and validate data
                ImportStudentData studentData = extractStudentData(row);

                if (!studentData.isValid()) {
                    result.skipped++;
                    String reason = "Missing required fields: Email=" + studentData.email +
                            ", Username=" + studentData.username +
                            ", FullName=" + studentData.fullName +
                            ", Password=" + studentData.password;
                    result.skippedDetails.add(reason);
                    LOG.warning("Skipped - Invalid data: " + reason);
                    continue;
                }

                // Check if student already exists
                boolean exists = studentExists(studentData.email);
                LOG.info("Checking if student exists (email: " + studentData.email + "): " + exists);

                if (exists) {
                    result.skipped++;
                    String reason = "Already exists: " + studentData.email;
                    result.skippedDetails.add(reason);
                    LOG.warning("Skipped - " + reason);
                    continue;
                }

                // Create the student
                LOG.info("Creating student: " + studentData.fullName + " (" + studentData.email + ")");
                createCompleteStudent(studentData);
                result.imported++;
                result.importedStudents.add(studentData.fullName + " (" + studentData.email + ")");
                LOG.info("Successfully created student: " + studentData.fullName);

            } catch (Exception e) {
                result.skipped++;
                result.skippedDetails.add("Error processing: " + e.getMessage());
                LOG.severe("Failed to process row: " + e.getMessage());
                e.printStackTrace();
            }
        }

        LOG.info("Import completed. Imported: " + result.imported +
                ", Skipped: " + result.skipped + ", Total: " + result.totalInFile);

        return result;
    }

    /**
     * Extract and validate student data from row
     */
    private ImportStudentData extractStudentData(Map<String, String> row) {
        ImportStudentData data = new ImportStudentData();

        // Get values with case-insensitive matching
        data.email = getCaseInsensitiveValue(row, "Email");
        data.username = getCaseInsensitiveValue(row, "Username");
        data.fullName = getCaseInsensitiveValue(row, "Full Name");
        String studyYearStr = getCaseInsensitiveValue(row, "Study Year");
        String gradeStr = getCaseInsensitiveValue(row, "Last Year Grade");
        String statusStr = getCaseInsensitiveValue(row, "Status");
        String enrolledStr = getCaseInsensitiveValue(row, "Enrolled");
        data.password = getCaseInsensitiveValue(row, "Password");

        LOG.info("Extracted values - Email: '" + data.email +
                "', Username: '" + data.username +
                "', FullName: '" + data.fullName +
                "', Password: '" + data.password + "'");

        // Validate required fields (ADD PASSWORD TO VALIDATION)
        if (data.email.isEmpty() || data.username.isEmpty() || data.fullName.isEmpty() || data.password.isEmpty()) {
            return data; // Will be invalid
        }

        // Parse name into parts
        String[] nameParts = data.fullName.split("\\s+", 3);
        data.firstName = nameParts.length > 0 ? nameParts[0] : "";
        data.lastName = nameParts.length > 1 ? nameParts[nameParts.length - 1] : "";
        data.middleName = nameParts.length > 2 ? nameParts[1] : "";

        // Parse study year
        try {
            data.studyYear = Integer.parseInt(studyYearStr);
        } catch (NumberFormatException e) {
            data.studyYear = 1; // Default
        }

        // Parse grade
        try {
            data.lastYearGrade = Float.parseFloat(gradeStr);
        } catch (NumberFormatException e) {
            data.lastYearGrade = 0.0f; // Default
        }

        // Parse enrolled status
        data.enrolled = "Yes".equalsIgnoreCase(enrolledStr) ||
                "true".equalsIgnoreCase(enrolledStr) ||
                "1".equals(enrolledStr);

        // Parse status
        try {
            data.status = StudentInfo.StudentStatus.valueOf(statusStr);
        } catch (IllegalArgumentException e) {
            data.status = StudentInfo.StudentStatus.Available; // Default
        }

        data.valid = true;
        return data;
    }

    /**
     * Create complete student with all related entities
     */
    private void createCompleteStudent(ImportStudentData data) {

        // 1. Create Attachment (empty)
        Attachment attachment = new Attachment();
        attachment.setHasCv(false);
        attachment.setHasProfilePic(false);
        entityManager.persist(attachment);

        // 2. Create StudentInfo
        StudentInfo student = new StudentInfo();
        student.setFirstName(data.firstName);
        student.setMiddleName(data.middleName);
        student.setLastName(data.lastName);
        student.setStudyYear(data.studyYear);
        student.setLastYearGrade(data.lastYearGrade);
        student.setStatus(data.status);
        student.setEnrolled(data.enrolled);
        student.setBiography("Imported from Excel");
        student.setGradeVisibility(true);
        student.setAttachment(attachment);

        entityManager.persist(student);
        entityManager.flush();
        LOG.info("Created StudentInfo with ID: " + student.getId());

        // 3. Create UserAccount
        UserAccount userAccount = new UserAccount();
        userAccount.setUsername(data.username);
        userAccount.setEmail(data.email);
        userAccount.setStudentInfo(student);

        // USE PASSWORD FROM EXCEL
        userAccount.setPassword(data.password);
        LOG.info("Setting password for " + data.email + ": '" + data.password + "'");

        entityManager.persist(userAccount);
        entityManager.flush();
        LOG.info("Created UserAccount with ID: " + userAccount.getUserId());

        // 4. Create Permission
        Permission permission = new Permission();
        permission.setUser(userAccount);
        permission.setRole(Permission.Role.Student);
        entityManager.persist(permission);
        entityManager.flush();

        LOG.info("Created Permission with ID: " + permission.getId());
        LOG.info("Successfully created student: " + data.fullName + " (" + data.email + ") with password: " + data.password);
    }

    /**
     * Get value from map with case-insensitive key matching
     */
    private String getCaseInsensitiveValue(Map<String, String> map, String key) {
        // First try exact match
        if (map.containsKey(key)) {
            return map.get(key);
        }

        // Try case-insensitive match
        for (Map.Entry<String, String> entry : map.entrySet()) {
            if (entry.getKey().equalsIgnoreCase(key)) {
                return entry.getValue();
            }
        }

        return "";
    }

    /**
     * Check if a student already exists by email
     */
    private boolean studentExists(String email) {
        try {
            Long count = entityManager.createQuery(
                            "SELECT COUNT(u) FROM UserAccount u WHERE u.email = :email", Long.class)
                    .setParameter("email", email)
                    .getSingleResult();
            return count > 0;
        } catch (Exception e) {
            LOG.warning("Error checking student existence: " + e.getMessage());
            return false;
        }
    }

    // =============================================
    // HELPER CLASSES
    // =============================================

    /**
     * Data class for student import
     */
    private static class ImportStudentData {
        String email;
        String username;
        String fullName;
        String firstName;
        String middleName;
        String lastName;
        int studyYear;
        float lastYearGrade;
        StudentInfo.StudentStatus status;
        boolean enrolled;
        String password;  // ADD THIS
        boolean valid = false;

        boolean isValid() {
            return valid && !email.isEmpty() && !username.isEmpty() && !fullName.isEmpty() && !password.isEmpty();
        }
    }

    /**
     * Result class for import operation
     */
    public static class ImportResult {
        public int imported = 0;
        public int skipped = 0;
        public int totalInFile = 0;
        public List<String> importedStudents = new ArrayList<>();
        public List<String> skippedDetails = new ArrayList<>();

        // Add getters for JSP
        public int getImported() { return imported; }
        public int getSkipped() { return skipped; }
        public int getTotalInFile() { return totalInFile; }
        public List<String> getImportedStudents() { return importedStudents; }
        public List<String> getSkippedDetails() { return skippedDetails; }

        public boolean hasErrors() {
            return skipped > 0;
        }

        public String getSummary() {
            return String.format("Imported: %d, Skipped: %d, Total in file: %d",
                    imported, skipped, totalInFile);
        }
    }
}