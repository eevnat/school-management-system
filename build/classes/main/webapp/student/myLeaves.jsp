<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    String rollNumber = (String) session.getAttribute("rollNumber");
%>
<!DOCTYPE html>
<html>
<head>
    <title>My Leave Requests</title>
    <style>
        body { font-family: Arial; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); margin:0; padding:20px; min-height:100vh; }
        .container { max-width: 1100px; margin: 0 auto; background:#fff; padding:30px; border-radius:15px; box-shadow: 0 10px 30px rgba(0,0,0,0.25); }
        h1 { text-align:center; color:#333; margin-bottom: 20px; }
        table { width:100%; border-collapse: collapse; }
        th { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); color:white; padding:12px; text-align:left; }
        td { padding:12px; border-bottom:1px solid #ddd; }
        .badge { padding:4px 10px; border-radius: 10px; font-size: 12px; font-weight:bold; display:inline-block; }
        .p1 { background:#fff3cd; color:#856404; } /* pending parent */
        .p2 { background:#d1ecf1; color:#0c5460; } /* pending admin */
        .ok { background:#d4edda; color:#155724; } /* approved */
        .rej { background:#f8d7da; color:#721c24; } /* rejected */
        .top { display:flex; justify-content: space-between; align-items:center; margin-bottom: 15px; }
        .btn { padding:10px 18px; border-radius:6px; text-decoration:none; font-weight:bold; background:#95a5a6; color:white; }
        .btn-primary { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); }
        .nodata { text-align:center; color:#777; padding:40px 0; }
    </style>
</head>
<body>
<div class="container">
    <div class="top">
        <a class="btn" href="studentDashboard.jsp">← Back</a>
        <a class="btn btn-primary" href="applyLeave.jsp">+ Apply Leave</a>
    </div>

    <h1>📌 My Leave Requests</h1>

    <%
        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> col = db.getCollection("leaveRequests");

            ArrayList<Document> list = col.find(new Document("rollNumber", rollNumber))
                    .sort(new Document("appliedAt", -1))
                    .into(new ArrayList<>());

            if(list.isEmpty()) {
    %>
        <div class="nodata">No leave requests yet.</div>
    <%
            } else {
    %>
        <table>
            <thead>
                <tr>
                    <th>Leave ID</th>
                    <th>From</th>
                    <th>To</th>
                    <th>Type</th>
                    <th>Status</th>
                    <th>Parent Remark</th>
                    <th>Admin Remark</th>
                </tr>
            </thead>
            <tbody>
            <%
                for(Document d : list){
                    String status = d.getString("status");
                    String badgeClass = "p1";
                    if("PENDING_ADMIN".equals(status)) badgeClass = "p2";
                    else if("APPROVED".equals(status)) badgeClass = "ok";
                    else if(status != null && status.startsWith("REJECTED")) badgeClass = "rej";
            %>
                <tr>
                    <td><%= d.getString("leaveId") %></td>
                    <td><%= d.getString("fromDate") %></td>
                    <td><%= d.getString("toDate") %></td>
                    <td><%= d.getString("leaveType") %></td>
                    <td><span class="badge <%= badgeClass %>"><%= status %></span></td>
                    <td><%= d.getString("parentRemark") == null ? "-" : d.getString("parentRemark") %></td>
                    <td><%= d.getString("adminRemark") == null ? "-" : d.getString("adminRemark") %></td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    <%
            }
        } catch(Exception e) {
            out.println("<div class='nodata'>❌ Error: " + e.getMessage() + "</div>");
            e.printStackTrace();
        }
    %>
</div>
</body>
</html>
