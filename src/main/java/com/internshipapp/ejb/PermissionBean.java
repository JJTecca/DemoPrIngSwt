package com.internshipapp.ejb;

import com.internshipapp.common.PermissionDto;
import com.internshipapp.entities.Permission;
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
public class PermissionBean {
    private static final Logger LOG = Logger.getLogger(PermissionBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public List<PermissionDto> copyPermissionsToDto(List<Permission> permissions) {
        List<PermissionDto> dtos = new ArrayList<>();
        for (Permission permission : permissions) {
            PermissionDto permissionDto = new PermissionDto(
                    permission.getId(),
                    permission.getUser().getUserId(),
                    permission.getUser().getUsername(),
                    permission.getRole().toString()
            );
            dtos.add(permissionDto);
        }
        return dtos;
    }

    // Add custom query methods for specific business requirements
    public List<PermissionDto> findAllPermissions() {
        LOG.info("findAllPermissions");
        try {
            TypedQuery<Permission> typedQuery = entityManager.createQuery("SELECT p FROM Permission p", Permission.class);
            List<Permission> permissions = typedQuery.getResultList();
            return copyPermissionsToDto(permissions);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }
}