package com.internshipapp.ejb;

import com.internshipapp.common.CompanyInfoDto;
import com.internshipapp.common.StudentInfoDto;
import com.internshipapp.common.UserAccountDto;
import com.internshipapp.entities.UserAccount;
import com.internshipapp.entities.CompanyInfo;
import com.internshipapp.entities.Permission;
import com.internshipapp.entities.Request;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
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

    @Inject
    private StudentInfoBean studentInfoBean;

    @Inject
    private CompanyInfoBean companyInfoBean;

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
                    user.getPassword(),
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

    public UserAccountDto findByEmail(String email) {
        LOG.info("findByEmail: " + email);
        try {
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.email = :email", UserAccount.class);
            query.setParameter("email", email);
            UserAccount user = query.getSingleResult();

            return new UserAccountDto(
                    user.getUserId(),
                    user.getUsername(),
                    user.getPassword(),
                    user.getEmail(),
                    user.getStudentInfo() != null ? user.getStudentInfo().getId() : null,
                    user.getStudentInfo() != null ? user.getStudentInfo().getFirstName() + " " + user.getStudentInfo().getLastName() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getId() : null,
                    user.getCompanyInfo() != null ? user.getCompanyInfo().getName() : null
            );
        } catch (Exception ex) {
            LOG.info("User not found with email: " + email + " - Error: " + ex.getMessage());
            return null;
        }
    }

    /**************************************************************************
     * NOTE : In database password are encrypted already, remove the BCrypt prefix
     * Admin is hardcoded in the database with proper password
     ****************************************************************************/
    public boolean authenticate(String email, String password) {
        LOG.info("authenticate: " + email);

        UserAccountDto user = findByEmail(email);
        if (user == null) {
            LOG.info("User not found: " + email);
            return false;
        }

        String storedPassword = user.getPassword();

        // Check if it's a real BCrypt hash (starts with $2a$...)
        if (storedPassword != null && storedPassword.startsWith("$2a$")) {
            if (storedPassword.startsWith("$2a$10$")) {
                // Remove the "$2a$10$" prefix (7 characters)
                String extractedPassword = storedPassword.substring(7);
                LOG.info("Extracted password after removing BCrypt prefix: " + extractedPassword);

                boolean match = password.equals(extractedPassword);
                LOG.info("Password match after BCrypt extraction: " + match);
                return match;
            }
        }

        boolean authenticated = password.equals(storedPassword);
        return authenticated;
    }

    public String getUserRoleByEmail(String email) {
        try {
            // Query for the Enum object, then call .name()
            TypedQuery<Permission.Role> query = entityManager.createQuery(
                    "SELECT p.role FROM Permission p WHERE p.user.email = :email", Permission.Role.class);
            query.setParameter("email", email);
            Permission.Role role = query.getSingleResult();
            return role.name(); // Converts Enum 'Faculty' to String "Faculty"
        } catch (Exception ex) {
            LOG.warning("Database role check failed: " + ex.getMessage());
            return "";
        }
    }

    public StudentInfoDto getStudentInfoByEmail(String email) {
        LOG.info("getStudentInfoByEmail: " + email);
        try {
            // Retrieve UserAccount, eagerly fetching studentInfo
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u LEFT JOIN FETCH u.studentInfo WHERE u.email = :email",
                    UserAccount.class
            );
            query.setParameter("email", email);
            UserAccount user = query.getSingleResult();

            if (user != null && user.getStudentInfo() != null) {
                // Delegate the complex mapping (including the AttachmentDto logic)
                // to the StudentInfoBean
                return studentInfoBean.copyStudentToDto(user.getStudentInfo());
            }
            return null;
        } catch (Exception ex) {
            LOG.info("Student info not found for email: " + email + " - Error: " + ex.getMessage());
            return null;
        }
    }

    public CompanyInfoDto getCompanyInfoByEmail(String email) {
        LOG.info("getCompanyInfoByEmail: " + email);
        try {
            // Retrieve UserAccount, eagerly fetching companyInfo
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u LEFT JOIN FETCH u.companyInfo WHERE u.email = :email",
                    UserAccount.class
            );
            query.setParameter("email", email);
            UserAccount user = query.getSingleResult();

            if (user != null && user.getCompanyInfo() != null) {
                // Delegate the complex mapping (including the AttachmentDto logic)
                // to the CompanyInfoBean
                return companyInfoBean.copyToDto(user.getCompanyInfo());
            }
            return null;
        } catch (Exception ex) {
            LOG.info("Company info not found for email: " + email + " - Error: " + ex.getMessage());
            return null;
        }
    }

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

    public boolean createCompanyUserFromRequest(String companyName, String companyEmail, String password) {
        LOG.info("Creating company user account for: " + companyEmail);

        try {
            // Check if user already exists
            UserAccount existingUser = findUserEntityByEmail(companyEmail);
            if (existingUser != null) {
                LOG.warning("User already exists with email: " + companyEmail);
                return false;
            }

            // Create CompanyInfo
            CompanyInfo companyInfo = new CompanyInfo();
            companyInfo.setName(companyName);
            entityManager.persist(companyInfo);

            // Create UserAccount
            UserAccount userAccount = new UserAccount();
            userAccount.setUsername(companyName.replaceAll("\\s+", "").toLowerCase());

            // FIX: If password already has $2a$10$, DON'T add another!
            String passwordToStore;
            if (password.startsWith("$2a$10$")) {
                // Remove the existing $2a$10$, then add our own
                // So we have SINGLE $2a$10$ prefix
                String withoutPrefix = password.substring(7); // Remove "$2a$10$"
                passwordToStore = "$2a$10$" + withoutPrefix;
                LOG.info("Removed existing BCrypt prefix, adding new one");
            } else {
                // Add prefix
                passwordToStore = "$2a$10$" + password;
            }

            userAccount.setPassword(passwordToStore);
            userAccount.setEmail(companyEmail);
            userAccount.setCompanyInfo(companyInfo);

            entityManager.persist(userAccount);

            // Create Permission
            Permission permission = new Permission();
            permission.setUser(userAccount);
            permission.setRole(Permission.Role.Company);
            entityManager.persist(permission);

            LOG.info("Company user account created successfully for: " + companyEmail);
            LOG.info("Password stored as: " + passwordToStore.substring(0, Math.min(30, passwordToStore.length())) + "...");

            return true;

        } catch (Exception e) {
            LOG.severe("Error creating company user account: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Approves a request by creating a company user account
     * This is a wrapper method that combines finding the request and creating the account
     *
     * @param requestId The ID of the request to approve
     * @return true if successful, false otherwise
     */
    public boolean approveRequestAndCreateAccount(Long requestId) {
        LOG.info("Approving request and creating account for request ID: " + requestId);

        try {
            // Find the request entity
            Request request = entityManager.find(Request.class, requestId);
            if (request == null) {
                LOG.warning("Request not found with ID: " + requestId);
                return false;
            }

            // Create the company account
            boolean accountCreated = createCompanyUserFromRequest(
                    request.getCompanyName(),
                    request.getCompanyEmail(),
                    request.getPassword()
            );

            if (accountCreated) {
                // Update request status to approved
                request.setStatus(Request.RequestStatus.approved);
                entityManager.merge(request);
                LOG.info("Request approved and account created successfully for: " + request.getCompanyEmail());
                return true;
            } else {
                LOG.warning("Failed to create account for request ID: " + requestId);
                return false;
            }

        } catch (Exception e) {
            LOG.severe("Error approving request: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**********************************************************************
     *  Reject Request by admin to the company so no account will be created
     **********************************************************************/
    public boolean rejectRequest(Long requestId) {
        LOG.info("Rejecting request with ID: " + requestId);

        try {
            // Find the request entity
            Request request = entityManager.find(Request.class, requestId);
            if (request == null) {
                LOG.warning("Request not found with ID: " + requestId);
                return false;
            }

            // Update request status to rejected
            request.setStatus(Request.RequestStatus.rejected);
            entityManager.merge(request);

            LOG.info("Request rejected successfully for: " + request.getCompanyEmail());
            return true;

        } catch (Exception e) {
            LOG.severe("Error rejecting request: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public UserAccount findUserEntityByEmail(String email) {
        try {
            TypedQuery<UserAccount> query = entityManager.createQuery(
                    "SELECT u FROM UserAccount u WHERE u.email = :email", UserAccount.class);
            query.setParameter("email", email);
            return query.getSingleResult();
        } catch (Exception ex) {
            return null;
        }
    }
}