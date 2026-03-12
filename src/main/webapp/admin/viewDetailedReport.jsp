<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
    
    String rollNumber = request.getParameter("rollNumber");
    if(rollNumber == null || rollNumber.isEmpty()) {
        response.sendRedirect("viewReportCards.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Detailed Report Card</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .report-container {
            max-width: 900px;
            margin: 0 auto;
            background-color: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        .report-header {
            text-align: center;
            border-bottom: 3px solid #667eea;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .school-name {
            font-size: 28px;
            font-weight: bold;
            color: #333;
            margin: 0;
        }
        .report-title {
            font-size: 20px;
            color: #667eea;
            margin: 10px 0 0 0;
        }
        .student-info {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin-bottom: 30px;
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
        }
        .info-item {
            display: flex;
        }
        .info-label {
            font-weight: bold;
            color: #555;
            width: 140px;
        }
        .info-value {
            color: #333;
        }
        .marks-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        .marks-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
        }
        .marks-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        .marks-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        .total-row {
            background-color: #e3f2fd !important;
            font-weight: bold;
            font-size: 16px;
        }
        .result-section {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .result-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .result-label {
            font-size: 14px;
            opacity: 0.9;
            margin-bottom: 8px;
        }
        .result-value {
            font-size: 32px;
            font-weight: bold;
        }
        .remarks {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid #667eea;
        }
        .remarks h3 {
            margin: 0 0 10px 0;
            color: #333;
        }
        .btn-container {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
        }
        .btn-print {
            background-color: #27ae60;
            color: white;
        }
        .btn-back {
            background-color: #95a5a6;
            color: white;
        }
        @media print {
            body {
                background: white;
                padding: 0;
            }
            .btn-container {
                display: none;
            }
            .report-container {
                box-shadow: none;
            }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> studentsCollection = database.getCollection("students");
                MongoCollection<Document> marksCollection = database.getCollection("marks");
                
                Document student = studentsCollection.find(new Document("rollNumber", rollNumber)).first();
                Document marks = marksCollection.find(new Document("rollNumber", rollNumber)).first();
                
                if(student == null) {
        %>
                    <div style="text-align: center; padding: 40px;">
                        <h2>❌ Student not found!</h2>
                        <a href="viewReportCards.jsp" class="btn btn-back">← Back to Reports</a>
                    </div>
        <%
                    return;
                }
                
                if(marks == null) {
        %>
                    <div style="text-align: center; padding: 40px;">
                        <h2>📝 Marks not added yet for this student!</h2>
                        <a href="viewReportCards.jsp" class="btn btn-back">← Back to Reports</a>
                    </div>
        <%
                    return;
                }
                
                // Get student details
                String studentName = student.getString("fullName");
                String studentId = student.getString("studentId");
                String className = student.getString("className");
                String section = student.getString("section");
                String email = student.getString("email");
                String phone = student.getString("phoneNumber");
                
                // Get marks
                int math = marks.getInteger("mathematics");
                int science = marks.getInteger("science");
                int english = marks.getInteger("english");
                int social = marks.getInteger("socialStudies");
                int hindi = marks.getInteger("hindi");
                int computer = marks.getInteger("computerScience");
                int total = marks.getInteger("totalMarks");
                double percentage = marks.getDouble("percentage");
                String grade = marks.getString("grade");
                
                String result = percentage >= 40 ? "PASS" : "FAIL";
        %>
        
        <div class="report-header">
            <h1 class="school-name">🎓 Wilfred High School</h1>
            <p class="report-title">STUDENT REPORT CARD - 2025</p>
        </div>
        
        <div class="student-info">
            <div class="info-item">
                <span class="info-label">Student Name:</span>
                <span class="info-value"><%= studentName %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Roll Number:</span>
                <span class="info-value"><%= rollNumber %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Student ID:</span>
                <span class="info-value"><%= studentId %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Class:</span>
                <span class="info-value">Class <%= className %> - Section <%= section %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Email:</span>
                <span class="info-value"><%= email %></span>
            </div>
            <div class="info-item">
                <span class="info-label">Phone:</span>
                <span class="info-value"><%= phone %></span>
            </div>
        </div>
        
        <table class="marks-table">
            <thead>
                <tr>
                    <th>Subject</th>
                    <th>Maximum Marks</th>
                    <th>Marks Obtained</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>Mathematics</td>
                    <td>100</td>
                    <td><%= math %></td>
                    <td><%= math >= 40 ? "✅ Pass" : "❌ Fail" %></td>
                </tr>
                <tr>
                    <td>Science</td>
                    <td>100</td>
                    <td><%= science %></td>
                    <td><%= science >= 40 ? "✅ Pass" : "❌ Fail" %></td>
                </tr>
                <tr>
                    <td>English</td>
                    <td>100</td>
                    <td><%= english %></td>
                    <td><%= english >= 40 ? "✅ Pass" : "❌ Fail" %></td>
                </tr>
                <tr>
                    <td>Social Studies</td>
                    <td>100</td>
                    <td><%= social %></td>
                    <td><%= social >= 40 ? "✅ Pass" : "❌ Fail" %></td>
                </tr>
                <tr>
                    <td>Hindi</td>
                    <td>100</td>
                    <td><%= hindi %></td>
                    <td><%= hindi >= 40 ? "✅ Pass" : "❌ Fail" %></td>
                </tr>
                <tr>
                    <td>Computer Science</td>
                    <td>100</td>
                    <td><%= computer %></td>
                    <td><%= computer >= 40 ? "✅ Pass" : "❌ Fail" %></td>
                </tr>
                <tr class="total-row">
                    <td>TOTAL</td>
                    <td>600</td>
                    <td><%= total %></td>
                    <td></td>
                </tr>
            </tbody>
        </table>
        
        <div class="result-section">
            <div class="result-card">
                <div class="result-label">Total Marks</div>
                <div class="result-value"><%= total %>/600</div>
            </div>
            <div class="result-card">
                <div class="result-label">Percentage</div>
                <div class="result-value"><%= String.format("%.2f", percentage) %>%</div>
            </div>
            <div class="result-card">
                <div class="result-label">Grade</div>
                <div class="result-value"><%= grade %></div>
            </div>
        </div>
        
        <div class="remarks">
            <h3>📝 Remarks</h3>
            <p><strong>Result:</strong> <%= result %></p>
            <p><strong>Performance:</strong> 
                <% if(percentage >= 90) { %>
                    Outstanding performance! Keep up the excellent work.
                <% } else if(percentage >= 75) { %>
                    Very good performance! Continue your hard work.
                <% } else if(percentage >= 60) { %>
                    Good performance. Keep improving.
                <% } else if(percentage >= 40) { %>
                    Satisfactory performance. Needs improvement.
                <% } else { %>
                    Needs significant improvement. Please work harder.
                <% } %>
            </p>
        </div>
        
        <div class="btn-container">
            <button onclick="window.print()" class="btn btn-print">🖨️ Print Report</button>
            <a href="viewReportCards.jsp" class="btn btn-back">← Back to All Reports</a>
        </div>
        
        <%
            } catch(Exception e) {
                out.println("<div style='text-align: center; padding: 40px;'>");
                out.println("<h2>❌ Error loading report: " + e.getMessage() + "</h2>");
                out.println("<a href='viewReportCards.jsp' class='btn btn-back'>← Back</a>");
                out.println("</div>");
                e.printStackTrace();
            }
        %>
    </div>
</body>
</html>
