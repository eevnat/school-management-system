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
    <title>Add Student</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
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
        h2 {
            color: #667eea;
            margin-top: 30px;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
            font-size: 20px;
        }
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group.full-width {
            grid-column: 1 / -1;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: bold;
            font-size: 14px;
        }
        input, select, textarea {
            width: 100%;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
        }
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        textarea {
            resize: vertical;
            min-height: 80px;
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
        .btn-submit {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-back {
            background-color: #95a5a6;
            color: white;
        }
        .success-msg {
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .error-msg {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .section-icon {
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>➕ Add New Student</h1>
        
        <% 
            String success = request.getParameter("success");
            if(success != null && success.equals("1")) {
        %>
            <div class="success-msg">✅ Student added successfully!</div>
        <% } %>
        
        <% 
            String error = request.getParameter("error");
            if(error != null) {
        %>
            <div class="error-msg">❌ Failed to add student. Please try again!</div>
        <% } %>
        
        <form action="../AddStudentServlet" method="post">
            <!-- Student Information Section -->
            <h2><span class="section-icon">👨‍🎓</span>Student Information</h2>
            <div class="form-grid">
                <div class="form-group">
                    <label>Student ID: *</label>
                    <input type="text" name="studentId" placeholder="e.g., S001" required>
                </div>
                
                <div class="form-group">
                    <label>Roll Number: *</label>
                    <input type="text" name="rollNumber" placeholder="e.g., 2025001" required>
                </div>
                
                <div class="form-group full-width">
                    <label>Full Name: *</label>
                    <input type="text" name="fullName" placeholder="Enter full name" required>
                </div>
                
                <div class="form-group">
                    <label>Email: *</label>
                    <input type="email" name="email" placeholder="student@example.com" required>
                </div>
                
                <div class="form-group">
                    <label>Phone Number: *</label>
                    <input type="tel" name="phoneNumber" placeholder="1234567890" required>
                </div>
                
                <div class="form-group">
                    <label>Class: *</label>
                    <select name="className" required>
                        <option value="">-- Select --</option>
                        <option value="10">Class 10</option>
                        <option value="11">Class 11</option>
                        <option value="12">Class 12</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Section: *</label>
                    <select name="section" required>
                        <option value="">-- Select --</option>
                        <option value="A">Section A</option>
                        <option value="B">Section B</option>
                        <option value="C">Section C</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Date of Birth: *</label>
                    <input type="date" name="dateOfBirth" required>
                </div>
                
                <div class="form-group">
                    <label>Gender: *</label>
                    <select name="gender" required>
                        <option value="">-- Select --</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                
                <div class="form-group full-width">
                    <label>Address: *</label>
                    <textarea name="address" placeholder="Enter address" required></textarea>
                </div>
                
                <div class="form-group">
                    <label>Password: *</label>
                    <input type="password" name="password" placeholder="Password for login" required>
                </div>
                
                <div class="form-group">
                    <label>Confirm Password: *</label>
                    <input type="password" name="confirmPassword" placeholder="Re-enter password" required>
                </div>
            </div>
            
            <!-- Parent Information Section -->
            <h2><span class="section-icon">👪</span>Parent / Guardian Information</h2>
            <div class="form-grid">
                <div class="form-group full-width">
                    <label>Parent Name: *</label>
                    <input type="text" name="parentName" placeholder="Enter parent/guardian name" required>
                </div>
                
                <div class="form-group">
                    <label>Parent Contact: *</label>
                    <input type="tel" name="parentContact" placeholder="Parent phone number" required>
                </div>
                
                <div class="form-group">
                    <label>Parent Email: *</label>
                    <input type="email" name="parentEmail" placeholder="parent@example.com" required>
                </div>
            </div>
            
            <div class="btn-container">
                <button type="submit" class="btn btn-submit">💾 Add Student</button>
                <a href="adminDashboard.jsp" class="btn btn-back">← Back</a>
            </div>
        </form>
    </div>
</body>
</html>
