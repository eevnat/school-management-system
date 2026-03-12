<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document" %>
<%
    // Only parents allowed here
    if(session.getAttribute("userType") == null || !session.getAttribute("userType").equals("parent")) {
        response.sendRedirect("parentLogin.jsp");
        return;
    }
    
    // Use values stored in ParentLoginServlet
    String rollNumber = (String) session.getAttribute("studentRollNumber");
    String studentName = (String) session.getAttribute("studentName");
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Marks - Parent</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 900px;
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
        .student-info {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }
        .marks-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
        }
        .marks-table th {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
            padding: 15px;
            text-align: left;
        }
        .marks-table td {
            padding: 15px;
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
        .pass { color: #27ae60; }
        .fail { color: #e74c3c; }
        .result-section {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .result-card {
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .result-label {
            font-size: 14px;
            opacity: 0.9;
        }
        .result-value {
            font-size: 32px;
            font-weight: bold;
            margin-top: 8px;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        .back-btn {
            display: block;
            width: 220px;
            margin: 0 auto;
            padding: 12px;
            background-color: #95a5a6;
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .back-btn:hover {
            background-color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Student Marks</h1>
        <div class="student-info">
            <strong><%= studentName %></strong> | Roll Number: <%= rollNumber %>
        </div>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> marksCollection = database.getCollection("marks");
                
                // same structure you are already using for students
                Document marks = marksCollection.find(new Document("rollNumber", rollNumber)).first();
                
                if(marks == null) {
        %>
                    <div class="no-data">
                        <h2>📭 Marks Not Added Yet!</h2>
                        <p>Marks for this student have not been uploaded by the admin yet. Please check back later.</p>
                        <a href="parentDashboard.jsp" class="back-btn">← Back to Dashboard</a>
                    </div>
        <%
                } else {
                    int math = marks.getInteger("mathematics");
                    int science = marks.getInteger("science");
                    int english = marks.getInteger("english");
                    int social = marks.getInteger("socialStudies");
                    int hindi = marks.getInteger("hindi");
                    int computer = marks.getInteger("computerScience");
                    int total = marks.getInteger("totalMarks");
                    double percentage = marks.getDouble("percentage");
                    String grade = marks.getString("grade");
        %>
        
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
                    <td class="<%= math >= 40 ? "pass" : "fail" %>">
                        <%= math >= 40 ? "✅ Pass" : "❌ Fail" %>
                    </td>
                </tr>
                <tr>
                    <td>Science</td>
                    <td>100</td>
                    <td><%= science %></td>
                    <td class="<%= science >= 40 ? "pass" : "fail" %>">
                        <%= science >= 40 ? "✅ Pass" : "❌ Fail" %>
                    </td>
                </tr>
                <tr>
                    <td>English</td>
                    <td>100</td>
                    <td><%= english %></td>
                    <td class="<%= english >= 40 ? "pass" : "fail" %>">
                        <%= english >= 40 ? "✅ Pass" : "❌ Fail" %>
                    </td>
                </tr>
                <tr>
                    <td>Social Studies</td>
                    <td>100</td>
                    <td><%= social %></td>
                    <td class="<%= social >= 40 ? "pass" : "fail" %>">
                        <%= social >= 40 ? "✅ Pass" : "❌ Fail" %>
                    </td>
                </tr>
                <tr>
                    <td>Hindi</td>
                    <td>100</td>
                    <td><%= hindi %></td>
                    <td class="<%= hindi >= 40 ? "pass" : "fail" %>">
                        <%= hindi >= 40 ? "✅ Pass" : "❌ Fail" %>
                    </td>
                </tr>
                <tr>
                    <td>Computer Science</td>
                    <td>100</td>
                    <td><%= computer %></td>
                    <td class="<%= computer >= 40 ? "pass" : "fail" %>">
                        <%= computer >= 40 ? "✅ Pass" : "❌ Fail" %>
                    </td>
                </tr>
                <tr class="total-row">
                    <td>TOTAL</td>
                    <td>600</td>
                    <td><%= total %></td>
                    <td></td>
                </tr>
            </tbody>
        </table>
        
        <a href="parentDashboard.jsp" class="back-btn">← Back to Dashboard</a>
        
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</body>
</html>
