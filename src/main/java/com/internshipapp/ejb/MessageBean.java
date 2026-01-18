package com.internshipapp.ejb;

import com.internshipapp.common.MessageDto;
import com.internshipapp.entities.*;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@Stateless
public class MessageBean {
    private static final Logger LOG = Logger.getLogger(MessageBean.class.getName());

    @PersistenceContext
    private EntityManager entityManager;

    public List<MessageDto> convertMessagesToDto(List<Message> messages) {
        List<MessageDto> dtos = new ArrayList<>();

        for (Message m : messages) {
            UserAccount user = m.getSender();
            String senderFullName = "";
            Long infoId = null;
            String pfpUrl = "/ProfilePicture?id=";

            // Using the new Info naming convention from your UserAccount entity
            if (m.getSenderRole() == Message.SenderRole.Student && user.getStudentInfo() != null) {
                infoId = user.getStudentInfo().getId();
                senderFullName = user.getStudentInfo().getFullName();
                pfpUrl += infoId + "&targetRole=Student";
            } else if (m.getSenderRole() == Message.SenderRole.Company && user.getCompanyInfo() != null) {
                infoId = user.getCompanyInfo().getId();
                senderFullName = user.getCompanyInfo().getName();
                pfpUrl += infoId + "&targetRole=Company";
            }

            dtos.add(new MessageDto(
                    m.getId(),
                    m.getApplication().getId(),
                    m.getSenderRole().name(),
                    infoId,
                    user.getUsername(),
                    senderFullName,
                    m.getMessageText(),
                    m.getTimeSent(),
                    pfpUrl
            ));
        }
        return dtos;
    }

    public void sendMessage(Long appId, Long senderUserId, String text, String role) {
        InternshipApplication app = entityManager.find(InternshipApplication.class, appId);
        UserAccount sender = entityManager.find(UserAccount.class, senderUserId);

        if (app == null || sender == null) return;

        // 1. If Company initiates chat, update Application state
        if ("Company".equals(role) || "Faculty".equals(role)) {
            if (!app.isChatInitiated()) {
                app.setChatInitiated(true);
                // Only move to Discussion if it's currently Pending
                if (app.getStatus() == InternshipApplication.ApplicationStatus.Pending) {
                    app.setStatus(InternshipApplication.ApplicationStatus.Discussion);
                }
                entityManager.merge(app);
            }
        }

        // 2. Create and Persist Message
        Message msg = new Message();
        msg.setApplication(app);
        msg.setSender(sender);
        msg.setMessageText(text);
        msg.setSenderRole(Message.SenderRole.valueOf(role));
        msg.setTimeSent(LocalDateTime.now());

        entityManager.persist(msg);
    }

    public List<MessageDto> getChatHistory(Long appId) {
        LOG.log(Level.INFO, "Fetching chat history for application {0}", appId);

        // Ensure query uses studentInfo and companyInfo as defined in UserAccount
        List<Message> messages = entityManager.createQuery(
                        "SELECT m FROM Message m " +
                                "JOIN FETCH m.sender u " +
                                "LEFT JOIN FETCH u.studentInfo s " +
                                "LEFT JOIN FETCH u.companyInfo c " +
                                "WHERE m.application.id = :appId " +
                                "ORDER BY m.timeSent ASC", Message.class)
                .setParameter("appId", appId)
                .getResultList();

        return convertMessagesToDto(messages);
    }
}