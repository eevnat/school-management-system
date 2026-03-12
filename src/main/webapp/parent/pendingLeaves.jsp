<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection" %>
<%@ page import="com.mongodb.client.MongoDatabase" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.util.ArrayList" %>

<%
    // ✅ Correct parent session check (matches your parentDashboard.jsp)
    if(session.getAttribute("userType") == null || !session.getAttribute("userType").equals("parent")) {
        response.sendRedirect("parentLogin.jsp");
        return;
    }

    // ✅ Correct student roll number session key (matches your parentDashboard.jsp)
    String studentRollNumber = (String) session.getAttribute("studentRollNumber");
    if(studentRollNumber == null) {
        out.println("❌ Student Roll Number not found in session. Please login again.");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Pending Leaves (Parent)</title>
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
        .student-info {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        
        /* Table Styles */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
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

        .action-btn {
            padding: 8px 16px;
            background: linear-gradient(135deg, #48bb78, #38a169);
            color: white;
            text-decoration: none;
            border-radius: 6px;
            font-weight: bold;
            display: inline-block;
        }
        .action-btn:hover {
            opacity: 0.9;
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
        <h1>📝 Pending Leave Requests (Parent Approval)</h1>
        <a class="back-btn" href="parentDashboard.jsp">← Back to Dashboard</a>
    </div>
    
    <div class="student-info">
        Showing requests for Roll Number: <strong><%= studentRollNumber %></strong>
    </div>

    <%
        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> col = db.getCollection("leaveRequests");

            ArrayList<Document> list = col.find(
                    new Document("rollNumber", studentRollNumber)
                            .append("status", "PENDING_PARENT")
            ).into(new ArrayList<>());

            if(list.isEmpty()) {
    %>
        <div class="no-data">📭 No pending leave requests.</div>
    <%
            } else {
    %>
        <table>
            <thead>
                <tr>
                    <th>Leave ID</th>
                    <th>Student</th>
                    <th>From Date</th>
                    <th>To Date</th>
                    <th>Type</th>
                    <th>Reason</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <%
                for(Document d : list) {
            %>
                <tr>
                    <td><%= d.getString("leaveId") %></td>
                    <td><%= d.getString("studentName") %></td>
                    <td><%= d.getString("fromDate") %></td>
                    <td><%= d.getString("toDate") %></td>
                    <td><%= d.getString("leaveType") %></td>
                    <td><%= d.getString("reason") %></td>
                    <td>
                        <a class="action-btn" href="reviewLeave.jsp?leaveId=<%= d.getString("leaveId") %>">Review</a>
                    </td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
            }
        } catch(Exception e) {
            out.println("<div class='no-data'>❌ Error loading pending leaves: " + e.getMessage() + "</div>");
            e.printStackTrace();
        }
    %>
</div>
</body>
</html>
