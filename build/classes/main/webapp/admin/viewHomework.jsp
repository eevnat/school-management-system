<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.time.LocalDate" %>
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
    <title>View Homework - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
        
        .homework-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
            border-left: 5px solid #f093fb;
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
        
        .delete-btn {
            background: #ef4444;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 14px;
        }
        
        .delete-btn:hover {
            background: #dc2626;
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
            align-items: end;
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
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
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
        <h1><i class="fas fa-tasks"></i> All Homework Assignments</h1>
        <a href="adminDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <form method="GET" class="filter-section">
            <select name="className">
                <option value="">All Classes</option>
                <option value="1">Class 1</option>
                <option value="2">Class 2</option>
                <option value="3">Class 3</option>
                <option value="4">Class 4</option>
                <option value="5">Class 5</option>
                <option value="6">Class 6</option>
                <option value="7">Class 7</option>
                <option value="8">Class 8</option>
                <option value="9">Class 9</option>
                <option value="10">Class 10</option>
                <option value="11">Class 11</option>
                <option value="12">Class 12</option>
            </select>
            
            <select name="subject">
                <option value="">All Subjects</option>
                <option value="Mathematics">Mathematics</option>
                <option value="English">English</option>
                <option value="Science">Science</option>
                <option value="Physics">Physics</option>
                <option value="Chemistry">Chemistry</option>
                <option value="Biology">Biology</option>
            </select>
            
            <button type="submit" class="filter-btn">
                <i class="fas fa-filter"></i> Filter
            </button>
        </form>
        
        <%
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> homeworkCollection = database.getCollection("homework");
            
            String classFilter = request.getParameter("className");
            String subjectFilter = request.getParameter("subject");
            
            Document query = new Document();
            if (classFilter != null && !classFilter.isEmpty()) {
                query.append("className", classFilter);
            }
            if (subjectFilter != null && !subjectFilter.isEmpty()) {
                query.append("subject", subjectFilter);
            }
            
            int count = 0;
            LocalDate today = LocalDate.now();
            
            for (Document hw : homeworkCollection.find(query).sort(new Document("assignedDate", -1))) {
                count++;
                String title = hw.getString("title");
                String subject = hw.getString("subject");
                String className = hw.getString("className");
                String section = hw.getString("section");
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
                            <i class="fas fa-chalkboard"></i> Class <%= className %>-<%= section %>
                        </span>
                        <span class="meta-item">
                            <i class="fas fa-calendar"></i> Due: <%= dueDate %>
                        </span>
                    </div>
                </div>
                <span class="status-badge <%= isOverdue ? "overdue" : "active" %>">
                    <%= isOverdue ? "Overdue" : "Active" %>
                </span>
            </div>
            
            <div class="homework-description">
                <%= description %>
            </div>
            
            <% if (attachmentPath != null) { %>
            <div style="margin-bottom: 10px;">
                <a href="../<%= attachmentPath %>" target="_blank" style="color: #3b82f6; text-decoration: none;">
                    <i class="fas fa-paperclip"></i> View Attachment
                </a>
            </div>
            <% } %>
            
            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 13px; color: #999;">
                <span><i class="fas fa-user"></i> Assigned by: <%= assignedBy %></span>
                <form method="POST" action="../DeleteHomeworkServlet" style="display: inline;" onsubmit="return confirm('Are you sure you want to delete this homework?');">
                    <input type="hidden" name="homeworkId" value="<%= hw.getObjectId("_id").toString() %>">
                    <button type="submit" class="delete-btn">
                        <i class="fas fa-trash"></i> Delete
                    </button>
                </form>
            </div>
        </div>
        
        <%
            }
            
            if (count == 0) {
        %>
        <div class="no-data">
            <i class="fas fa-book-open"></i>
            <h3>No homework assignments found</h3>
            <p>Create your first homework assignment!</p>
        </div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>
