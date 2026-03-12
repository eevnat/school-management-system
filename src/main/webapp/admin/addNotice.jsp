<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Notice</title>
    <style>
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg,#667eea,#764ba2); margin:0; padding:20px; }
        .container { max-width:800px; margin:0 auto; background:#fff; padding:30px; border-radius:15px;
                     box-shadow:0 10px 30px rgba(0,0,0,0.3); }
        h1 { text-align:center; margin-bottom:20px; color:#333; }
        .msg { padding:10px 15px; border-radius:8px; margin-bottom:15px; text-align:center; }
        .success { background:#d4edda; color:#155724; }
        .error { background:#f8d7da; color:#721c24; }
        .form-group { margin-bottom:15px; }
        label { display:block; font-weight:bold; margin-bottom:5px; color:#555; }
        input[type=text], select, textarea {
            width:100%; padding:10px; border:2px solid #ddd; border-radius:6px; box-sizing:border-box;
        }
        textarea { min-height:100px; resize:vertical; }
        .btn-row { display:flex; gap:15px; justify-content:center; margin-top:20px; }
        .btn { padding:10px 25px; border:none; border-radius:6px; font-weight:bold; cursor:pointer; }
        .btn-save { background:linear-gradient(135deg,#667eea,#764ba2); color:#fff; }
        .btn-back { background:#95a5a6; color:#fff; text-decoration:none; display:inline-block; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📢 Add Notice</h1>

        <%
            String success = request.getParameter("success");
            String error = request.getParameter("error");
            if("1".equals(success)) {
        %>
            <div class="msg success">✅ Notice added successfully!</div>
        <% } else if("1".equals(error)) { %>
            <div class="msg error">❌ Failed to add notice. Try again.</div>
        <% } %>

        <!-- ✅ Use context path (recommended) -->
        <form action="<%=request.getContextPath()%>/AddNoticeServlet" method="post">

            <div class="form-group">
                <label>Notice ID *</label>
                <input type="text" name="noticeId" placeholder="e.g., N001" required>
            </div>

            <div class="form-group">
                <label>Title *</label>
                <input type="text" name="title" placeholder="Holiday on Friday" required>
            </div>

            <div class="form-group">
                <label>Category *</label>
                <select name="category" required>
                    <option value="">-- Select --</option>
                    <option value="Holiday">Holiday</option>
                    <option value="PT Uniform">PT Uniform</option>
                    <option value="Homework">Homework</option>
                    <option value="Project Submission">Project Submission</option>
                    <option value="Workshop">Workshop</option>
                    <option value="Daily Activity">Daily Activity</option>
                    <option value="Exam">Upcoming Exam</option>
                    <option value="Assignment">Assignment Submission</option>
                    <option value="Other">Other</option>
                </select>
            </div>

            <div class="form-group">
                <label>Audience *</label>
                <!-- ✅ These values match AddNoticeServlet audience checks -->
                <select name="audience" required>
                    <option value="ALL">All</option>
                    <option value="STUDENT">Students</option>
                    <option value="PARENT">Parents</option>
                </select>
            </div>

            <div class="form-group">
                <label>Message *</label>
                <textarea name="message" placeholder="Enter full notice details" required></textarea>
            </div>

            <div class="btn-row">
                <button type="submit" class="btn btn-save">💾 Save Notice</button>
                <a href="adminDashboard.jsp" class="btn btn-back">← Back</a>
            </div>
        </form>
    </div>
</body>
</html>
