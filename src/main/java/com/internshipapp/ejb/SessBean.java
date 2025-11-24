package com.internshipapp.ejb;

import com.internshipapp.common.SessDto;
import com.internshipapp.entities.Sess;
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
public class SessBean {
    private static final Logger LOG = Logger.getLogger(SessBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<SessDto> copySessionsToDto(List<Sess> sessions) {
        List<SessDto> dtos = new ArrayList<>();
        for (Sess sess : sessions) {
            SessDto sessDto = new SessDto(
                    sess.getId(),
                    sess.getUser().getUserId(),
                    sess.getUser().getUsername(),
                    sess.getLogin(),
                    sess.getToken()
            );
            dtos.add(sessDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
    public List<SessDto> findAllSessions() {
        LOG.info("findAllSessions");
        try {
            TypedQuery<Sess> typedQuery = entityManager.createQuery("SELECT s FROM Sess s", Sess.class);
            List<Sess> sessions = typedQuery.getResultList();
            return copySessionsToDto(sessions);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}