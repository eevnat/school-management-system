<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.util.*" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    
    String studentId = (String) session.getAttribute("studentId");
    String rollNumber = (String) session.getAttribute("rollNumber");
    String studentClass = (String) session.getAttribute("studentClass");
    String studentSection = (String) session.getAttribute("studentSection");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Attendance - Student Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
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
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
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
        
        .content {
            padding: 40px;
        }
        
        .month-selector {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .month-selector input {
            padding: 10px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            flex: 1;
        }
        
        .month-selector button {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            padding: 10px 25px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: bold;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            padding: 20px;
            border-radius: 15px;
            color: white;
            text-align: center;
        }
        
        .stat-card.present {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
        }
        
        .stat-card.absent {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        
        .stat-card.late {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .stat-card.percentage {
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
        }
        
        .stat-card h3 {
            font-size: 36px;
            margin-bottom: 5px;
        }
        
        .stat-card p {
            opacity: 0.9;
            font-size: 14px;
        }
        
        .attendance-table {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: 600;
        }
        
        tbody tr {
            border-bottom: 1px solid #f0f0f0;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        td {
            padding: 15px;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .status-badge.present {
            background: #d1fae5;
            color: #065f46;
        }
        
        .status-badge.absent {
            background: #fee2e2;
            color: #991b1b;
        }
        
        .status-badge.late {
            background: #fef3c7;
            color: #78350f;
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
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-calendar-check"></i> My Attendance Record</h1>
        <a href="studentDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <form method="GET" class="month-selector">
            <input type="month" name="month" value="<%= request.getParameter("month") != null ? request.getParameter("month") : YearMonth.now().toString() %>" required>
            <button type="submit">
                <i class="fas fa-search"></i> View Attendance
            </button>
        </form>
        
        <%
            String month = request.getParameter("month");
            if (month != null) {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> attendanceCollection = database.getCollection("attendance");
                
                int presentCount = 0;
                int absentCount = 0;
                int lateCount = 0;
                
                List<Document> attendanceRecords = new ArrayList<>();
                
                for (Document attendance : attendanceCollection.find(
                        new Document("studentId", studentId)
                            .append("date", new Document("$regex", "^" + month))
                ).sort(new Document("date", -1))) {
                    
                    attendanceRecords.add(attendance);
                    String status = attendance.getString("status");
                    if ("PRESENT".equals(status)) presentCount++;
                    else if ("ABSENT".equals(status)) absentCount++;
                    else if ("LATE".equals(status)) lateCount++;
                }
                
                int totalMarked = presentCount + absentCount + lateCount;
                double percentage = totalMarked > 0 ? ((double)(presentCount + lateCount) / totalMarked) * 100 : 0;
        %>
        
        <div class="stats-grid">
            <div class="stat-card present">
                <h3><%= presentCount %></h3>
                <p>Days Present</p>
            </div>
            <div class="stat-card absent">
                <h3><%= absentCount %></h3>
                <p>Days Absent</p>
            </div>
            <div class="stat-card late">
                <h3><%= lateCount %></h3>
                <p>Days Late</p>
            </div>
            <div class="stat-card percentage">
                <h3><%= String.format("%.1f", percentage) %>%</h3>
                <p>Attendance %</p>
            </div>
        </div>
        
        <% if (attendanceRecords.size() > 0) { %>
        <div class="attendance-table">
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Marked By</th>
                        <th>Remarks</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        for (Document record : attendanceRecords) {
                            String status = record.getString("status");
                            String statusClass = status.toLowerCase();
                    %>
                    <tr>
                        <td><%= record.getString("date") %></td>
                        <td>
                            <span class="status-badge <%= statusClass %>">
                                <%= status %>
                            </span>
                        </td>
                        <td><%= record.getString("markedBy") != null ? record.getString("markedBy") : "Admin" %></td>
                        <td><%= record.getString("remarks") != null ? record.getString("remarks") : "-" %></td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        <% } else { %>
        <div class="no-data">
            <i class="fas fa-calendar-times"></i>
            <h3>No attendance records found</h3>
            <p>No attendance data for selected month</p>
        </div>
        <% } %>
        
        <% } else { %>
        <div class="no-data">
            <i class="fas fa-calendar-alt"></i>
            <h3>Select a month to view attendance</h3>
            <p>Choose a month from the selector above</p>
        </div>
        <% } %>
    </div>
</div>

</body>
</html>
