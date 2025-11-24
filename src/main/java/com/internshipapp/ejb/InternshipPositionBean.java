package com.internshipapp.ejb;

import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.entities.InternshipPosition;
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
public class InternshipPositionBean {
    private static final Logger LOG = Logger.getLogger(InternshipPositionBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<InternshipPositionDto> copyPositionsToDto(List<InternshipPosition> positions) {
        List<InternshipPositionDto> dtos = new ArrayList<>();
        for (InternshipPosition position : positions) {
            InternshipPositionDto positionDto = new InternshipPositionDto(
                    position.getId(),
                    position.getCompany().getId(),
                    position.getCompany().getName(),
                    position.getTitle(),
                    position.getDescription(),
                    position.getRequirements(),
                    position.getDeadline(),
                    position.getMaxSpots()
            );
            dtos.add(positionDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
    public List<InternshipPositionDto> findAllPositions() {
        LOG.info("findAllPositions");
        try {
            TypedQuery<InternshipPosition> typedQuery = entityManager.createQuery("SELECT p FROM InternshipPosition p", InternshipPosition.class);
            List<InternshipPosition> positions = typedQuery.getResultList();
            return copyPositionsToDto(positions);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}