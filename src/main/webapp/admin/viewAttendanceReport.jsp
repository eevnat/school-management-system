<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
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
    <title>Attendance Reports - Admin Dashboard</title>
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
            max-width: 1400px;
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
        
        .filter-section {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 30px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        
        .form-group label {
            font-weight: 600;
            color: #333;
            font-size: 14px;
        }
        
        .form-group select,
        .form-group input {
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
        }
        
        .generate-btn {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            align-self: flex-end;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
        }
        
        .stat-card.warning {
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
        }
        
        .stat-card.danger {
            background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);
        }
        
        .stat-card h3 {
            font-size: 32px;
            margin-bottom: 5px;
        }
        
        .stat-card p {
            opacity: 0.9;
        }
        
        .section-title {
            font-size: 20px;
            font-weight: bold;
            color: #333;
            margin: 30px 0 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #4facfe;
        }
        
        .report-table {
            background: white;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 30px;
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
            transition: all 0.3s;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        td {
            padding: 15px;
        }
        
        .percentage {
            font-weight: bold;
            padding: 5px 10px;
            border-radius: 5px;
        }
        
        .percentage.good {
            background: #d1fae5;
            color: #065f46;
        }
        
        .percentage.warning {
            background: #fef3c7;
            color: #78350f;
        }
        
        .percentage.danger {
            background: #fee2e2;
            color: #991b1b;
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
        <h1><i class="fas fa-chart-line"></i> Attendance Reports & Analytics</h1>
        <a href="adminDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <form method="GET">
            <div class="filter-section">
                <div class="form-group">
                    <label>Month</label>
                    <input type="month" name="month" value="<%= request.getParameter("month") != null ? request.getParameter("month") : YearMonth.now().toString() %>" required>
                </div>
                
                <div class="form-group">
                    <label>Class</label>
                    <select name="className" required>
                        <option value="">Select Class</option>
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
                </div>
                
                <div class="form-group">
                    <label>Section</label>
                    <select name="section" required>
                        <option value="">Select Section</option>
                        <option value="A">Section A</option>
                        <option value="B">Section B</option>
                        <option value="C">Section C</option>
                        <option value="D">Section D</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>&nbsp;</label>
                    <button type="submit" class="generate-btn">
                        <i class="fas fa-chart-bar"></i> Generate Report
                    </button>
                </div>
            </div>
        </form>
        
        <%
            String month = request.getParameter("month");
            String className = request.getParameter("className");
            String section = request.getParameter("section");
            
            if (month != null && className != null && section != null) {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> attendanceCollection = database.getCollection("attendance");
                MongoCollection<Document> studentCollection = database.getCollection("students");
                
                // Parse month
                String[] monthParts = month.split("-");
                int year = Integer.parseInt(monthParts[0]);
                int monthNum = Integer.parseInt(monthParts[1]);
                YearMonth yearMonth = YearMonth.of(year, monthNum);
                int daysInMonth = yearMonth.lengthOfMonth();
                
                // Get all students in class
                List<Document> students = studentCollection.find(
                    new Document("className", className).append("section", section)
                ).into(new ArrayList<>());
                
                int totalStudents = students.size();
                int defaulterCount = 0;
                List<Document> defaulters = new ArrayList<>();
                
                // Calculate attendance for each student
                Map<String, Map<String, Integer>> studentAttendance = new HashMap<>();
                
                for (Document student : students) {
                    String studentId = student.getString("studentId");
                    
                    int presentCount = 0;
                    int absentCount = 0;
                    int lateCount = 0;
                    
                    // Count attendance for the month
                    for (Document attendance : attendanceCollection.find(
                            new Document("studentId", studentId)
                                .append("className", className)
                                .append("section", section)
                                .append("date", new Document("$regex", "^" + month))
                    )) {
                        String status = attendance.getString("status");
                        if ("PRESENT".equals(status)) presentCount++;
                        else if ("ABSENT".equals(status)) absentCount++;
                        else if ("LATE".equals(status)) lateCount++;
                    }
                    
                    int totalMarked = presentCount + absentCount + lateCount;
                    double percentage = totalMarked > 0 ? ((double)(presentCount + lateCount) / totalMarked) * 100 : 0;
                    
                    Map<String, Integer> stats = new HashMap<>();
                    stats.put("present", presentCount);
                    stats.put("absent", absentCount);
                    stats.put("late", lateCount);
                    stats.put("percentage", (int)percentage);
                    
                    studentAttendance.put(studentId, stats);
                    
                    // Check if defaulter (<75%)
                    if (percentage < 75 && totalMarked > 0) {
                        defaulterCount++;
                        Document defaulter = new Document(student);
                        defaulter.append("percentage", (int)percentage)
                                .append("presentDays", presentCount)
                                .append("absentDays", absentCount);
                        defaulters.add(defaulter);
                    }
                }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <h3><%= totalStudents %></h3>
                <p>Total Students</p>
            </div>
            <div class="stat-card warning">
                <h3><%= defaulterCount %></h3>
                <p>Defaulters (<75%)</p>
            </div>
            <div class="stat-card danger">
                <h3><%= daysInMonth %></h3>
                <p>Working Days</p>
            </div>
        </div>
        
        <!-- Monthly Attendance Report -->
        <div class="section-title">
            <i class="fas fa-calendar-alt"></i> Monthly Attendance Report - <%= month %>
        </div>
        
        <div class="report-table">
            <table>
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Student ID</th>
                        <th>Name</th>
                        <th>Roll No</th>
                        <th>Present</th>
                        <th>Absent</th>
                        <th>Late</th>
                        <th>Attendance %</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        int rowNum = 0;
                        for (Document student : students) {
                            rowNum++;
                            String studentId = student.getString("studentId");
                            Map<String, Integer> stats = studentAttendance.get(studentId);
                            
                            int present = stats.get("present");
                            int absent = stats.get("absent");
                            int late = stats.get("late");
                            int percentage = stats.get("percentage");
                            
                            String percentageClass = percentage >= 75 ? "good" : (percentage >= 60 ? "warning" : "danger");
                    %>
                    <tr>
                        <td><%= rowNum %></td>
                        <td><%= studentId %></td>
                        <td><strong><%= student.getString("fullName") %></strong></td>
                        <td><%= student.getString("rollNumber") %></td>
                        <td><span style="color: #10b981;"><%= present %></span></td>
                        <td><span style="color: #ef4444;"><%= absent %></span></td>
                        <td><span style="color: #f59e0b;"><%= late %></span></td>
                        <td>
                            <span class="percentage <%= percentageClass %>">
                                <%= percentage %>%
                            </span>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <!-- Defaulters List -->
        <% if (defaulterCount > 0) { %>
        <div class="section-title" style="border-color: #ef4444; color: #ef4444;">
            <i class="fas fa-exclamation-triangle"></i> Defaulters List (Below 75% Attendance)
        </div>
        
        <div class="report-table">
            <table>
                <thead style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%);">
                    <tr>
                        <th>#</th>
                        <th>Student ID</th>
                        <th>Name</th>
                        <th>Parent Contact</th>
                        <th>Present</th>
                        <th>Absent</th>
                        <th>Percentage</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        int defNum = 0;
                        for (Document defaulter : defaulters) {
                            defNum++;
                    %>
                    <tr>
                        <td><%= defNum %></td>
                        <td><%= defaulter.getString("studentId") %></td>
                        <td><strong><%= defaulter.getString("fullName") %></strong></td>
                        <td>
                            <%= defaulter.getString("parentName") %><br>
                            <small><%= defaulter.getString("parentContact") %></small>
                        </td>
                        <td><%= defaulter.getInteger("presentDays") %></td>
                        <td><%= defaulter.getInteger("absentDays") %></td>
                        <td>
                            <span class="percentage danger">
                                <%= defaulter.getInteger("percentage") %>%
                            </span>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </div>
        <% } %>
        
        <% } else { %>
        <div class="no-data">
            <i class="fas fa-chart-bar"></i>
            <h3>Please select month, class, and section to generate report</h3>
        </div>
        <% } %>
    </div>
</div>

</body>
</html>
