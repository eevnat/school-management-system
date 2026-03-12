<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String leaveId = request.getParameter("leaveId");
    if(leaveId == null) { response.sendRedirect("viewLeaveRequests.jsp"); return; }

    MongoDatabase db = MongoDBUtil.getDatabase();
    MongoCollection<Document> col = db.getCollection("leaveRequests");

    Document leave = col.find(new Document("leaveId", leaveId)).first();
    if(leave == null) { out.println("Leave not found."); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Review Leave (Admin)</title>
    <style>
        body { font-family: Arial; background: #f4f4f4; padding: 20px; }
        .box { max-width: 800px; margin: auto; background: white; padding: 25px; border-radius: 10px; }
        textarea { width: 100%; padding: 10px; }
        .btn { padding: 10px 16px; border: none; color: white; border-radius: 6px; cursor: pointer; }
        .approve { background: #27ae60; }
        .reject { background: #e74c3c; }
    </style>
</head>
<body>
<div class="box">
    <h2>Admin Final Decision</h2>

    <p><b>Leave ID:</b> <%= leave.getString("leaveId") %></p>
    <p><b>Student:</b> <%= leave.getString("studentName") %> (Roll: <%= leave.getString("rollNumber") %>)</p>
    <p><b>Class:</b> <%= leave.getString("className") %>-<%= leave.getString("section") %></p>
    <p><b>Dates:</b> <%= leave.getString("fromDate") %> to <%= leave.getString("toDate") %></p>
    <p><b>Type:</b> <%= leave.getString("leaveType") %></p>
    <p><b>Reason:</b> <%= leave.getString("reason") %></p>
    <p><b>Parent Remark:</b> <%= leave.getString("parentRemark") == null ? "-" : leave.getString("parentRemark") %></p>
    <p><b>Status:</b> <%= leave.getString("status") %></p>

    <form action="<%=request.getContextPath()%>/AdminLeaveActionServlet" method="post">
        <input type="hidden" name="leaveId" value="<%= leave.getString("leaveId") %>">

        <label>Admin Remark *</label><br>
        <textarea name="adminRemark" rows="4" required placeholder="e.g., Approved. Maintain attendance."></textarea>
        <br><br>

        <button class="btn approve" type="submit" name="action" value="approve">Approve</button>
        <button class="btn reject" type="submit" name="action" value="reject">Reject</button>
    </form>

    <br>
    <a href="viewLeaveRequests.jsp">Back</a>
</div>
</body>
</html>
