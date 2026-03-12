<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%
    if(session.getAttribute("userType") == null || !session.getAttribute("userType").equals("parent")) {
        response.sendRedirect("parentLogin.jsp");
        return;
    }
    
    String studentId = (String) session.getAttribute("studentId");
    String studentRollNumber = (String) session.getAttribute("studentRollNumber");
    String studentName = (String) session.getAttribute("studentName");
    
    // If studentId is null, try to get it from database
    if (studentId == null || studentId.isEmpty()) {
        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> studentCol = db.getCollection("students");
            Document student = studentCol.find(new Document("rollNumber", studentRollNumber)).first();
            if (student != null) {
                studentId = student.getString("studentId");
                session.setAttribute("studentId", studentId);
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Child's Behavior History - Parent Portal</title>
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
            max-width: 1000px;
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
        
        .log-category {
            font-size: 16px;
            font-weight: bold;
            color: #333;
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
        
        .stats-summary {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .stat-box {
            padding: 20px;
            border-radius: 12px;
            color: white;
            text-align: center;
        }
        
        .stat-box.positive {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .stat-box.warning {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .stat-box.severe {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        
        .stat-box h3 {
            font-size: 32px;
            margin-bottom: 5px;
        }
        
        .stat-box p {
            opacity: 0.9;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-star"></i> Child's Behavior History</h1>
        <a href="parentDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <div class="child-info">
            <h3>⭐ Behavior & Feedback For</h3>
            <p><strong>Student:</strong> <%= studentName %></p>
        </div>
        
        <%
            if (studentId == null || studentId.isEmpty()) {
        %>
        <div class="no-data">
            <i class="fas fa-exclamation-triangle"></i>
            <h3>Unable to load behavior logs</h3>
            <p>Student ID not found. Please logout and login again.</p>
        </div>
        <%
            } else {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> behaviorCollection = database.getCollection("behavior_logs");
                
                String typeFilter = request.getParameter("type");
                
                Document query = new Document("studentId", studentId);
                if (typeFilter != null && !typeFilter.isEmpty()) {
                    query.append("type", typeFilter);
                }
                
                int positiveCount = 0;
                int warningCount = 0;
                int severeCount = 0;
                
                // Count by type
                positiveCount = (int) behaviorCollection.countDocuments(new Document("studentId", studentId).append("type", "POSITIVE"));
                warningCount = (int) behaviorCollection.countDocuments(new Document("studentId", studentId).append("type", "WARNING"));
                severeCount = (int) behaviorCollection.countDocuments(new Document("studentId", studentId).append("type", "SEVERE"));
        %>
        
        <div class="stats-summary">
            <div class="stat-box positive">
                <h3><%= positiveCount %></h3>
                <p>👍 Positive</p>
            </div>
            <div class="stat-box warning">
                <h3><%= warningCount %></h3>
                <p>⚠️ Warnings</p>
            </div>
            <div class="stat-box severe">
                <h3><%= severeCount %></h3>
                <p>🚨 Severe</p>
            </div>
        </div>
        
        <form method="GET" class="filter-section">
            <select name="type">
                <option value="">All Types</option>
                <option value="POSITIVE" <%= "POSITIVE".equals(typeFilter) ? "selected" : "" %>>Positive</option>
                <option value="WARNING" <%= "WARNING".equals(typeFilter) ? "selected" : "" %>>Warning</option>
                <option value="SEVERE" <%= "SEVERE".equals(typeFilter) ? "selected" : "" %>>Severe</option>
            </select>
            <button type="submit" class="filter-btn">
                <i class="fas fa-filter"></i> Filter
            </button>
        </form>
        
        <%
            int count = 0;
            for (Document log : behaviorCollection.find(query).sort(new Document("timestamp", -1))) {
                count++;
                String type = log.getString("type");
                String emoji = type.equals("POSITIVE") ? "👍" : (type.equals("WARNING") ? "⚠️" : "🚨");
        %>
        
        <div class="log-card <%= type.toLowerCase() %>">
            <div class="log-header">
                <div class="log-category">
                    <%= log.getString("category") %>
                </div>
                <div class="log-type"><%= emoji %></div>
            </div>
            
            <div class="log-meta">
                Logged by: <%= log.getString("loggedBy") %> | 
                <%= log.getString("timestamp") != null ? log.getString("timestamp").substring(0, 19).replace("T", " ") : "" %>
            </div>
            
            <div class="log-description">
                <%= log.getString("description") %>
            </div>
        </div>
        
        <%
            }
            
            if (count == 0) {
        %>
        <div class="no-data">
            <i class="fas fa-clipboard-list"></i>
            <h3>No behavior logs found</h3>
            <p>No feedback recorded yet 🌟</p>
        </div>
        <%
            }
        }
        %>
    </div>
</div>

</body>
</html>
