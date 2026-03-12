<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Report Cards</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1300px;
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
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .back-btn {
            padding: 10px 20px;
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .search-box {
            margin-bottom: 20px;
            text-align: center;
        }
        .search-box input {
            width: 50%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 10px;
            text-align: left;
            font-weight: bold;
            font-size: 13px;
        }
        td {
            padding: 12px 10px;
            border-bottom: 1px solid #ddd;
            font-size: 13px;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 18px;
        }
        .grade-badge {
            padding: 5px 12px;
            border-radius: 5px;
            font-weight: bold;
            display: inline-block;
        }
        .grade-A-plus { background-color: #2ecc71; color: white; }
        .grade-A { background-color: #27ae60; color: white; }
        .grade-B-plus { background-color: #3498db; color: white; }
        .grade-B { background-color: #2980b9; color: white; }
        .grade-C { background-color: #f39c12; color: white; }
        .grade-D { background-color: #e67e22; color: white; }
        .grade-F { background-color: #e74c3c; color: white; }
        .view-btn {
            padding: 6px 15px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .view-btn:hover {
            background-color: #2980b9;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
        .stat-value {
            font-size: 28px;
            font-weight: bold;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 View All Report Cards</h1>
            <a href="adminDashboard.jsp" class="back-btn">← Back to Dashboard</a>
        </div>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> studentsCollection = database.getCollection("students");
                MongoCollection<Document> marksCollection = database.getCollection("marks");
                
                ArrayList<Document> studentsList = studentsCollection.find().into(new ArrayList<>());
                
                // Calculate statistics
                int totalStudents = studentsList.size();
                int studentsWithMarks = 0;
                int passCount = 0;
                double avgPercentage = 0;
                
                for(Document student : studentsList) {
                    String rollNumber = student.getString("rollNumber");
                    Document marks = marksCollection.find(new Document("rollNumber", rollNumber)).first();
                    if(marks != null) {
                        studentsWithMarks++;
                        double percentage = marks.getDouble("percentage");
                        avgPercentage += percentage;
                        if(percentage >= 40) passCount++;
                    }
                }
                
                if(studentsWithMarks > 0) {
                    avgPercentage = avgPercentage / studentsWithMarks;
                }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Students</div>
                <div class="stat-value"><%= totalStudents %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Reports Generated</div>
                <div class="stat-value"><%= studentsWithMarks %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Pass Count</div>
                <div class="stat-value"><%= passCount %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Avg Percentage</div>
                <div class="stat-value"><%= String.format("%.1f", avgPercentage) %>%</div>
            </div>
        </div>
        
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="🔍 Search by name, roll number, class..." onkeyup="searchTable()">
        </div>
        
        <%
                if(studentsList.isEmpty()) {
        %>
                    <div class="no-data">
                        📭 No students found! Add students first.
                    </div>
        <%
                } else {
        %>
                    <table id="reportTable">
                        <thead>
                            <tr>
                                <th>Roll No.</th>
                                <th>Name</th>
                                <th>Class</th>
                                <th>Math</th>
                                <th>Science</th>
                                <th>English</th>
                                <th>Social</th>
                                <th>Hindi</th>
                                <th>Computer</th>
                                <th>Total</th>
                                <th>%</th>
                                <th>Grade</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for(Document student : studentsList) {
                                    String rollNumber = student.getString("rollNumber");
                                    String fullName = student.getString("fullName");
                                    String className = student.getString("className");
                                    String section = student.getString("section");
                                    
                                    Document marks = marksCollection.find(new Document("rollNumber", rollNumber)).first();
                                    
                                    if(marks != null) {
                                        int math = marks.getInteger("mathematics");
                                        int science = marks.getInteger("science");
                                        int english = marks.getInteger("english");
                                        int social = marks.getInteger("socialStudies");
                                        int hindi = marks.getInteger("hindi");
                                        int computer = marks.getInteger("computerScience");
                                        int total = marks.getInteger("totalMarks");
                                        double percentage = marks.getDouble("percentage");
                                        String grade = marks.getString("grade");
                                        String gradeClass = "grade-" + grade.replace("+", "-plus");
                            %>
                            <tr>
                                <td><%= rollNumber %></td>
                                <td><%= fullName %></td>
                                <td>Class <%= className %>-<%= section %></td>
                                <td><%= math %></td>
                                <td><%= science %></td>
                                <td><%= english %></td>
                                <td><%= social %></td>
                                <td><%= hindi %></td>
                                <td><%= computer %></td>
                                <td><strong><%= total %></strong></td>
                                <td><strong><%= String.format("%.2f", percentage) %>%</strong></td>
                                <td><span class="grade-badge <%= gradeClass %>"><%= grade %></span></td>
                                <td>
                                    <a href="viewDetailedReport.jsp?rollNumber=<%= rollNumber %>" class="view-btn">📄 View Report</a>
                                </td>
                            </tr>
                            <%
                                    } else {
                            %>
                            <tr>
                                <td><%= rollNumber %></td>
                                <td><%= fullName %></td>
                                <td>Class <%= className %>-<%= section %></td>
                                <td colspan="10" style="text-align: center; color: #999;">
                                    <em>Marks not added yet</em>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error loading report cards: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
    
    <script>
        function searchTable() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("reportTable");
            var tr = table.getElementsByTagName("tr");
            
            for (var i = 1; i < tr.length; i++) {
                var td = tr[i].getElementsByTagName("td");
                var found = false;
                
                for (var j = 0; j < td.length; j++) {
                    if (td[j]) {
                        var txtValue = td[j].textContent || td[j].innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found) {
                    tr[i].style.display = "";
                } else {
                    tr[i].style.display = "none";
                }
            }
        }
    </script>
</body>
</html>
