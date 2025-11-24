package com.internshipapp.ejb;

import com.internshipapp.common.AttachmentDto;
import com.internshipapp.entities.Attachment;
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