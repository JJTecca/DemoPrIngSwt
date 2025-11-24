package com.internshipapp.ejb;

import com.internshipapp.common.InternshipApplicationDto;
import com.internshipapp.entities.InternshipApplication;
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
        for (InternshipApplication application : applications) {
            InternshipApplicationDto applicationDto = new InternshipApplicationDto(
                    application.getId(),
                    application.getInternshipPosition().getId(),
                    application.getStudent().getId(),
                    application.getStatus().toString(),
                    application.getGrade(),
                    application.getAppliedAt(),
                    application.getChatIds()
            );
            dtos.add(applicationDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
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