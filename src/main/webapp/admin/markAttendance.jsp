<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.time.LocalDate" %>
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
    <title>Mark Attendance - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        
        .back-btn:hover {
            background: rgba(255,255,255,0.3);
            transform: translateY(-2px);
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
            transition: all 0.3s;
        }
        
        .form-group select:focus,
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .load-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            font-size: 16px;
            font-weight: 600;
            transition: all 0.3s;
            align-self: flex-end;
        }
        
        .load-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        
        .status-buttons {
            display: flex;
            gap: 10px;
        }
        
        .status-btn {
            padding: 8px 16px;
            border: 2px solid #e0e0e0;
            background: white;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 600;
            font-size: 13px;
        }
        
        .status-btn.active.present {
            background: #10b981;
            color: white;
            border-color: #10b981;
        }
        
        .status-btn.active.absent {
            background: #ef4444;
            color: white;
            border-color: #ef4444;
        }
        
        .status-btn.active.late {
            background: #f59e0b;
            color: white;
            border-color: #f59e0b;
        }
        
        .submit-section {
            margin-top: 30px;
            text-align: center;
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            padding: 15px 50px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 18px;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(16, 185, 129, 0.4);
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .alert.success {
            background: #d1fae5;
            color: #065f46;
            border-left: 4px solid #10b981;
        }
        
        .alert.error {
            background: #fee2e2;
            color: #991b1b;
            border-left: 4px solid #ef4444;
        }
        
        .quick-actions {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .quick-btn {
            padding: 10px 20px;
            background: #f3f4f6;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .quick-btn:hover {
            background: #e5e7eb;
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
        <h1><i class="fas fa-clipboard-check"></i> Mark Daily Attendance</h1>
        <a href="adminDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>
    
    <div class="content">
        <% 
            String successMsg = (String) session.getAttribute("successMessage");
            String errorMsg = (String) session.getAttribute("errorMessage");
            if (successMsg != null) {
                out.println("<div class='alert success'><i class='fas fa-check-circle'></i> " + successMsg + "</div>");
                session.removeAttribute("successMessage");
            }
            if (errorMsg != null) {
                out.println("<div class='alert error'><i class='fas fa-exclamation-circle'></i> " + errorMsg + "</div>");
                session.removeAttribute("errorMessage");
            }
        %>
        
        <form method="GET" id="filterForm">
            <div class="filter-section">
                <div class="form-group">
                    <label>Date</label>
                    <input type="date" name="attendanceDate" value="<%= request.getParameter("attendanceDate") != null ? request.getParameter("attendanceDate") : LocalDate.now() %>" required>
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
                    <button type="submit" class="load-btn">
                        <i class="fas fa-search"></i> Load Students
                    </button>
                </div>
            </div>
        </form>
        
        <%
            String className = request.getParameter("className");
            String section = request.getParameter("section");
            String attendanceDate = request.getParameter("attendanceDate");
            
            if (className != null && section != null && attendanceDate != null) {
        %>
        
        <div class="quick-actions">
            <button class="quick-btn" onclick="markAll('PRESENT')">
                <i class="fas fa-check-double"></i> Mark All Present
            </button>
            <button class="quick-btn" onclick="markAll('ABSENT')">
                <i class="fas fa-times"></i> Mark All Absent
            </button>
        </div>
        
        <form method="POST" action="../MarkAttendanceServlet" id="attendanceForm">
            <input type="hidden" name="attendanceDate" value="<%= attendanceDate %>">
            <input type="hidden" name="className" value="<%= className %>">
            <input type="hidden" name="section" value="<%= section %>">
            
            <div class="attendance-table">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Student ID</th>
                            <th>Name</th>
                            <th>Roll No</th>
                            <th style="text-align: center;">Attendance Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            MongoDatabase database = MongoDBUtil.getDatabase();
                            MongoCollection<Document> collection = database.getCollection("students");
                            
                            Document query = new Document("className", className).append("section", section);
                            int count = 0;
                            
                            for (Document student : collection.find(query).sort(new Document("rollNumber", 1))) {
                                count++;
                                String studentId = student.getString("studentId");
                                String studentName = student.getString("fullName");
                                String rollNo = student.getString("rollNumber");
                        %>
                        <tr>
                            <td><%= count %></td>
                            <td><%= studentId %></td>
                            <td><strong><%= studentName %></strong></td>
                            <td><%= rollNo %></td>
                            <td style="text-align: center;">
                                <input type="hidden" name="studentIds[]" value="<%= studentId %>">
                                <div class="status-buttons">
                                    <button type="button" class="status-btn present" onclick="setStatus(this, '<%= studentId %>', 'PRESENT')">
                                        <i class="fas fa-check"></i> Present
                                    </button>
                                    <button type="button" class="status-btn absent" onclick="setStatus(this, '<%= studentId %>', 'ABSENT')">
                                        <i class="fas fa-times"></i> Absent
                                    </button>
                                    <button type="button" class="status-btn late" onclick="setStatus(this, '<%= studentId %>', 'LATE')">
                                        <i class="fas fa-clock"></i> Late
                                    </button>
                                </div>
                                <input type="hidden" name="statuses[]" id="status-<%= studentId %>" value="PRESENT">
                            </td>
                        </tr>
                        <%
                            }
                            
                            if (count == 0) {
                        %>
                        <tr>
                            <td colspan="5">
                                <div class="no-data">
                                    <i class="fas fa-user-slash"></i>
                                    <h3>No students found in this class</h3>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <% if (count > 0) { %>
            <div class="submit-section">
                <button type="submit" class="submit-btn">
                    <i class="fas fa-save"></i> Submit Attendance
                </button>
            </div>
            <% } %>
        </form>
        
        <% } else { %>
        <div class="no-data">
            <i class="fas fa-filter"></i>
            <h3>Please select date, class, and section to load students</h3>
        </div>
        <% } %>
    </div>
</div>

<script>
    function setStatus(button, studentId, status) {
        const row = button.closest('tr');
        const buttons = row.querySelectorAll('.status-btn');
        
        buttons.forEach(btn => btn.classList.remove('active'));
        button.classList.add('active');
        
        document.getElementById('status-' + studentId).value = status;
    }
    
    function markAll(status) {
        const statusInputs = document.querySelectorAll('input[name="statuses[]"]');
        const buttons = document.querySelectorAll('.status-btn');
        
        buttons.forEach(btn => btn.classList.remove('active'));
        
        statusInputs.forEach(input => {
            input.value = status;
            const studentId = input.id.replace('status-', '');
            const row = input.closest('tr');
            const targetBtn = row.querySelector('.status-btn.' + status.toLowerCase());
            if (targetBtn) {
                targetBtn.classList.add('active');
            }
        });
    }
    
    // Set default status to PRESENT for all
    window.onload = function() {
        document.querySelectorAll('.status-btn.present').forEach(btn => {
            btn.classList.add('active');
        });
    };
</script>
</body>
</html>
