<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    String studentName = (String) session.getAttribute("studentName");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Notice Board</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); 
            margin: 0; 
            padding: 20px; 
            min-height: 100vh;
        }
        .container { 
            max-width: 900px; 
            margin: 0 auto; 
            background: #fff; 
            padding: 30px; 
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3); 
        }
        h1 { 
            text-align: center; 
            color: #333; 
            margin-bottom: 10px; 
        }
        .subtitle { 
            text-align: center; 
            color: #666; 
            margin-bottom: 20px; 
        }
        .back-btn { 
            padding: 8px 18px; 
            background: #95a5a6; 
            color: #fff; 
            text-decoration: none; 
            border-radius: 5px;
            font-weight: bold; 
            display: inline-block; 
            margin-bottom: 15px; 
        }
        .back-btn:hover {
            background: #7f8c8d;
        }
        .notice-list { 
            margin-top: 10px; 
        }
        .notice-card { 
            border: 1px solid #e2e8f0; 
            border-radius: 10px; 
            padding: 18px; 
            margin-bottom: 15px;
            background: #f9fafb; 
        }
        .notice-card:hover {
            border-color: #3b82f6;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
        }
        .notice-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 8px;
            flex-wrap: wrap;
            gap: 10px;
        }
        .notice-title { 
            font-weight: bold; 
            font-size: 16px; 
            color: #2d3748; 
        }
        .badge { 
            padding: 4px 10px; 
            border-radius: 999px; 
            font-size: 11px; 
            font-weight: bold; 
        }
        .badge-category { 
            background: linear-gradient(135deg, #3b82f6, #2563eb); 
            color: #fff; 
        }
        .badge-audience { 
            background: #e2e8f0; 
            color: #2d3748; 
            margin-left: 6px; 
        }
        .notice-meta { 
            font-size: 12px; 
            color: #718096; 
            margin-bottom: 8px; 
        }
        .notice-message { 
            font-size: 14px; 
            color: #4a5568; 
            white-space: pre-wrap; 
        }
        .no-data { 
            text-align: center; 
            padding: 40px 10px; 
            color: #999; 
        }
    </style>
</head>
<body>
<div class="container">
    <a href="studentDashboard.jsp" class="back-btn">← Back to Dashboard</a>

    <h1>📢 Notice Board</h1>
    <p class="subtitle">Hello <strong><%= studentName %></strong>, here are the latest school notices.</p>

    <div class="notice-list">
        <%
            try {
                MongoDatabase db = MongoDBUtil.getDatabase();
                MongoCollection<Document> notices = db.getCollection("notices");

                // ✅ Only notices for STUDENT or ALL, latest first (NEW values)
                ArrayList<Document> list = notices
                        .find(new Document("audience", new Document("$in",
                                java.util.Arrays.asList("ALL", "STUDENT"))))
                        .sort(new Document("createdDate", -1))
                        .into(new ArrayList<Document>());

                if(list.isEmpty()) {
        %>
                    <div class="no-data">📭 No notices available right now.</div>
        <%
                } else {
                    for(Document n : list) {
        %>
            <div class="notice-card">
                <div class="notice-header">
                    <div class="notice-title"><%= n.getString("title") %></div>
                    <div>
                        <span class="badge badge-category"><%= n.getString("category") %></span>
                        <span class="badge badge-audience"><%= n.getString("audience") %></span>
                    </div>
                </div>
                <div class="notice-meta">
                    Posted on <%= n.getString("createdDate") %> by <%= n.getString("createdBy") %>
                </div>
                <div class="notice-message"><%= n.getString("message") %></div>
            </div>
        <%
                    }
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error loading notices: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</div>
</body>
</html>
