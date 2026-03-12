<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Behavior History - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
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
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
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
        
        .content {
            padding: 40px;
        }
        
        .filter-section {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            gap: 15px;
            align-items: end;
            flex-wrap: wrap;
        }
        
        .filter-section select,
        .filter-section input {
            padding: 10px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            flex: 1;
            min-width: 150px;
        }
        
        .filter-btn {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
            color: white;
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
        }
        
        .log-card {
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 15px;
            border-left: 5px solid;
        }
        
        .log-card.positive {
            background: #d1fae5;
            border-color: #10b981;
        }
        
        .log-card.warning {
            background: #fef3c7;
            border-color: #f59e0b;
        }
        
        .log-card.severe {
            background: #fee2e2;
            border-color: #ef4444;
        }
        
        .log-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        
        .log-student {
            font-size: 18px;
            font-weight: bold;
        }
        
        .log-type {
            font-size: 24px;
        }
        
        .log-meta {
            font-size: 13px;
            color: #666;
            margin-bottom: 10px;
        }
        
        .log-description {
            color: #333;
            line-height: 1.5;
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
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-history"></i> Behavior History</h1>
        <a href="adminDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <form method="GET" class="filter-section">
            <input type="text" name="studentId" placeholder="Search by Student ID" value="<%= request.getParameter("studentId") != null ? request.getParameter("studentId") : "" %>">
            
            <select name="type">
                <option value="">All Types</option>
                <option value="POSITIVE" <%= "POSITIVE".equals(request.getParameter("type")) ? "selected" : "" %>>Positive</option>
                <option value="WARNING" <%= "WARNING".equals(request.getParameter("type")) ? "selected" : "" %>>Warning</option>
                <option value="SEVERE" <%= "SEVERE".equals(request.getParameter("type")) ? "selected" : "" %>>Severe</option>
            </select>
            
            <select name="category">
                <option value="">All Categories</option>
                <option value="Discipline">Discipline</option>
                <option value="Participation">Class Participation</option>
                <option value="Conduct">General Conduct</option>
                <option value="Punctuality">Punctuality</option>
                <option value="Academic">Academic Excellence</option>
                <option value="Sports">Sports & Athletics</option>
                <option value="Leadership">Leadership</option>
                <option value="Bullying">Bullying/Harassment</option>
                <option value="Other">Other</option>
            </select>
            
            <button type="submit" class="filter-btn">
                <i class="fas fa-search"></i> Filter
            </button>
        </form>
        
        <%
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> behaviorCollection = database.getCollection("behavior_logs");
            
            Document query = new Document();
            String studentIdFilter = request.getParameter("studentId");
            String typeFilter = request.getParameter("type");
            String categoryFilter = request.getParameter("category");
            
            if (studentIdFilter != null && !studentIdFilter.isEmpty()) {
                query.append("studentId", studentIdFilter);
            }
            if (typeFilter != null && !typeFilter.isEmpty()) {
                query.append("type", typeFilter);
            }
            if (categoryFilter != null && !categoryFilter.isEmpty()) {
                query.append("category", categoryFilter);
            }
            
            int count = 0;
            for (Document log : behaviorCollection.find(query).sort(new Document("timestamp", -1))) {
                count++;
                String type = log.getString("type");
                String emoji = type.equals("POSITIVE") ? "👍" : (type.equals("WARNING") ? "⚠️" : "🚨");
        %>
        
        <div class="log-card <%= type.toLowerCase() %>">
            <div class="log-header">
                <div class="log-student">
                    <%= log.getString("studentName") %> 
                    <span style="font-size: 14px; color: #666;">
                        (Roll: <%= log.getString("rollNumber") %> | Class <%= log.getString("className") %>-<%= log.getString("section") %>)
                    </span>
                </div>
                <div class="log-type"><%= emoji %></div>
            </div>
            
            <div class="log-meta">
                <strong><%= log.getString("category") %></strong> | 
                Logged by: <%= log.getString("loggedBy") %> | 
                <%= log.getString("timestamp") != null ? log.getString("timestamp").substring(0, 19).replace("T", " ") : "" %>
            </div>
            
            <div class="log-description">
                <%= log.getString("description") %>
            </div>
            
            <% if (log.getBoolean("notifyParent", false)) { %>
            <div style="margin-top: 10px; font-size: 12px; color: #666;">
                <i class="fas fa-bell"></i> Parent was notified
            </div>
            <% } %>
        </div>
        
        <%
            }
            
            if (count == 0) {
        %>
        <div class="no-data">
            <i class="fas fa-clipboard-list"></i>
            <h3>No behavior logs found</h3>
            <p>Try adjusting your filters or add new behavior logs</p>
        </div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>
