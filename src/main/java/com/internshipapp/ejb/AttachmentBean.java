package com.internshipapp.ejb;

import com.internshipapp.common.AttachmentDto;
import com.internshipapp.common.FileDto;
import com.internshipapp.entities.Attachment;
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

    public FileDto getProfilePicture(Long studentId) {
        Attachment att = findAttachmentByStudentId(studentId);
        if (att != null && att.getProfilePic() != null && att.getProfilePic().length > 0) {
            return new FileDto("pfp.jpg", "image/jpeg", att.getProfilePic());
        }
        return null;
    }

    // --- WRITE OPERATIONS ---

    public void updateCv(Long studentId, byte[] fileData, String fileName, String contentType) {
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

        // SET FLAG
        att.setHasCv(true);

        entityManager.merge(att);
        entityManager.merge(student);
    }

    public void updateProfilePicture(Long studentId, byte[] fileData) {
        StudentInfo student = entityManager.find(StudentInfo.class, studentId);
        if (student == null) throw new IllegalArgumentException("Student not found");

        Attachment att = student.getAttachment();
        if (att == null) {
            att = new Attachment();
            entityManager.persist(att);
            student.setAttachment(att);
        }

        att.setProfilePic(fileData);

        // SET FLAG
        att.setHasProfilePic(true);

        entityManager.merge(att);
        entityManager.merge(student);
    }

    // --- DELETE OPERATIONS (Updated to clear Flags) ---

    public void deleteCv(Long studentId) {
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null && student.getAttachment() != null) {
                Attachment att = student.getAttachment();

                // Clear Data
                att.setCv(null);
                att.setCvFileName(null);
                att.setCvContentType(null);

                // UNSET FLAG
                att.setHasCv(false);

                // If both false, delete row. Else update.
                if (!att.getHasProfilePic()) {
                    student.setAttachment(null);
                    entityManager.merge(student);
                    entityManager.remove(att);
                } else {
                    entityManager.merge(att);
                }
            }
        } catch (Exception e) {
            // Log error
        }
    }

    public void deleteProfilePicture(Long studentId) {
        try {
            StudentInfo student = entityManager.find(StudentInfo.class, studentId);
            if (student != null && student.getAttachment() != null) {
                Attachment att = student.getAttachment();

                // Clear Data
                att.setProfilePic(null);

                // UNSET FLAG
                att.setHasProfilePic(false);

                // If both false, delete row
                if (!att.getHasCv()) {
                    student.setAttachment(null);
                    entityManager.merge(student);
                    entityManager.remove(att);
                } else {
                    entityManager.merge(att);
                }
            }
        } catch (Exception e) {
            // Log error
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