package com.internshipapp.ejb;

import com.internshipapp.common.AccountActivityDto;
import com.internshipapp.entities.AccountActivity;
import com.internshipapp.entities.UserAccount;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.time.LocalDateTime;
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

            // Safety check
            if (activity.getUser() == null) continue;

            String rawAction = activity.getAction().toString();

            // FIX: Only split when a Lowercase letter is followed by an Uppercase letter
            // Logic: Lookbehind for [a-z], Lookahead for [A-Z]
            String prettyAction = rawAction.replaceAll("(?<=[a-z])(?=[A-Z])", " ");

            AccountActivityDto activityDto = new AccountActivityDto(
                    activity.getId(),
                    activity.getUser().getUserId(),
                    activity.getUser().getUsername(),
                    prettyAction,
                    activity.getOldData(),
                    activity.getNewData(),
                    activity.getActionTime()
            );
            dtos.add(activityDto);
        }
        return dtos;
    }

    public List<AccountActivityDto> findActivitiesByUserId(Long userId) {
        LOG.info("findActivitiesByUserId: " + userId);
        try {
            // Select activities where the user relationship matches the ID
            TypedQuery<AccountActivity> query = entityManager.createQuery(
                    "SELECT a FROM AccountActivity a WHERE a.user.id = :userId ORDER BY a.actionTime DESC",
                    AccountActivity.class
            );
            query.setParameter("userId", userId);

            // Limit to the last 10 actions to keep the dashboard clean
            query.setMaxResults(10);

            List<AccountActivity> activities = query.getResultList();

            if (activities.isEmpty()) {
                return new ArrayList<>();
            }

            return copyActivitiesToDto(activities);
        } catch (Exception ex) {
            LOG.warning("Error finding activities for user " + userId + ": " + ex.getMessage());
            return new ArrayList<>();
        }
    }

    public void logActivity(Long userId, AccountActivity.Action actionEnum, String details) {
        try {
            UserAccount user = entityManager.find(UserAccount.class, userId);
            if (user != null) {
                AccountActivity activity = new AccountActivity();

                activity.setUser(user);          // Now works (Setter exists)
                activity.setAction(actionEnum);  // Now works (Matches Enum type)
                activity.setActionTime(LocalDateTime.now());

                // If we have details (like "Java Developer"), save it in newData
                if (details != null) {
                    activity.setNewData(details.getBytes());
                }

                entityManager.persist(activity);
                LOG.info("Logged activity: " + actionEnum + " for user " + userId);
            }
        } catch (Exception e) {
            LOG.warning("Failed to log activity: " + e.getMessage());
        }
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