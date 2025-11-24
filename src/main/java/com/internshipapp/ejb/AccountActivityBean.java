package com.internshipapp.ejb;

import com.internshipapp.common.AccountActivityDto;
import com.internshipapp.entities.AccountActivity;
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
public class AccountActivityBean {
    private static final Logger LOG = Logger.getLogger(AccountActivityBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<AccountActivityDto> copyActivitiesToDto(List<AccountActivity> accountActivities) {
        List<AccountActivityDto> dtos = new ArrayList<>();
        for (AccountActivity activity : accountActivities) {
            AccountActivityDto activityDto = new AccountActivityDto(
                    activity.getId(),
                    activity.getUser().getUserId(),
                    activity.getUser().getUsername(),
                    activity.getAction().toString(),
                    activity.getOldData(),
                    activity.getNewData(),
                    activity.getActionTime()
            );
            dtos.add(activityDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
    public List<AccountActivityDto> findAllActivities() {
        LOG.info("findAllActivities");
        try {
            TypedQuery<AccountActivity> typedQuery = entityManager.createQuery("SELECT a FROM AccountActivity a", AccountActivity.class);
            List<AccountActivity> activities = typedQuery.getResultList();
            return copyActivitiesToDto(activities);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}