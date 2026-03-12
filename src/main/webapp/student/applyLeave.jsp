<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }

    String studentName = (String) session.getAttribute("studentName");
    String rollNumber = (String) session.getAttribute("rollNumber");
    String studentClass = (String) session.getAttribute("studentClass");
    String studentSection = (String) session.getAttribute("studentSection");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Apply Leave</title>
    <style>
        body { font-family: Arial; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); margin:0; padding:20px; min-height:100vh; }
        .container { max-width: 900px; margin: 0 auto; background:#fff; padding:30px; border-radius:15px; box-shadow: 0 10px 30px rgba(0,0,0,0.25); }
        h1 { text-align:center; color:#333; margin-bottom: 8px; }
        .sub { text-align:center; color:#666; margin-bottom: 25px; }
        .row { display:grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        label { display:block; margin: 10px 0 6px; font-weight: bold; color:#555; }
        input, select, textarea { width:100%; padding: 12px; border: 2px solid #ddd; border-radius: 6px; box-sizing: border-box; }
        textarea { min-height: 110px; resize: vertical; }
        .btns { display:flex; gap:12px; justify-content:center; margin-top: 20px; }
        .btn { padding: 12px 26px; border-radius:6px; text-decoration:none; font-weight:bold; border:none; cursor:pointer; }
        .btn-primary { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); color:white; }
        .btn-back { background:#95a5a6; color:white; }
        .msg-ok { background:#d4edda; color:#155724; padding:10px; border-radius:6px; margin-bottom:12px; text-align:center; }
        .msg-err { background:#f8d7da; color:#721c24; padding:10px; border-radius:6px; margin-bottom:12px; text-align:center; }
    </style>
</head>
<body>
<div class="container">
    <h1>📝 Apply Leave</h1>
    <div class="sub"><strong><%= studentName %></strong> | Roll: <%= rollNumber %> | Class <%= studentClass %>-<%= studentSection %></div>

    <%
        String success = request.getParameter("success");
        String error = request.getParameter("error");
        if("1".equals(success)) {
    %>
        <div class="msg-ok">✅ Leave request submitted. Waiting for Parent approval.</div>
    <% } else if(error != null) { %>
        <div class="msg-err">❌ Something went wrong. Try again.</div>
    <% } %>

    <form action="<%=request.getContextPath()%>/ApplyLeaveServlet" method="post" onsubmit="return validateDates()">
        <div class="row">
            <div>
                <label>From Date *</label>
                <input type="date" name="fromDate" required>
            </div>
            <div>
                <label>To Date *</label>
                <input type="date" name="toDate" required>
            </div>
        </div>

        <label>Leave Type *</label>
        <select name="leaveType" required>
            <option value="">-- Select --</option>
            <option value="Medical">Medical</option>
            <option value="Personal">Personal</option>
            <option value="Family">Family</option>
            <option value="Other">Other</option>
        </select>

        <label>Reason *</label>
        <textarea name="reason" required placeholder="Write your leave reason..."></textarea>

        <div class="btns">
            <button class="btn btn-primary" type="submit">Submit Leave</button>
            <a class="btn btn-back" href="studentDashboard.jsp">← Back</a>
            <a class="btn btn-back" href="myLeaves.jsp">My Leaves</a>
        </div>
    </form>
</div>

<script>
function validateDates(){
    const from = document.getElementsByName("fromDate")[0].value;
    const to = document.getElementsByName("toDate")[0].value;
    if(from && to && from > to){
        alert("From Date cannot be after To Date.");
        return false;
    }
    return true;
}
</script>
</body>
</html>
