<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection" %>
<%@ page import="com.mongodb.client.MongoDatabase" %>
<%@ page import="com.mongodb.client.FindIterable" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="com.student.util.NotificationUtil" %>
<%@ page import="org.bson.Document" %>

<%
    if(session.getAttribute("role") == null || !"admin".equals(session.getAttribute("role"))) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    long unreadCount = 0;
    try {
        MongoDatabase dbTmp = MongoDBUtil.getDatabase();
        MongoCollection<Document> colTmp = dbTmp.getCollection("notifications");
        Document unreadFilter = new Document("toUserType", "admin")
                .append("toUserId", NotificationUtil.ADMIN_ID)
                .append("isRead", false);
        unreadCount = colTmp.countDocuments(unreadFilter);
    } catch(Exception e) {
        unreadCount = 0;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Notifications</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 {
            color: #333;
            margin-bottom: 10px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            flex-wrap: wrap;
            gap: 15px;
        }
        .header-left {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .header-right {
            display: flex;
            gap: 10px;
        }
        .back-btn {
            padding: 10px 20px;
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            border: none;
            cursor: pointer;
        }
        .back-btn:hover {
            background-color: #7f8c8d;
        }
        .btn-all {
            padding: 10px 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
        }
        .btn-all:hover {
            opacity: 0.9;
        }
        .count-chip {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 999px;
            background: #e53e3e;
            color: #fff;
            font-size: 13px;
            font-weight: bold;
        }
        .notification-count {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        .card {
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            padding: 18px;
            margin-bottom: 15px;
            background: #fafbfc;
            transition: all 0.3s ease;
        }
        .card:hover {
            border-color: #667eea;
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.15);
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 10px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .title {
            font-weight: bold;
            font-size: 16px;
            color: #333;
        }
        .badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
        }
        .unread {
            background: #fff3cd;
            color: #856404;
            border: 1px solid #ffeeba;
        }
        .read {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .meta {
            color: #666;
            font-size: 12px;
            margin-bottom: 10px;
        }
        .msg {
            color: #333;
            font-size: 14px;
            line-height: 1.5;
            margin-top: 8px;
        }
        .actions {
            margin-top: 12px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .btn-read {
            padding: 8px 16px;
            background-color: #2ecc71;
            color: white;
            border: none;
            border-radius: 5px;
            font-weight: bold;
            cursor: pointer;
            font-size: 13px;
        }
        .btn-read:hover {
            background-color: #27ae60;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 18px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-left">
                <h1>🔔 Notifications (Admin)</h1>
                <% if(unreadCount > 0) { %>
                    <span class="count-chip"><%= unreadCount %> unread</span>
                <% } %>
            </div>
            <div class="header-right">
                <a class="back-btn" href="adminDashboard.jsp">← Back to Dashboard</a>
                <form action="<%=request.getContextPath()%>/MarkAllNotificationsReadServlet" method="post" style="display:inline;">
                    <button class="btn-all" type="submit">✓ Mark All as Read</button>
                </form>
            </div>
        </div>

        <%
            try {
                MongoDatabase db = MongoDBUtil.getDatabase();
                MongoCollection<Document> col = db.getCollection("notifications");

                FindIterable<Document> list = col.find(new Document("toUserType", "admin").append("toUserId", NotificationUtil.ADMIN_ID))
                                                .sort(new Document("createdAt", -1));

                boolean any = false;
                int totalCount = 0;
                for(Document n : list) {
                    totalCount++;
                }
                
                if(totalCount > 0) {
        %>
                    <div class="notification-count">
                        📊 Total Notifications: <strong><%= totalCount %></strong>
                    </div>
        <%
                }

                list = col.find(new Document("toUserType", "admin").append("toUserId", NotificationUtil.ADMIN_ID))
                         .sort(new Document("createdAt", -1));

                for(Document n : list) {
                    any = true;
                    boolean isRead = n.getBoolean("isRead", false);
        %>
            <div class="card">
                <div class="card-header">
                    <div class="title"><%= n.getString("title") %></div>
                    <span class="badge <%= isRead ? "read" : "unread" %>"><%= isRead ? "✓ READ" : "● UNREAD" %></span>
                </div>
                <div class="meta">
                    📂 Module: <strong><%= n.getString("module") %></strong> | 
                    🔗 Ref: <strong><%= n.getString("refId") %></strong> | 
                    🕒 Time: <strong><%= n.getString("createdAt") %></strong>
                </div>
                <div class="msg"><%= n.getString("message") %></div>

                <div class="actions">
                    <% if(!isRead) { %>
                    <form action="<%=request.getContextPath()%>/MarkNotificationReadServlet" method="post" style="display:inline;">
                        <input type="hidden" name="notificationId" value="<%= n.getObjectId("_id").toHexString() %>">
                        <input type="hidden" name="redirectTo" value="admin/notifications.jsp">
                        <button class="btn-read" type="submit">✓ Mark as Read</button>
                    </form>
                    <% } %>
                </div>
            </div>
        <%
                }

                if(!any) {
        %>
            <div class="no-data">📭 No notifications yet.</div>
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</body>
</html>
