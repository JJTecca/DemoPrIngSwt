package com.internshipapp.ejb;

import com.internshipapp.common.RequestDto;
import com.internshipapp.entities.Request;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

@Stateless
public class RequestBean {
    private static final Logger LOG = Logger.getLogger(RequestBean.class.getName());

    @PersistenceContext
    EntityManager entityManager;

    // Convert entities to DTOs
    public List<RequestDto> copyRequestsToDto(List<Request> requests) {
        List<RequestDto> dtos = new ArrayList<>();
        for (Request request : requests) {
            RequestDto dto = new RequestDto(
                    request.getId(),
                    request.getCompanyName(),
                    request.getCompanyEmail(),
                    request.getHqAddress(),
                    request.getPhoneNumber(),
                    request.getPassword(),
                    request.getToken(),
                    request.getStatus()
            );
            dtos.add(dto);
        }
        return dtos;
    }

    // Get all pending requests
    public List<RequestDto> getPendingRequests() {
        LOG.info("getPendingRequests");
        try {
            TypedQuery<Request> query = entityManager.createQuery(
                    "SELECT r FROM Request r WHERE r.status = com.internshipapp.entities.Request.RequestStatus.pending ORDER BY r.id",
                    Request.class
            );
            List<Request> requests = query.getResultList();
            return copyRequestsToDto(requests);
        } catch (Exception ex) {
            LOG.severe("Error getting pending requests: " + ex.getMessage());
            ex.printStackTrace();
            return new ArrayList<>();
        }
    }

    // Also update countPendingRequests():
    public long countPendingRequests() {
        LOG.info("countPendingRequests");
        try {
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(r) FROM Request r WHERE r.status = com.internshipapp.entities.Request.RequestStatus.pending",
                    Long.class
            );
            return query.getSingleResult();
        } catch (Exception ex) {
            LOG.severe("Error counting pending requests: " + ex.getMessage());
            return 0;
        }
    }

    // Get all requests
    public List<RequestDto> getAllRequests() {
        LOG.info("getAllRequests");
        try {
            TypedQuery<Request> query = entityManager.createQuery(
                    "SELECT r FROM Request r ORDER BY r.id",
                    Request.class
            );
            List<Request> requests = query.getResultList();
            return copyRequestsToDto(requests);
        } catch (Exception ex) {
            throw new EJBException(ex);
        }
    }

    public RequestDto createRequest(RequestDto requestDto) {
        LOG.info("createRequest: " + requestDto.getCompanyName());

        try {
            // Convert DTO to entity
            Request requestEntity = new Request();
            requestEntity.setCompanyName(requestDto.getCompanyName());
            requestEntity.setCompanyEmail(requestDto.getCompanyEmail());
            requestEntity.setHqAddress(requestDto.getHqAddress());
            requestEntity.setPhoneNumber(requestDto.getPhoneNumber());
            requestEntity.setPassword(requestDto.getPassword());
            requestEntity.setToken(requestDto.getToken());

            // Set status from string to enum
            if (requestDto.getStatus() != null) {
                try {
                    Request.RequestStatus status = Request.RequestStatus.valueOf(
                            requestDto.getStatus().toLowerCase()
                    );
                    requestEntity.setStatus(status);
                } catch (IllegalArgumentException e) {
                    // Default to pending if status is invalid
                    requestEntity.setStatus(Request.RequestStatus.pending);
                }
            } else {
                requestEntity.setStatus(Request.RequestStatus.pending);
            }

            // Save to database
            entityManager.persist(requestEntity);
            entityManager.flush();

            requestDto.setId(requestEntity.getId());
            return requestDto;

        } catch (Exception ex) {
            LOG.severe("Error creating request: " + ex.getMessage());
            throw ex;
        }
    }
    public boolean approveRequest(Long requestId) {
        LOG.info("=== START approveRequest for ID: " + requestId + " ===");

        try {
            // Find the request entity
            LOG.info("Looking for request with ID: " + requestId);
            Request request = entityManager.find(Request.class, requestId);

            if (request == null) {
                LOG.severe("❌ Request not found with ID: " + requestId);
                LOG.info("=== END approveRequest (FAILED - not found) ===");
                return false;
            }

            LOG.info("✅ Request found:");
            LOG.info("  - Company: " + request.getCompanyName());
            LOG.info("  - Email: " + request.getCompanyEmail());
            LOG.info("  - Current status: " + request.getStatus());
            LOG.info("  - Password: " + (request.getPassword() != null ? "[SET]" : "NULL"));

            // Check if already approved
            if (Request.RequestStatus.approved.equals(request.getStatus())) {
                LOG.warning("⚠️ Request already approved");
                LOG.info("=== END approveRequest (already approved) ===");
                return true;
            }

            // Update request status
            LOG.info("Setting status to: approved");
            request.setStatus(Request.RequestStatus.approved);

            LOG.info("Merging changes to database...");
            entityManager.merge(request);

            // Verify the update
            Request updatedRequest = entityManager.find(Request.class, requestId);
            LOG.info("✅ Status after update: " + updatedRequest.getStatus());

            LOG.info("✅ Request approved successfully for: " + request.getCompanyEmail());
            LOG.info("=== END approveRequest (SUCCESS) ===");
            return true;

        } catch (Exception e) {
            LOG.severe("❌ ERROR approving request: " + e.getMessage());
            LOG.severe("Exception type: " + e.getClass().getName());
            e.printStackTrace();
            LOG.info("=== END approveRequest (FAILED - exception) ===");
            return false;
        }
    }

    /**
     * Rejects a request by updating its status
     *
     * @param requestId The ID of the request to reject
     * @return true if successful, false otherwise
     */
    public boolean rejectRequest(Long requestId) {
        LOG.info("Rejecting request with ID: " + requestId);

        try {
            // Find the request entity
            Request request = entityManager.find(Request.class, requestId);
            if (request == null) {
                LOG.warning("Request not found with ID: " + requestId);
                return false;
            }

            // Update request status to REJECTED
            // Check how the status field is defined in Request entity
            // If it's a String:
            request.setStatus(Request.RequestStatus.rejected);

            // If it's an enum, you might need something like:
            // request.setStatus(RequestStatus.REJECTED);
            // or
            // request.setStatus(StatusEnum.REJECTED);

            entityManager.merge(request);

            LOG.info("Request rejected successfully for: " + request.getCompanyEmail());
            return true;

        } catch (Exception e) {
            LOG.severe("Error rejecting request: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}