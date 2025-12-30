package com.internshipapp.ejb;

import com.internshipapp.common.AttachmentDto;
import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.entities.Attachment;
import com.internshipapp.entities.CompanyInfo;
import com.internshipapp.entities.UserAccount;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

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
public class CompanyInfoBean {
    private static final Logger LOG = Logger.getLogger(CompanyInfoBean.class.getName());

    @Inject
    private InternshipApplicationBean applicationBean;

    @PersistenceContext
    EntityManager entityManager;

    private AttachmentDto getAttachmentDto(Attachment attachment) {
        if (attachment == null) return null;
        return new AttachmentDto(
                attachment.getId(),
                attachment.hasCv() != null && attachment.hasCv(),
                attachment.hasProfilePic() != null && attachment.hasProfilePic()
        );
    }

    // --- CONVERTER METHOD ---
    public CompanyInfoDto copyToDto(CompanyInfo entity) {
        if (entity == null) return null;

        String userEmail = null;
        String username = null;
        Long userId = null;

        try {
            // Find UserAccount linked to this CompanyInfo (ManyToOne from UserAccount to CompanyInfo)
            TypedQuery<UserAccount> userQuery = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.companyInfo = :company",
                    UserAccount.class
            );
            userQuery.setParameter("company", entity);
            List<UserAccount> accounts = userQuery.getResultList();

            if (!accounts.isEmpty()) {
                userEmail = accounts.get(0).getEmail();
                username = accounts.get(0).getUsername();
                userId = accounts.get(0).getUserId();
            }
        } catch (Exception e) {
            LOG.warning("Could not fetch UserAccount for Company: " + entity.getName());
        }

        Long totalApplications = applicationBean.countApplicationsByCompanyId(entity.getId());
        String studentsAppliedString = String.valueOf(totalApplications);
        // -----------------------------------------------------------------

        return new CompanyInfoDto(
                entity.getId(),
                entity.getName(),
                entity.getShortName(),
                entity.getWebsite(),
                entity.getCompDescription(),
                entity.getOpenedPositions(),
                // FIX: Use the calculated count instead of the raw entity field
                studentsAppliedString,
                entity.getBiography(),
                getAttachmentDto(entity.getAttachment()),
                entity.getContactEmail(),
                userEmail,
                username,
                userId
        );
    }


    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/

    public void updateCompany(Long companyId, String name, String shortName, String website,
                              String compDescription, String openedPositions, String studentsApplied,
                              String biography, String contactEmail) {
        try {
            CompanyInfo company = entityManager.find(CompanyInfo.class, companyId);
            if (company != null) {
                // Ensure name is updated, it is NOT NULL
                company.setName(name);

                // Update nullable fields
                company.setShortName(shortName);
                company.setWebsite(website);
                company.setCompDescription(compDescription);
                company.setOpenedPositions(openedPositions);
                company.setStudentsApplied(studentsApplied);
                company.setBiography(biography);
                company.setContactEmail(contactEmail);

                entityManager.merge(company);
            }
        } catch (Exception ex) {
            LOG.severe("Error updating company ID " + companyId + ": " + ex.getMessage());
            throw new EJBException(ex);
        }
    }
    // Update return type to DTO
    public CompanyInfoDto findByUserEmail(String email) {
        try {
            TypedQuery<CompanyInfo> query = entityManager.createQuery(
                    "SELECT c FROM UserAccount u JOIN u.companyInfo c WHERE u.email = :email",
                    CompanyInfo.class
            );
            query.setParameter("email", email);
            return copyToDto(query.getSingleResult()); // Convert before returning
        } catch (Exception e) {
            return null;
        }
    }

    public CompanyInfoDto findFacultyProfile() {
        try {
            // Search for the specific name you gave the faculty in the DB
            TypedQuery<CompanyInfo> query = entityManager.createQuery(
                    "SELECT c FROM CompanyInfo c WHERE c.name LIKE :name", CompanyInfo.class);
            query.setParameter("name", "%Faculty%"); // Or the exact name
            CompanyInfo faculty = query.getSingleResult();
            return copyToDto(faculty);
        } catch (Exception e) {
            return null;
        }
    }

    // Update return type to DTO
    public CompanyInfoDto findById(Long id) {
        CompanyInfo entity = entityManager.find(CompanyInfo.class, id);
        return copyToDto(entity);
    }
}