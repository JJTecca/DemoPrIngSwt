package com.internshipapp.ejb;

import com.internshipapp.common.InternshipPositionDto;
import com.internshipapp.entities.CompanyInfo;
import com.internshipapp.entities.InternshipPosition;
import jakarta.ejb.EJBException;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Date;
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

    @PersistenceContext(unitName = "default")
    EntityManager entityManager;

    /*******************************************************
     *  Implement conversion methods between entities and DTOs
     *  Write specific sentence about what each function does
     *  Copy function example is standard
     **********************************************************/
    public InternshipPositionDto copyPositionToDto(InternshipPosition position) {
        if (position == null) return null;

        Long id = position.getId();
        Integer filledSpots = getFilledSpotsForPosition(id);
        Integer applicationsCount = getApplicationsCountForPosition(id);
        Integer maxSpots = position.getMaxSpots();
        Integer availableSpots = Math.max(0, maxSpots - filledSpots);

        // Convert Date to LocalDateTime
        LocalDateTime deadline = position.getDeadline() != null ?
                LocalDateTime.ofInstant(position.getDeadline().toInstant(),
                        java.time.ZoneId.systemDefault()) : null;

        Boolean isActive = deadline != null ?
                deadline.isAfter(LocalDateTime.now()) : false;

        return new InternshipPositionDto(
                id,
                position.getCompany() != null ? position.getCompany().getId() : null,
                position.getCompany() != null ? position.getCompany().getName() : null,
                position.getTitle(),
                position.getDescription(),
                position.getRequirements(),
                deadline,
                maxSpots,
                filledSpots,
                applicationsCount,
                isActive,
                availableSpots
        );
    }

    public List<InternshipPositionDto> copyPositionsToDto(List<InternshipPosition> positions) {
        List<InternshipPositionDto> dtos = new ArrayList<>();
        for (InternshipPosition position : positions) {
            dtos.add(copyPositionToDto(position));
        }
        return dtos;
    }

    /*******************************************************
     *  CRUD Operations
     *******************************************************/

    // Get all internship positions
    public List<InternshipPositionDto> findAllPositions() {
        LOG.info("findAllPositions");
        try {
            TypedQuery<InternshipPosition> query = entityManager.createQuery(
                    "SELECT p FROM InternshipPosition p LEFT JOIN FETCH p.company ORDER BY p.deadline",
                    InternshipPosition.class
            );
            List<InternshipPosition> positions = query.getResultList();
            return copyPositionsToDto(positions);
        } catch (Exception ex) {
            LOG.severe("Error in findAllPositions: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Get active positions (deadline in future)
    public List<InternshipPositionDto> findActivePositions() {
        LOG.info("findActivePositions");
        try {
            Date now = new Date();
            TypedQuery<InternshipPosition> query = entityManager.createQuery(
                    "SELECT p FROM InternshipPosition p WHERE p.deadline > :now ORDER BY p.deadline ASC",
                    InternshipPosition.class
            );
            query.setParameter("now", now);
            List<InternshipPosition> positions = query.getResultList();
            return copyPositionsToDto(positions);
        } catch (Exception ex) {
            LOG.severe("Error in findActivePositions: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Get positions by company
    public List<InternshipPositionDto> findByCompany(Long companyId) {
        LOG.info("findByCompany: " + companyId);
        try {
            TypedQuery<InternshipPosition> query = entityManager.createQuery(
                    "SELECT p FROM InternshipPosition p WHERE p.company.id = :companyId ORDER BY p.deadline ASC",
                    InternshipPosition.class
            );
            query.setParameter("companyId", companyId);
            List<InternshipPosition> positions = query.getResultList();
            return copyPositionsToDto(positions);
        } catch (Exception ex) {
            LOG.severe("Error in findByCompany: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Get positions with available spots
    public List<InternshipPositionDto> findPositionsWithAvailableSpots() {
        LOG.info("findPositionsWithAvailableSpots");
        try {
            Date now = new Date();
            // First get all active positions
            List<InternshipPositionDto> activePositions = findActivePositions();
            List<InternshipPositionDto> availablePositions = new ArrayList<>();

            for (InternshipPositionDto position : activePositions) {
                if (position.hasAvailableSpots()) {
                    availablePositions.add(position);
                }
            }
            return availablePositions;
        } catch (Exception ex) {
            LOG.severe("Error in findPositionsWithAvailableSpots: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Count total positions
    public long countAllPositions() {
        LOG.info("countAllPositions");
        try {
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(p) FROM InternshipPosition p", Long.class
            );
            return query.getSingleResult();
        } catch (Exception ex) {
            LOG.severe("Error in countAllPositions: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Count active positions
    public long countActivePositions() {
        LOG.info("countActivePositions");
        try {
            Date now = new Date();
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(p) FROM InternshipPosition p WHERE p.deadline > :now",
                    Long.class
            );
            query.setParameter("now", now);
            return query.getSingleResult();
        } catch (Exception ex) {
            LOG.severe("Error in countActivePositions: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Count positions with available spots
    public long countPositionsWithAvailableSpots() {
        LOG.info("countPositionsWithAvailableSpots");
        try {
            return findPositionsWithAvailableSpots().size();
        } catch (Exception ex) {
            LOG.severe("Error in countPositionsWithAvailableSpots: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Find position by ID
    public InternshipPositionDto findById(Long positionId) {
        LOG.info("findById: " + positionId);
        try {
            InternshipPosition position = entityManager.find(InternshipPosition.class, positionId);
            return copyPositionToDto(position);
        } catch (Exception ex) {
            LOG.severe("Error in findById: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    public Long createPosition(Long companyId, String title, String description,
                               String requirements, Date deadline, Integer maxSpots) {
        LOG.info("createPosition");
        try {
            // Verify company exists
            CompanyInfo company = entityManager.find(CompanyInfo.class, companyId);
            if (company == null) {
                throw new IllegalArgumentException("Company not found with ID: " + companyId);
            }

            // Create new position
            InternshipPosition position = new InternshipPosition();
            position.setCompany(company);
            position.setTitle(title);
            position.setDescription(description);
            position.setRequirements(requirements);
            position.setDeadline(deadline);
            position.setMaxSpots(maxSpots);

            // Persist
            entityManager.persist(position);
            entityManager.flush(); // Get the generated ID

            LOG.info("Created position with ID: " + position.getId());
            return position.getId();

        } catch (Exception ex) {
            LOG.severe("Error in createPosition: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Update position
    public void updatePosition(Long positionId, String title, String description,
                               String requirements, Date deadline, Integer maxSpots) {
        LOG.info("updatePosition: " + positionId);
        try {
            InternshipPosition position = entityManager.find(InternshipPosition.class, positionId);
            if (position == null) {
                throw new IllegalArgumentException("Position not found with ID: " + positionId);
            }

            position.setTitle(title);
            position.setDescription(description);
            position.setRequirements(requirements);
            position.setDeadline(deadline);
            position.setMaxSpots(maxSpots);

            entityManager.merge(position);
            LOG.info("Updated position: " + positionId);

        } catch (Exception ex) {
            LOG.severe("Error in updatePosition: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Delete position
    public void deletePosition(Long positionId) {
        LOG.info("deletePosition: " + positionId);
        try {
            InternshipPosition position = entityManager.find(InternshipPosition.class, positionId);
            if (position != null) {
                entityManager.remove(position);
                LOG.info("Deleted position: " + positionId);
            }
        } catch (Exception ex) {
            LOG.severe("Error in deletePosition: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    /*******************************************************
     *  Helper Methods
     *******************************************************/

    // Get filled spots for a position (accepted applications)
    private Integer getFilledSpotsForPosition(Long positionId) {
        try {
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(a) FROM InternshipApplication a " +
                            "WHERE a.internshipPosition.id = :positionId " +
                            "AND a.status = 'Accepted'",
                    Long.class
            );
            query.setParameter("positionId", positionId);
            Long count = query.getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            LOG.warning("Error getting filled spots for position " + positionId + ": " + e.getMessage());
            return 0;
        }
    }

    // Get total applications for a position
    private Integer getApplicationsCountForPosition(Long positionId) {
        try {
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(a) FROM InternshipApplication a " +
                            "WHERE a.internshipPosition.id = :positionId",
                    Long.class
            );
            query.setParameter("positionId", positionId);
            Long count = query.getSingleResult();
            return count != null ? count.intValue() : 0;
        } catch (Exception e) {
            LOG.warning("Error getting applications count for position " + positionId + ": " + e.getMessage());
            return 0;
        }
    }

    // Get positions expiring soon (within 7 days)
    public List<InternshipPositionDto> findExpiringPositions() {
        LOG.info("findExpiringPositions");
        try {
            Date now = new Date();
            long sevenDays = 7L * 24 * 60 * 60 * 1000;
            Date weekFromNow = new Date(now.getTime() + sevenDays);

            TypedQuery<InternshipPosition> query = entityManager.createQuery(
                    "SELECT p FROM InternshipPosition p " +
                            "WHERE p.deadline BETWEEN :now AND :weekFromNow " +
                            "ORDER BY p.deadline ASC",
                    InternshipPosition.class
            );
            query.setParameter("now", now);
            query.setParameter("weekFromNow", weekFromNow);

            List<InternshipPosition> positions = query.getResultList();
            return copyPositionsToDto(positions);

        } catch (Exception ex) {
            LOG.severe("Error in findExpiringPositions: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Search positions by title or description
    public List<InternshipPositionDto> searchPositions(String searchTerm) {
        LOG.info("searchPositions: " + searchTerm);
        try {
            if (searchTerm == null || searchTerm.trim().isEmpty()) {
                return findAllPositions();
            }

            String likePattern = "%" + searchTerm.toLowerCase() + "%";
            TypedQuery<InternshipPosition> query = entityManager.createQuery(
                    "SELECT p FROM InternshipPosition p " +
                            "WHERE LOWER(p.title) LIKE :pattern " +
                            "OR LOWER(p.description) LIKE :pattern " +
                            "OR LOWER(p.requirements) LIKE :pattern " +
                            "ORDER BY p.deadline ASC",
                    InternshipPosition.class
            );
            query.setParameter("pattern", likePattern);

            List<InternshipPosition> positions = query.getResultList();
            return copyPositionsToDto(positions);

        } catch (Exception ex) {
            LOG.severe("Error in searchPositions: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Check if a student has applied to a position
    public Boolean hasStudentApplied(Long studentId, Long positionId) {
        LOG.info("hasStudentApplied - student: " + studentId + ", position: " + positionId);
        try {
            TypedQuery<Long> query = entityManager.createQuery(
                    "SELECT COUNT(a) FROM InternshipApplication a " +
                            "WHERE a.student.id = :studentId " +
                            "AND a.internshipPosition.id = :positionId",
                    Long.class
            );
            query.setParameter("studentId", studentId);
            query.setParameter("positionId", positionId);

            Long count = query.getSingleResult();
            return count != null && count > 0;

        } catch (Exception ex) {
            LOG.severe("Error in hasStudentApplied: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    // Get statistics
    public PositionStatistics getPositionStatistics() {
        LOG.info("getPositionStatistics");
        try {
            PositionStatistics stats = new PositionStatistics();

            stats.totalPositions = countAllPositions();
            stats.activePositions = countActivePositions();
            stats.positionsWithSpots = countPositionsWithAvailableSpots();

            // Get total spots
            TypedQuery<Object[]> query = entityManager.createQuery(
                    "SELECT SUM(p.maxSpots), " +
                            "COUNT(DISTINCT p.company.id) " +
                            "FROM InternshipPosition p",
                    Object[].class
            );
            Object[] result = query.getSingleResult();

            stats.totalSpots = result[0] != null ? ((Long) result[0]).intValue() : 0;
            stats.companiesWithPositions = result[1] != null ? ((Long) result[1]).intValue() : 0;

            // Calculate filled spots
            TypedQuery<Long> filledQuery = entityManager.createQuery(
                    "SELECT COUNT(a) FROM InternshipApplication a WHERE a.status = 'Accepted'",
                    Long.class
            );
            Long filledCount = filledQuery.getSingleResult();
            stats.filledSpots = filledCount != null ? filledCount.intValue() : 0;

            // Calculate utilization
            if (stats.totalSpots > 0) {
                stats.utilizationRate = (double) stats.filledSpots / stats.totalSpots * 100;
            }

            return stats;

        } catch (Exception ex) {
            LOG.severe("Error in getPositionStatistics: " + ex.getMessage());
            throw new EJBException(ex);
        }
    }

    /*******************************************************
     *  Statistics Inner Class
     *******************************************************/
    public static class PositionStatistics {
        public long totalPositions;
        public long activePositions;
        public long positionsWithSpots;
        public int totalSpots;
        public int filledSpots;
        public int companiesWithPositions;
        public double utilizationRate;

        // Getters
        public long getTotalPositions() { return totalPositions; }
        public long getActivePositions() { return activePositions; }
        public long getPositionsWithSpots() { return positionsWithSpots; }
        public int getTotalSpots() { return totalSpots; }
        public int getFilledSpots() { return filledSpots; }
        public int getCompaniesWithPositions() { return companiesWithPositions; }
        public double getUtilizationRate() { return utilizationRate; }

        // Helper methods
        public int getAvailableSpots() { return totalSpots - filledSpots; }
        public double getFillPercentage() {
            return totalSpots > 0 ? (double) filledSpots / totalSpots * 100 : 0;
        }
    }
}