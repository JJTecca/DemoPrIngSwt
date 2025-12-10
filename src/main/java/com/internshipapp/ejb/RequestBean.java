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
            entityManager.flush(); // Ensure ID is generated

            // Return updated DTO with ID
            requestDto.setId(requestEntity.getId());
            return requestDto;

        } catch (Exception ex) {
            LOG.severe("Error creating request: " + ex.getMessage());
            throw ex;
        }
    }
}