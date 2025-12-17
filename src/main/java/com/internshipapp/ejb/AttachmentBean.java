package com.internshipapp.ejb;

import com.internshipapp.common.AttachmentDto;
import com.internshipapp.common.FileDto;
import com.internshipapp.entities.Attachment;
import com.internshipapp.entities.CompanyInfo;
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
public class AttachmentBean {
    private static final Logger LOG = Logger.getLogger(AttachmentBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<AttachmentDto> copyAttachmentsToDto(List<Attachment> attachments) {
        List<AttachmentDto> dtos = new ArrayList<>();
        for (Attachment attachment : attachments) {
            AttachmentDto attachmentDto = new AttachmentDto(
                    attachment.getId(),
                    attachment.getCv(),
                    attachment.getProfilePic()
            );
            dtos.add(attachmentDto);
        }
        return dtos;
    }

    public FileDto getCvFile(Long studentId) {
        Attachment att = findAttachmentByStudentId(studentId);
        if (att != null && att.getCv() != null && att.getCv().length > 0) {
            return new FileDto(att.getCvFileName(), att.getCvContentType(), att.getCv());
        }
        return null;
    }

    public FileDto getPfpForStudent(Long studentId) {
        Attachment att = findAttachmentByStudentId(studentId);

        // Use att.getProfilePic() to get byte data
        if (att != null && att.getProfilePic() != null && att.getProfilePic().length > 0) {
            // FileDto signature: public FileDto(String fileName, String contentType, byte[] fileData)
            return new FileDto("pfp.jpg", "image/jpeg", att.getProfilePic());
        }
        return null;
    }

    /**
     * Retrieves the profile picture FileDto for a specific Company.
     */
    public FileDto getPfpForCompany(Long companyId) {
        Attachment att = findAttachmentByCompanyId(companyId);

        // Use att.getProfilePic() to get byte data
        if (att != null && att.getProfilePic() != null && att.getProfilePic().length > 0) {
            // FileDto signature: public FileDto(String fileName, String contentType, byte[] fileData)
            return new FileDto("pfp.jpg", "image/jpeg", att.getProfilePic());
        }
        return null;
    }

    // --- WRITE OPERATIONS ---

    public void updateCvForStudent(Long studentId, byte[] fileData, String fileName, String contentType) {
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        if (student == null) throw new IllegalArgumentException("Student not found");

        Attachment att = student.getAttachment();
        if (att == null) {
            att = new Attachment();
            entityManager.persist(att);
            student.setAttachment(att);
        }

        att.setCv(fileData);
        att.setCvFileName(fileName);
        att.setCvContentType(contentType);

        att.setHasCv(true);

        entityManager.merge(att);
        entityManager.merge(student);
    }

    // RENAMED from updateProfilePicture to updateProfilePictureForStudent
    public void updatePfpForStudent(Long studentId, byte[] fileData) {
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        if (student == null) throw new IllegalArgumentException("Student not found");

        Attachment att = student.getAttachment();
        if (att == null) {
            att = new Attachment();
            entityManager.persist(att);
            student.setAttachment(att);
        }

        att.setProfilePic(fileData);
        att.setHasProfilePic(true);

        entityManager.merge(att);
        entityManager.merge(student);
    }

    // --- WRITE OPERATIONS: COMPANY (NEW) ---

    // NEW: Update Profile Picture for Company
    public void updatePfpForCompany(Long companyId, byte[] fileData) {
        CompanyInfo company = entityManager.find(CompanyInfo.class, companyId);
        if (company == null) throw new IllegalArgumentException("Company not found");

        Attachment att = company.getAttachment();
        if (att == null) {
            att = new Attachment();
            entityManager.persist(att);
            company.setAttachment(att);
        }

        att.setProfilePic(fileData);
        att.setHasProfilePic(true);

        entityManager.merge(att);
        entityManager.merge(company);
    }

    // --- DELETE OPERATIONS: STUDENT (Renamed and Logic remains) ---

    public void deleteCvForStudent(Long studentId) {
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null && student.getAttachment() != null) {
                Attachment att = student.getAttachment();

                att.setCv(null);
                att.setCvFileName(null);
                att.setCvContentType(null);
                att.setHasCv(false);

                if (!att.hasProfilePic()) {
                    student.setAttachment(null);
                    entityManager.merge(student);
                    entityManager.remove(att);
                } else {
                    entityManager.merge(att);
                }
            }
        } catch (Exception e) {
            LOG.severe("Error deleting CV for student ID " + studentId + ": " + e.getMessage());
        }
    }

    public void deletePfpForStudent(Long studentId) {
        // ... (Logic same as old deleteProfilePicture, but uses StudentInfo) ...
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null && student.getAttachment() != null) {
                Attachment att = student.getAttachment();

                att.setProfilePic(null);
                att.setHasProfilePic(false);

                if (!att.hasCv()) {
                    student.setAttachment(null);
                    entityManager.merge(student);
                    entityManager.remove(att);
                } else {
                    entityManager.merge(att);
                }
            }
        } catch (Exception e) {
            LOG.severe("Error deleting PFP for student ID " + studentId + ": " + e.getMessage());
        }
    }

    // --- DELETE OPERATIONS: COMPANY (NEW) ---

    public void deletePfpForCompany(Long companyId) {
        try {
            CompanyInfo company = entityManager.find(CompanyInfo.class, companyId);
            if (company != null && company.getAttachment() != null) {
                Attachment att = company.getAttachment();

                att.setProfilePic(null);
                att.setHasProfilePic(false);

                if (!att.hasCv()) { // Check if the company has a CV (should always be false)
                    company.setAttachment(null);
                    entityManager.merge(company);
                    entityManager.remove(att);
                } else {
                    // This scenario shouldn't happen for a company, but we merge anyway
                    entityManager.merge(att);
                }
            }
        } catch (Exception e) {
            LOG.severe("Error deleting PFP for company ID " + companyId + ": " + e.getMessage());
        }
    }

    // --- HELPER ---
    private Attachment findAttachmentByStudentId(Long studentId) {
        try {
            return entityManager.createQuery(
                            "SELECT a FROM StudentInfo s JOIN s.attachment a WHERE s.id = :sid", Attachment.class)
                    .setParameter("sid", studentId)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    private Attachment findAttachmentByCompanyId(Long companyId) {
        try {
            // Assumes CompanyInfo has a 'attachment' field linked to Attachment entity
            return (Attachment) entityManager.createQuery(
                            "SELECT c.attachment FROM CompanyInfo c WHERE c.id = :cid")
                    .setParameter("cid", companyId)
                    .getSingleResult();
        } catch (Exception e) {
            return null;
        }
    }

    // Add custom query methods for specific business requirements
    public List<AttachmentDto> findAllAttachments() {
        LOG.info("findAllAttachments");
        try {
            TypedQuery<Attachment> typedQuery = entityManager.createQuery("SELECT a FROM Attachment a", Attachment.class);
            List<Attachment> attachments = typedQuery.getResultList();
            return copyAttachmentsToDto(attachments);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}