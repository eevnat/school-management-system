<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Leave Requests (Admin)</title>
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
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 18px;
        }
        .request-count {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        .action-btn {
            padding: 8px 14px;
            margin: 0 3px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            text-decoration: none;
            display: inline-block;
            font-weight: bold;
        }
        .review-btn {
            background-color: #2ecc71;
            color: white;
        }
        .review-btn:hover {
            background-color: #27ae60;
        }
        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: bold;
        }
        .badge-sick {
            background-color: #e74c3c;
            color: white;
        }
        .badge-casual {
            background-color: #3498db;
            color: white;
        }
        .badge-emergency {
            background-color: #e67e22;
            color: white;
        }
        .badge-other {
            background-color: #95a5a6;
            color: white;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Leave Requests (Pending Admin)</h1>
            <a href="adminDashboard.jsp" class="back-btn">← Back to Dashboard</a>
        </div>

        <%
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> col = db.getCollection("leaveRequests");

            ArrayList<Document> list = col.find(new Document("status", "PENDING_ADMIN"))
                                          .into(new ArrayList<>());

            if(list.isEmpty()) {
        %>
            <div class="no-data">
                ✅ No leave requests pending for admin approval!
            </div>
        <%
            } else {
        %>
            <div class="request-count">
                📊 Total Pending Requests: <strong><%= list.size() %></strong>
            </div>
            
            <table>
                <thead>
                    <tr>
                        <th>Sr. No.</th>
                        <th>Leave ID</th>
                        <th>Student Name</th>
                        <th>Roll Number</th>
                        <th>Class</th>
                        <th>From Date</th>
                        <th>To Date</th>
                        <th>Leave Type</th>
                        <th>Parent Remark</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        int srNo = 1;
                        for(Document d : list) { 
                            String leaveType = d.getString("leaveType");
                            String badgeClass = "badge-other";
                            if(leaveType != null) {
                                if(leaveType.equalsIgnoreCase("Sick Leave")) badgeClass = "badge-sick";
                                else if(leaveType.equalsIgnoreCase("Casual Leave")) badgeClass = "badge-casual";
                                else if(leaveType.equalsIgnoreCase("Emergency")) badgeClass = "badge-emergency";
                            }
                    %>
                    <tr>
                        <td><%= srNo++ %></td>
                        <td><%= d.getString("leaveId") %></td>
                        <td><%= d.getString("studentName") %></td>
                        <td><%= d.getString("rollNumber") %></td>
                        <td>Class <%= d.getString("className") %>-<%= d.getString("section") %></td>
                        <td><%= d.getString("fromDate") %></td>
                        <td><%= d.getString("toDate") %></td>
                        <td>
                            <span class="badge <%= badgeClass %>"><%= leaveType == null ? "N/A" : leaveType %></span>
                        </td>
                        <td><%= d.getString("parentRemark") == null ? "-" : d.getString("parentRemark") %></td>
                        <td>
                            <a class="action-btn review-btn" href="reviewLeaveAdmin.jsp?leaveId=<%= d.getString("leaveId") %>">👁️ Review</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</body>
</html>
