package com.internshipapp.ejb;

import com.internshipapp.common.UserAccountDto;
import com.internshipapp.entities.UserAccount;
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
public class UserAccountBean {
    private static final Logger LOG = Logger.getLogger(UserAccountBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<UserAccountDto> copyUsersToDto(List<UserAccount> users) {
        List<UserAccountDto> dtos = new ArrayList<>();
        for (UserAccount user : users) {
            UserAccountDto userDto = new UserAccountDto(
                    user.getUserId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getStudentInfo() != null ? user.getStudentInfo().getId() : null,
                    user.getStudentInfo() != null ? user.getStudentInfo().getFirstName() + " " + user.getStudentInfo().getLastName() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getId() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getName() : null
            );
            dtos.add(userDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
    public List<UserAccountDto> findAllUsers() {
        LOG.info("findAllUsers");
        try {
            TypedQuery<UserAccount> typedQuery = entityManager.createQuery("SELECT u FROM UserAccount u", UserAccount.class);
            List<UserAccount> users = typedQuery.getResultList();
            return copyUsersToDto(users);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}