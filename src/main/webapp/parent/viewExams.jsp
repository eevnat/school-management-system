<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection" %>
<%@ page import="com.mongodb.client.FindIterable" %>
<%@ page import="com.mongodb.client.MongoDatabase" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    // Determine User Role and Student Class
    String userRole = (String) session.getAttribute("role"); // 'student' or null (for parent session check)
    String userType = (String) session.getAttribute("userType"); // 'parent'
    
    String studentClass = "";
    
    if(userRole != null && userRole.equals("student")) {
        studentClass = (String) session.getAttribute("studentClass");
    } else if(userType != null && userType.equals("parent")) {
        studentClass = (String) session.getAttribute("studentClass");
    } else {
        response.sendRedirect("../index.jsp"); // Redirect if not logged in
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Exam Schedule</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
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
            text-align: center;
            margin-bottom: 10px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .back-btn {
            padding: 10px 20px;
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .back-btn:hover {
            background-color: #7f8c8d;
        }
        .exam-count {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        
        /* Exam Card Styles */
        .exam-card {
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            margin-bottom: 25px;
            overflow: hidden;
            border-left: 5px solid #48bb78;
        }
        .exam-card:hover {
            border-color: #48bb78;
            box-shadow: 0 4px 12px rgba(72, 187, 120, 0.15);
        }
        .exam-header {
            background: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 10px;
        }
        .exam-title { 
            font-size: 18px; 
            font-weight: bold; 
            color: #2c3e50; 
        }
        .exam-badge { 
            background: linear-gradient(135deg, #48bb78, #38a169); 
            color: white; 
            padding: 6px 14px; 
            border-radius: 20px; 
            font-size: 12px; 
            text-transform: uppercase;
            font-weight: bold;
        }
        .exam-note { 
            padding: 15px 20px; 
            color: #666; 
            font-style: italic; 
            background: #fffde7; 
            font-size: 14px; 
            border-bottom: 1px solid #e5e7eb; 
        }
        
        /* Table Styles */
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
            vertical-align: top;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        tr:last-child td {
            border-bottom: none;
        }
        .syllabus-text { 
            white-space: pre-wrap; 
            font-size: 13px; 
            color: #555; 
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
            <h1>📅 Exam Schedules & Syllabus</h1>
            <a href="javascript:history.back()" class="back-btn">← Back to Dashboard</a>
        </div>

        <%
            boolean hasExams = false;
            int examCount = 0;
            try {
                MongoDatabase db = MongoDBUtil.getDatabase();
                MongoCollection<Document> col = db.getCollection("exams");

                // Filter exams for student's class OR "All" (for competitions)
                Document filter = new Document("$or", java.util.Arrays.asList(
                    new Document("class", studentClass),
                    new Document("class", "All")
                ));

                // Count exams first
                for(Document doc : col.find(filter)) {
                    examCount++;
                }

                if(examCount > 0) {
        %>
                    <div class="exam-count">
                        📊 Total Exams Scheduled: <strong><%= examCount %></strong>
                    </div>
        <%
                }

                // Sort by creation date descending (newest first)
                FindIterable<Document> exams = col.find(filter).sort(new Document("createdAt", -1));

                for(Document doc : exams) {
                    hasExams = true;
                    String title = doc.getString("title");
                    String category = doc.getString("category");
                    String note = doc.getString("note");
                    List<Document> schedule = (List<Document>) doc.get("schedule");
        %>
            <div class="exam-card">
                <div class="exam-header">
                    <span class="exam-title"><%= title %></span>
                    <span class="exam-badge"><%= category %></span>
                </div>
                
                <% if(note != null && !note.trim().isEmpty()) { %>
                    <div class="exam-note">📢 Note: <%= note %></div>
                <% } %>

                <table>
                    <thead>
                        <tr>
                            <th width="15%">Date</th>
                            <th width="20%">Time</th>
                            <th width="10%">Code</th>
                            <th width="25%">Subject</th>
                            <th width="30%">Syllabus</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if(schedule != null) {
                            for(Document row : schedule) { 
                        %>
                            <tr>
                                <td><%= row.getString("date") %></td>
                                <td><%= row.getString("time") %></td>
                                <td><%= row.getString("code") != null ? row.getString("code") : "-" %></td>
                                <td><strong><%= row.getString("subject") %></strong></td>
                                <td><div class="syllabus-text"><%= row.getString("syllabus") != null ? row.getString("syllabus") : "-" %></div></td>
                            </tr>
                        <% 
                            } 
                        } 
                        %>
                    </tbody>
                </table>
            </div>
        <%
                }
            } catch(Exception e) {
                e.printStackTrace();
                out.println("<div class='no-data'>❌ Error loading exams: " + e.getMessage() + "</div>");
            }

            if(!hasExams) {
        %>
            <div class="no-data">📭 No exam schedules found for Class <%= studentClass %> yet.</div>
        <% } %>
    </div>
</body>
</html>
