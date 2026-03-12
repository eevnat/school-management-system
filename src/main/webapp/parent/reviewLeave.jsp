<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection" %>
<%@ page import="com.mongodb.client.MongoDatabase" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>

<%
    // ✅ Correct parent session check (matches your parentDashboard.jsp)
    if(session.getAttribute("userType") == null || !session.getAttribute("userType").equals("parent")) {
        response.sendRedirect("parentLogin.jsp");
        return;
    }

    // ✅ Correct student roll number session key
    String studentRollNumber = (String) session.getAttribute("studentRollNumber");
    if(studentRollNumber == null) {
        out.println("❌ Student Roll Number not found in session. Please login again.");
        return;
    }

    // Get leaveId from URL
    String leaveId = request.getParameter("leaveId");
    if(leaveId == null || leaveId.trim().isEmpty()) {
        response.sendRedirect("pendingLeaves.jsp");
        return;
    }

    // Fetch leave request from MongoDB
    MongoDatabase db = MongoDBUtil.getDatabase();
    MongoCollection<Document> col = db.getCollection("leaveRequests");

    // ✅ Extra security: parent can only view their child’s leave
    Document leave = col.find(new Document("leaveId", leaveId).append("rollNumber", studentRollNumber)).first();
    if(leave == null) {
        out.println("❌ Leave not found or not authorized.");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Review Leave (Parent)</title>
    <style>
        body { font-family: Arial; background: #f4f4f4; padding: 20px; }
        .box { max-width: 800px; margin: auto; background: white; padding: 25px; border-radius: 10px; }
        textarea { width: 100%; padding: 10px; border-radius: 6px; border: 1px solid #ccc; }
        .btn { padding: 10px 16px; border: none; color: white; border-radius: 6px; cursor: pointer; font-weight: bold; }
        .approve { background: #27ae60; }
        .reject { background: #e74c3c; }
        .back { display:inline-block; margin-top: 14px; text-decoration:none; color:#667eea; font-weight:bold; }
        .info p { margin: 7px 0; color:#333; }
        .badge { display:inline-block; padding: 4px 10px; border-radius: 12px; background:#eee; font-weight:bold; }
    </style>
</head>

<body>
<div class="box">
    <h2>Parent Authorization</h2>

    <div class="info">
        <p><b>Leave ID:</b> <%= leave.getString("leaveId") %></p>
        <p><b>Student:</b> <%= leave.getString("studentName") %> (Roll: <%= leave.getString("rollNumber") %>)</p>
        <p><b>Class:</b> <%= leave.getString("className") %> - <%= leave.getString("section") %></p>
        <p><b>Dates:</b> <%= leave.getString("fromDate") %> to <%= leave.getString("toDate") %></p>
        <p><b>Type:</b> <%= leave.getString("leaveType") %></p>
        <p><b>Reason:</b> <%= leave.getString("reason") %></p>
        <p><b>Status:</b> <span class="badge"><%= leave.getString("status") %></span></p>
    </div>

    <hr style="margin: 15px 0;">

    <form action="<%=request.getContextPath()%>/ParentLeaveActionServlet" method="post">
        <input type="hidden" name="leaveId" value="<%= leave.getString("leaveId") %>">

        <label><b>Parent Remark / Digital Signature *</b></label><br><br>
        <textarea name="parentRemark" rows="4" required
                  placeholder="e.g., Approved by Parent - Sanjay Patil"></textarea>
        <br><br>

        <button class="btn approve" type="submit" name="action" value="approve">Approve</button>
        <button class="btn reject" type="submit" name="action" value="reject">Reject</button>
    </form>

    <a class="back" href="pendingLeaves.jsp">← Back to Pending Leaves</a>
</div>
</body>
</html>
