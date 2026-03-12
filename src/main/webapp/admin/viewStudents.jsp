<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
    
    String adminName = (String) session.getAttribute("adminName");
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Students</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
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
        .back-btn:hover {
            background-color: #7f8c8d;
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
        .search-box input:focus {
            outline: none;
            border-color: #667eea;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
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
        .student-count {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 16px;
        }
        .action-btn {
            padding: 5px 12px;
            margin: 0 3px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 12px;
            text-decoration: none;
            display: inline-block;
        }
        
        .delete-btn {
            background-color: #e74c3c;
            color: white;
        }
        .delete-btn:hover {
            background-color: #c0392b;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👥 View All Students</h1>
            <a href="adminDashboard.jsp" class="back-btn">← Back to Dashboard</a>
        </div>
        
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="🔍 Search by name, roll number, class..." onkeyup="searchTable()">
        </div>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> studentsCollection = database.getCollection("students");
                
                ArrayList<Document> studentsList = studentsCollection.find().into(new ArrayList<>());
                
                if(studentsList.isEmpty()) {
        %>
                    <div class="no-data">
                        📭 No students found! Click "Add Student" to register students.
                    </div>
        <%
                } else {
        %>
                    <div class="student-count">
                        📊 Total Students: <strong><%= studentsList.size() %></strong>
                    </div>
                    
                    <table id="studentsTable">
                        <thead>
                            <tr>
                                <th>Sr. No.</th>
                                <th>Student ID</th>
                                <th>Roll Number</th>
                                <th>Full Name</th>
                                <th>Class</th>
                                <th>Section</th>
                                <th>Email</th>
                                <th>Phone</th>
                                
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int srNo = 1;
                                for(Document student : studentsList) {
                                    String studentId = student.getString("studentId");
                            %>
                            <tr>
                                <td><%= srNo++ %></td>
                                <td><%= studentId %></td>
                                <td><%= student.getString("rollNumber") %></td>
                                <td><%= student.getString("fullName") %></td>
                                <td>Class <%= student.getString("className") %></td>
                                <td><%= student.getString("section") %></td>
                                <td><%= student.getString("email") %></td>
                                <td><%= student.getString("phoneNumber") %></td>
                                
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error loading students: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
    
    <script>
        function searchTable() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("studentsTable");
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
        
        function confirmDelete(studentId, studentName) {
            if(confirm("Are you sure you want to delete student: " + studentName + "?\n\nThis action cannot be undone!")) {
                window.location.href = "../DeleteStudentServlet?studentId=" + studentId;
            }
        }
    </script>
</body>
</html>
