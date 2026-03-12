<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
    
    String studentId = request.getParameter("studentId");
    if(studentId == null || studentId.trim().isEmpty()) {
        response.sendRedirect("viewStudents.jsp");
        return;
    }
    
    Document student = null;
    try {
        MongoDatabase database = MongoDBUtil.getDatabase();
        MongoCollection<Document> studentsCollection = database.getCollection("students");
        student = studentsCollection.find(new Document("studentId", studentId)).first();
        
        if(student == null) {
            response.sendRedirect("viewStudents.jsp?error=notfound");
            return;
        }
    } catch(Exception e) {
        e.printStackTrace();
        response.sendRedirect("viewStudents.jsp?error=exception");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Student</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 700px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"],
        input[type="tel"],
        input[type="password"],
        input[type="date"],
        select {
            width: 100%;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        input:focus, select:focus {
            outline: none;
            border-color: #667eea;
        }
        .btn-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
        }
        button {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }
        .update-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .update-btn:hover {
            opacity: 0.9;
        }
        .cancel-btn {
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .cancel-btn:hover {
            background-color: #7f8c8d;
        }
        .readonly {
            background-color: #f0f0f0;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>✏️ Edit Student Details</h1>
        
        <form action="../UpdateStudentServlet" method="post">
            <input type="hidden" name="studentId" value="<%= student.getString("studentId") %>">
            
            <div class="form-group">
                <label>Student ID</label>
                <input type="text" value="<%= student.getString("studentId") %>" class="readonly" readonly>
            </div>
            
            <div class="form-group">
                <label>Roll Number</label>
                <input type="text" name="rollNumber" value="<%= student.getString("rollNumber") %>" required>
            </div>
            
            <div class="form-group">
                <label>Full Name</label>
                <input type="text" name="fullName" value="<%= student.getString("fullName") %>" required>
            </div>
            
            <div class="form-group">
                <label>Class</label>
                <select name="className" required>
                    <option value="">Select Class</option>
                    <% 
                        String currentClass = student.getString("className");
                        for(int i=1; i<=12; i++) {
                            String selected = String.valueOf(i).equals(currentClass) ? "selected" : "";
                    %>
                        <option value="<%= i %>" <%= selected %>><%= i %></option>
                    <% } %>
                </select>
            </div>
            
            <div class="form-group">
                <label>Section</label>
                <select name="section" required>
                    <option value="">Select Section</option>
                    <% 
                        String currentSection = student.getString("section");
                        String[] sections = {"A", "B", "C", "D", "E"};
                        for(String sec : sections) {
                            String selected = sec.equals(currentSection) ? "selected" : "";
                    %>
                        <option value="<%= sec %>" <%= selected %>><%= sec %></option>
                    <% } %>
                </select>
            </div>
            
            <div class="form-group">
                <label>Email</label>
                <input type="email" name="email" value="<%= student.getString("email") %>" required>
            </div>
            
            <div class="form-group">
                <label>Phone Number</label>
                <input type="tel" name="phoneNumber" value="<%= student.getString("phoneNumber") %>" required>
            </div>
            
            <div class="form-group">
                <label>Date of Birth</label>
                <input type="date" name="dateOfBirth" value="<%= student.getString("dateOfBirth") %>" required>
            </div>
            
            <div class="form-group">
                <label>Gender</label>
                <select name="gender" required>
                    <% 
                        String currentGender = student.getString("gender");
                        String[] genders = {"Male", "Female", "Other"};
                        for(String g : genders) {
                            String selected = g.equals(currentGender) ? "selected" : "";
                    %>
                        <option value="<%= g %>" <%= selected %>><%= g %></option>
                    <% } %>
                </select>
            </div>
            
            <div class="form-group">
                <label>Address</label>
                <input type="text" name="address" value="<%= student.getString("address") %>" required>
            </div>
            
            <div class="btn-group">
                <button type="submit" class="update-btn">💾 Update Student</button>
                <a href="viewStudents.jsp" class="cancel-btn">❌ Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>
