package com.internshipapp.websocket;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Set;
import java.util.Collections;

@ServerEndpoint("/chat-socket/{appId}")
public class ChatSocket {
    // Thread-safe map: Key is Application ID, Value is a Set of active browser sessions
    private static final ConcurrentHashMap<Long, Set<Session>> sessionsByAppId = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("appId") Long appId) {
        sessionsByAppId.computeIfAbsent(appId, k -> Collections.synchronizedSet(new java.util.HashSet<>())).add(session);
    }

    @OnClose
    public void onClose(Session session, @PathParam("appId") Long appId) {
        Set<Session> sessions = sessionsByAppId.get(appId);
        if (sessions != null) {
            sessions.remove(session);
            if (sessions.isEmpty()) sessionsByAppId.remove(appId);
        }
    }

    // This method is called by the Servlet to ping all users in the specific room
    public static void notify(Long appId) {
        Set<Session> sessions = sessionsByAppId.get(appId);
        if (sessions != null) {
            synchronized (sessions) {
                for (Session s : sessions) {
                    if (s.isOpen()) {
                        try {
                            s.getBasicRemote().sendText("NEW_MESSAGE");
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                }
            }
        }
    }
}