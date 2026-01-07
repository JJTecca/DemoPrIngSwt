<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.internshipapp.common.*" %>
<%@ page import="java.util.List" %>
<%
    // 1. Authentication and Data Retrieval
    List<InternshipApplicationDto> sidebarApps = (List<InternshipApplicationDto>) request.getAttribute("applications");
    InternshipApplicationDto activeApp = (InternshipApplicationDto) request.getAttribute("activeApplication");
    List<MessageDto> chatHistory = (List<MessageDto>) request.getAttribute("chatHistory");
    CompanyInfoDto company = (CompanyInfoDto) request.getAttribute("companyInfo");
    String role = (String) session.getAttribute("userRole");
    Long userId = (Long) session.getAttribute("userId");

    if (session == null || userId == null) {
        response.sendRedirect(request.getContextPath() + "/UserLogin");
        return;
    }

    boolean isHired = activeApp != null && ("Accepted".equals(activeApp.getStatus()) || "Completed".equals(activeApp.getStatus()));

    // 2. Personalized Greetings Logic
    String personalizedTitle = "Welcome to your Workspace";
    String personalizedMessage = "Select an application to view details. If a company initiates a discussion, you will see it here.";

    if ("Student".equals(role) && sidebarApps != null) {
        boolean hasAccepted = sidebarApps.stream().anyMatch(a -> "Accepted".equals(a.getStatus()));
        boolean hasInterview = sidebarApps.stream().anyMatch(a -> "Interview".equals(a.getStatus()));
        boolean hasDiscussion = sidebarApps.stream().anyMatch(a -> "Discussion".equals(a.getStatus()));

        if (hasAccepted) {
            personalizedTitle = "Congratulations!";
            personalizedMessage = "One of your applications has been accepted! Check the details tab for the company's contact info.";
        } else if (hasInterview) {
            personalizedTitle = "Upcoming Interviews";
            personalizedMessage = "You have scheduled interviews. Review the time and location in the Application Details tab.";
        } else if (hasDiscussion) {
            personalizedTitle = "Active Discussions";
            personalizedMessage = "Companies are messaging you! Look for the blue indicator in the sidebar to reply.";
        } else if (!sidebarApps.isEmpty()) {
            personalizedTitle = "Applications Sent";
            personalizedMessage = "Your applications are currently pending review. You will be notified once a company starts a conversation.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Applications Hub - CSEE ULBS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/global.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f7f9;
        }

        .main-container {
            height: calc(100vh - 72px);
            display: flex !important;
            align-items: stretch;
            overflow: hidden;
        }

        /* Sidebars Positioning */
        .sidebar-container, .applications-sidebar {
            height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            top: 0 !important;
            position: relative;
        }

        /* Main Content Column */
        .content-pane {
            flex: 1;
            background: white;
            display: flex;
            flex-direction: column;
            justify-content: flex-start !important;
            overflow: hidden;
            animation: fadeIn 0.4s ease-in-out;
        }

        /* Tab Content filled height */
        .tab-content {
            flex: 1;
            display: block; /* Standard block to prevent centering */
            position: relative;
            overflow: hidden;
        }

        /* Pane Visibility Sync */
        .tab-pane {
            display: none;
            height: 100%;
            width: 100%;
        }

        .tab-pane.active {
            display: block;
        }

        /* Chat specific flex for input stickiness */
        #chatContent.active {
            display: flex !important;
            flex-direction: column;
        }

        /* Chat UI */
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 25px;
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .bubble {
            max-width: 75%;
            padding: 12px 18px;
            border-radius: 18px;
            font-size: 0.95rem;
            line-height: 1.5;
        }

        .bubble-in {
            background: white;
            align-self: flex-start;
            border: 1px solid #eee;
        }

        .bubble-out {
            background: linear-gradient(135deg, #0E2B58 0%, #1a4a8d 100%);
            color: white;
            align-self: flex-end;
        }

        .chat-pfp {
            width: 32px;
            height: 32px;
            object-fit: cover;
        }

        /* Header & Tabs */
        .hub-header {
            background: white;
            border-bottom: 1px solid #eef2f5;
            padding: 1rem 1.5rem;
        }

        .nav-tabs-custom {
            border-bottom: 1px solid #eef2f5;
            padding: 0 1.5rem;
        }

        .nav-tabs-custom .nav-link {
            border: none;
            padding: 1rem 1.5rem;
            font-weight: 700;
            color: #888;
            position: relative;
        }

        .nav-tabs-custom .nav-link.active {
            color: #0E2B58;
        }

        .nav-tabs-custom .nav-link.active::after {
            content: "";
            position: absolute;
            bottom: 0;
            left: 1.5rem;
            right: 1.5rem;
            height: 3px;
            background: #0E2B58;
            border-radius: 3px 3px 0 0;
        }

        .form-control-chat {
            border-radius: 30px;
            padding: 12px 25px;
            background: #fdfdfd;
            border: 1px solid #eef2f5;
        }

        .empty-hub-icon {
            font-size: 5rem;
            background: linear-gradient(135deg, #eef2f5 0%, #dce3e8 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(5px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .app-card {
            transition: all 0.2s ease-in-out;
        }

        .app-card:hover {
            transform: translateX(5px);
            background-color: #f8f9fa;
        }
    </style>
</head>
<body>

<jsp:include page="../blocks/header.jsp"/>

<div class="container-fluid p-0">
    <div class="main-container">
        <%-- Sidebars --%>
        <jsp:include page='<%= "../blocks/" + role.toLowerCase() + "Sidebar.jsp" %>'/>
        <jsp:include page="../blocks/applicationsSidebar.jsp"/>

        <main class="content-pane">
            <% if (activeApp == null) { %>
            <div class="m-auto text-center p-5" style="max-width: 600px;">
                <div class="empty-hub-icon mb-4"><i class="fa-solid fa-comments"></i></div>
                <h3 class="fw-bold text-dark"><%= "Faculty".equals(role) ? "Tutoring Management Hub" : personalizedTitle %>
                </h3>
                <p class="text-muted lead"><%= "Faculty".equals(role) ? "Review qualifications or finalize assignments." : personalizedMessage %>
                </p>
            </div>
            <% } else { %>
            <div class="hub-header d-flex justify-content-between align-items-center shadow-sm">
                <div class="d-flex align-items-center gap-3">
                    <div class="bg-primary-subtle p-2 rounded-3 text-primary"><i
                            class="fa-solid fa-briefcase fa-lg"></i></div>
                    <div>
                        <h5 class="fw-bold mb-0 text-dark"><%= activeApp.getPositionTitle() %>
                        </h5>
                        <span class="small text-muted fw-semibold">Discussion with <%= "Student".equals(role) ? activeApp.getCompanyName() : activeApp.getStudentName() %></span>
                    </div>
                </div>
                <div class="text-end">
                    <div class="small fw-bold text-muted"><i
                            class="fa-regular fa-envelope me-2"></i><%= (company.getContactEmail() != null) ? company.getContactEmail() : "N/A" %>
                    </div>
                    <% if (isHired) { %>
                    <div class="small fw-bold text-success mt-1"><i
                            class="fa-solid fa-phone-volume me-2"></i><%= (company.getPhoneNumber() != null) ? company.getPhoneNumber() : "Phone N/A" %>
                    </div>
                    <% } %>
                </div>
            </div>

            <ul class="nav nav-tabs nav-tabs-custom" id="hubTabs" role="tablist">
                <% boolean chatIsPrimary = activeApp.isChatInitiated() || !"Student".equals(role); %>
                <% if (chatIsPrimary) { %>
                <li class="nav-item">
                    <button class="nav-link active" id="chat-tab" data-bs-toggle="tab" data-bs-target="#chatContent"
                            type="button">CHAT
                    </button>
                </li>
                <% } %>
                <li class="nav-item">
                    <button class="nav-link <%= !chatIsPrimary ? "active" : "" %>" id="details-tab" data-bs-toggle="tab"
                            data-bs-target="#detailsContent" type="button">APPLICATION DETAILS
                    </button>
                </li>
            </ul>

            <div class="tab-content">
                <%-- Tab 1: Chat --%>
                <div class="tab-pane fade <%= chatIsPrimary ? "show active" : "" %>" id="chatContent" role="tabpanel">
                    <div class="chat-messages custom-scrollbar">
                        <% if (chatHistory != null && !chatHistory.isEmpty()) {
                            for (MessageDto msg : chatHistory) {
                                boolean isMe = (userId.equals(msg.getSenderId())); %>
                        <div class="d-flex <%= isMe ? "justify-content-end" : "justify-content-start" %> mb-2">
                            <% if (!isMe) { %><img src="<%= msg.getSenderPfpUrl() %>"
                                                   class="chat-pfp rounded-circle me-2 mt-auto border shadow-sm"><% } %>
                            <div class="bubble <%= isMe ? "bubble-out" : "bubble-in" %>">
                                <% if (!isMe) { %>
                                <div class="fw-bold mb-1" style="font-size: 0.75rem;"><%= msg.getSenderName() %>
                                </div>
                                <% } %>
                                <div class="message-text"><%= msg.getMessageText() %>
                                </div>
                                <div class="text-end mt-1 opacity-50"
                                     style="font-size: 0.65rem;"><%= msg.getTimeSent().toString().substring(11, 16) %>
                                </div>
                            </div>
                            <% if (isMe) { %><img src="<%= msg.getSenderPfpUrl() %>"
                                                  class="chat-pfp rounded-circle ms-2 mt-auto border shadow-sm"><% } %>
                        </div>
                        <% }
                        } else { %>
                        <div class="m-auto text-center opacity-50">
                            <i class="fa-regular fa-comments fa-3x mb-3"></i>
                            <p class="fw-bold">No messages yet.</p>
                        </div>
                        <% } %>
                    </div>
                    <div class="p-3 border-top bg-white">
                        <% if ("Rejected".equals(activeApp.getStatus())) { %>
                        <div class="alert alert-secondary mb-0 py-2 text-center small border-0 bg-light">Closed.
                            Messaging disabled.
                        </div>
                        <% } else { %>
                        <form action="SendMessage" method="POST" class="d-flex gap-2">
                            <input type="hidden" name="appId" value="<%= activeApp.getId() %>">
                            <input type="text" name="message" class="form-control form-control-chat"
                                   placeholder="Type a message..." required autocomplete="off">
                            <button type="submit" class="btn btn-primary rounded-circle"
                                    style="width: 48px; height: 48px;"><i class="fa-solid fa-paper-plane"></i></button>
                        </form>
                        <% } %>
                    </div>
                </div>

                <%-- Tab 2: Details --%>
                <div class="tab-pane fade <%= !chatIsPrimary ? "show active" : "" %> p-5 overflow-auto custom-scrollbar"
                     id="detailsContent" role="tabpanel">
                    <div class="row g-5 align-items-start">
                        <div class="col-lg-7">
                            <div class="mb-5">
                                <h6 class="text-uppercase fw-bold text-muted mb-3"
                                    style="letter-spacing: 1.5px; font-size: 0.7rem;">Job Description</h6>
                                <p class="text-dark leading-relaxed"
                                   style="white-space: pre-wrap;"><%= (activeApp.getDescription() != null) ? activeApp.getDescription() : "No description." %>
                                </p>
                            </div>
                            <div class="mb-5">
                                <h6 class="text-uppercase fw-bold text-muted mb-3"
                                    style="letter-spacing: 1.5px; font-size: 0.7rem;">Requirements</h6>
                                <p class="text-dark leading-relaxed"
                                   style="white-space: pre-wrap;"><%= (activeApp.getRequirements() != null) ? activeApp.getRequirements() : "No requirements." %>
                                </p>
                            </div>
                        </div>
                        <div class="col-lg-5">
                            <% if (!"Student".equals(role)) { %>
                            <div class="card border-0 shadow-sm p-4 bg-light border-start border-primary border-4">
                                <h5 class="fw-bold mb-4">Management</h5>
                                <form action="InternshipApplications" method="GET">
                                    <input type="hidden" name="action" value="updateStatus"><input type="hidden"
                                                                                                   name="id"
                                                                                                   value="<%= activeApp.getId() %>">
                                    <div class="mb-3"><label class="small fw-bold">Interview Date</label><input
                                            type="datetime-local" name="interviewDate" class="form-control"
                                            value="<%= activeApp.getInterview() %>"></div>
                                    <div class="mb-3"><label class="small fw-bold">Location</label><input type="text"
                                                                                                          name="location"
                                                                                                          class="form-control"
                                                                                                          value="<%= activeApp.getInterviewLocation() %>">
                                    </div>
                                    <div class="mb-4"><label class="small fw-bold">Status</label>
                                        <select name="status" class="form-select">
                                            <option value="Discussion" <%= "Discussion".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Discussion
                                            </option>
                                            <option value="Interview" <%= "Interview".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Interview
                                            </option>
                                            <option value="Accepted" <%= "Accepted".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Accepted
                                            </option>
                                            <option value="Rejected" <%= "Rejected".equals(activeApp.getStatus()) ? "selected" : "" %>>
                                                Rejected
                                            </option>
                                        </select>
                                    </div>
                                    <button type="submit" class="btn btn-primary w-100 fw-bold">Update</button>
                                </form>
                            </div>
                            <% } else { %>
                            <div class="card border-0 shadow-sm p-4 text-center bg-white">
                                <div class="mb-3 text-primary"><i class="fa-regular fa-calendar-check fa-3x"></i></div>
                                <h6 class="fw-bold">Interview Schedule</h6>
                                <hr class="my-3 opacity-10">
                                <% if (activeApp.getInterview() != null) { %>
                                <div class="mb-4">
                                    <div class="text-muted small fw-bold">Time</div>
                                    <div class="fw-bold"><%= activeApp.getInterview().toString().replace("T", " ") %>
                                    </div>
                                </div>
                                <div>
                                    <div class="text-muted small fw-bold">Location</div>
                                    <div class="fw-bold text-primary"><%= activeApp.getInterviewLocation() %>
                                    </div>
                                </div>
                                <% } else { %><p class="text-muted small italic">No interview scheduled yet.</p><% } %>
                            </div>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </main>
    </div>
</div>

<jsp:include page="../blocks/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.app-card').forEach(link => {
        link.addEventListener('click', () => {
            const sidebar = document.querySelector('.flex-grow-1.overflow-auto');
            if (sidebar) localStorage.setItem('sidebarScroll', sidebar.scrollTop);
        });
    });
    window.addEventListener('load', () => {
        const sidebar = document.querySelector('.flex-grow-1.overflow-auto');
        const scrollPos = localStorage.getItem('sidebarScroll');
        if (scrollPos && sidebar) sidebar.scrollTop = scrollPos;
    });
</script>
</body>
</html>