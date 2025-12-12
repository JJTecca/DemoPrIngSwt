package com.internshipapp.ejb;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.entities.CompanyInfo;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

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

    @PersistenceContext
    EntityManager entityManager;

    // --- CONVERTER METHOD ---
    public CompanyInfoDto copyToDto(CompanyInfo entity) {
        if (entity == null) return null;

        return new CompanyInfoDto(
                entity.getId(),
                entity.getAttachment() != null ? entity.getAttachment().getId() : null,
                entity.getName(),
                entity.getShortName(),
                entity.getWebsite(),
                entity.getCompDescription(),
                entity.getOpenedPositions(),
                entity.getStudentsApplied()
        );
    }

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
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

    // Update return type to DTO
    public CompanyInfoDto findById(Long id) {
        CompanyInfo entity = entityManager.find(CompanyInfo.class, id);
        return copyToDto(entity);
    }
}