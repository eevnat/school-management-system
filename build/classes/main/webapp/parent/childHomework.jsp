<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.time.LocalDate" %>
<%
    if(session.getAttribute("userType") == null || !session.getAttribute("userType").equals("parent")) {
        response.sendRedirect("parentLogin.jsp");
        return;
    }
    
    String studentClass = (String) session.getAttribute("studentClass");
    String studentSection = (String) session.getAttribute("studentSection");
    String studentName = (String) session.getAttribute("studentName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Child's Homework - Parent Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
            padding: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .header h1 {
            font-size: 28px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
        
        .back-btn {
            background: rgba(255,255,255,0.2);
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .content {
            padding: 40px;
        }
        
        .child-info {
            background: #e6fffa;
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 30px;
            border-left: 4px solid #48bb78;
        }
        
        .child-info h3 {
            color: #2f855a;
            margin-bottom: 5px;
        }
        
        .child-info p {
            color: #276749;
            font-size: 14px;
        }
        
        .homework-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
            border-left: 5px solid #48bb78;
            transition: all 0.3s;
        }
        
        .homework-card:hover {
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transform: translateX(5px);
        }
        
        .homework-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
        }
        
        .homework-title {
            font-size: 20px;
            font-weight: bold;
            color: #333;
            margin-bottom: 5px;
        }
        
        .homework-meta {
            display: flex;
            gap: 20px;
            flex-wrap: wrap;
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .homework-description {
            color: #555;
            line-height: 1.6;
            margin-bottom: 15px;
        }
        
        .status-badge {
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-badge.active {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-badge.overdue {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .attachment-link {
            display: inline-block;
            margin-bottom: 10px;
            color: #48bb78;
            text-decoration: none;
            font-weight: 500;
        }
        
        .attachment-link:hover {
            text-decoration: underline;
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #6b7280;
        }
        
        .no-data i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
        
        .filter-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            gap: 15px;
            align-items: center;
            flex-wrap: wrap;
        }
        
        .filter-section select {
            padding: 10px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            flex: 1;
            min-width: 150px;
        }
        
        .filter-btn {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-book-reader"></i> Child's Homework Tracker</h1>
        <a href="parentDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <div class="child-info">
            <h3>📚 Tracking Homework For</h3>
            <p><strong>Student:</strong> <%= studentName %> | <strong>Class:</strong> <%= studentClass %>-<%= studentSection %></p>
        </div>
        
        <form method="GET" class="filter-section">
            <select name="subject">
                <option value="">All Subjects</option>
                <option value="Mathematics">Mathematics</option>
                <option value="English">English</option>
                <option value="Science">Science</option>
                <option value="Physics">Physics</option>
                <option value="Chemistry">Chemistry</option>
                <option value="Biology">Biology</option>
                <option value="History">History</option>
                <option value="Geography">Geography</option>
            </select>
            
            <button type="submit" class="filter-btn">
                <i class="fas fa-filter"></i> Filter
            </button>
        </form>
        
        <%
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> homeworkCollection = database.getCollection("homework");
            
            String subjectFilter = request.getParameter("subject");
            
            Document query = new Document("className", studentClass)
                    .append("section", studentSection)
                    .append("active", true);
            
            if (subjectFilter != null && !subjectFilter.isEmpty()) {
                query.append("subject", subjectFilter);
            }
            
            int count = 0;
            LocalDate today = LocalDate.now();
            
            for (Document hw : homeworkCollection.find(query).sort(new Document("assignedDate", -1))) {
                count++;
                String title = hw.getString("title");
                String subject = hw.getString("subject");
                String description = hw.getString("description");
                String dueDate = hw.getString("dueDate");
                String assignedBy = hw.getString("assignedBy");
                String attachmentPath = hw.getString("attachmentPath");
                
                boolean isOverdue = LocalDate.parse(dueDate).isBefore(today);
        %>
        
        <div class="homework-card">
            <div class="homework-header">
                <div>
                    <div class="homework-title"><%= title %></div>
                    <div class="homework-meta">
                        <span class="meta-item">
                            <i class="fas fa-book"></i> <%= subject %>
                        </span>
                        <span class="meta-item">
                            <i class="fas fa-calendar"></i> Due: <%= dueDate %>
                        </span>
                        <span class="meta-item">
                            <i class="fas fa-user"></i> <%= assignedBy %>
                        </span>
                    </div>
                </div>
                <span class="status-badge <%= isOverdue ? "overdue" : "active" %>">
                    <%= isOverdue ? "⚠️ Overdue" : "✅ Active" %>
                </span>
            </div>
            
            <div class="homework-description">
                <%= description %>
            </div>
            
            <% if (attachmentPath != null && !attachmentPath.isEmpty()) { %>
            <a href="../<%= attachmentPath %>" target="_blank" class="attachment-link">
                <i class="fas fa-paperclip"></i> Download Attachment
            </a>
            <% } %>
        </div>
        
        <%
            }
            
            if (count == 0) {
        %>
        <div class="no-data">
            <i class="fas fa-book-open"></i>
            <h3>No homework assignments found</h3>
            <p>Your child is all caught up! 🎉</p>
        </div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>
