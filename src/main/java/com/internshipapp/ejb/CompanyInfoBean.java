package com.internshipapp.ejb;

import com.internshipapp.common.AttachmentDto;
import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.entities.Attachment;
import com.internshipapp.entities.CompanyInfo;
import jakarta.ejb.EJBException;
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
public class CompanyInfoBean {
    private static final Logger LOG = Logger.getLogger(AttachmentBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<CompanyInfoDto> copyCompanyInfoToDto(List<CompanyInfo> companyInfos) {
        List<CompanyInfoDto> companyInfoDtos = new ArrayList<>();
        for (CompanyInfo companyInfo : companyInfos) {
            CompanyInfoDto companyInfoDto = new CompanyInfoDto(
                    companyInfo.getId(),
                    companyInfo.getAttachment() != null ? companyInfo.getAttachment().getId() : null,
                    companyInfo.getName(),
                    companyInfo.getShortName(),
                    companyInfo.getWebsite(),
                    companyInfo.getCompDescription(),
                    companyInfo.getOpenedPositions(),
                    companyInfo.getStudentsApplied()
            );
            companyInfoDtos.add(companyInfoDto);
        }
        return companyInfoDtos;
    }

    // Add custom query methods for specific business requirements
    public List<CompanyInfoDto> findAllAttachments() {
        LOG.info("findAllAttachments");
        try {
            TypedQuery<CompanyInfo> typedQuery = entityManager.createQuery("SELECT a FROM CompanyInfo a", CompanyInfo.class);
            List<CompanyInfo> companyInfo = typedQuery.getResultList();
            return copyCompanyInfoToDto(companyInfo);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

}
