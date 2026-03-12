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
    <title>Add Marks</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
            margin-bottom: 30px;
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
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
        }
        select, input[type="number"] {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
        }
        select:focus, input:focus {
            outline: none;
            border-color: #667eea;
        }
        .marks-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
            margin-top: 20px;
        }
        .subject-field {
            background-color: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
        }
        .subject-field label {
            font-size: 14px;
            color: #333;
        }
        .total-section {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-top: 30px;
            text-align: center;
        }
        .total-section h3 {
            margin: 0 0 15px 0;
        }
        .total-display {
            display: flex;
            justify-content: space-around;
            margin-top: 15px;
        }
        .total-item {
            text-align: center;
        }
        .total-item .label {
            font-size: 12px;
            opacity: 0.9;
        }
        .total-item .value {
            font-size: 24px;
            font-weight: bold;
            margin-top: 5px;
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
        .info-box {
            background-color: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #2196F3;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📝 Add Student Marks</h1>
        
        <% 
            String success = request.getParameter("success");
            if(success != null && success.equals("1")) {
        %>
            <div class="success-msg">✅ Marks added successfully!</div>
        <% } %>
        
        <% 
            String error = request.getParameter("error");
            if(error != null) {
        %>
            <div class="error-msg">❌ Failed to add marks. Please try again!</div>
        <% } %>
        
        <div class="info-box">
            ℹ️ <strong>Note:</strong> Enter marks out of 100 for each subject. Total and percentage will be calculated automatically.
        </div>
        
        <form action="../AddMarksServlet" method="post" onsubmit="return validateMarks()">
            <div class="form-group">
                <label>Select Student: *</label>
                <select name="rollNumber" required>
                    <option value="">-- Select Student --</option>
                    <%
                        try {
                            MongoDatabase database = MongoDBUtil.getDatabase();
                            MongoCollection<Document> studentsCollection = database.getCollection("students");
                            ArrayList<Document> studentsList = studentsCollection.find().into(new ArrayList<>());
                            
                            for(Document student : studentsList) {
                                String rollNumber = student.getString("rollNumber");
                                String fullName = student.getString("fullName");
                                String className = student.getString("className");
                                String section = student.getString("section");
                    %>
                                <option value="<%= rollNumber %>">
                                    <%= rollNumber %> - <%= fullName %> (Class <%= className %>-<%= section %>)
                                </option>
                    <%
                            }
                        } catch(Exception e) {
                            out.println("<option value=''>Error loading students</option>");
                            e.printStackTrace();
                        }
                    %>
                </select>
            </div>
            
            <div class="marks-grid">
                <div class="subject-field">
                    <label>Mathematics (out of 100): *</label>
                    <input type="number" name="mathematics" min="0" max="100" required onkeyup="calculateTotal()">
                </div>
                
                <div class="subject-field">
                    <label>Science (out of 100): *</label>
                    <input type="number" name="science" min="0" max="100" required onkeyup="calculateTotal()">
                </div>
                
                <div class="subject-field">
                    <label>English (out of 100): *</label>
                    <input type="number" name="english" min="0" max="100" required onkeyup="calculateTotal()">
                </div>
                
                <div class="subject-field">
                    <label>Social Studies (out of 100): *</label>
                    <input type="number" name="socialStudies" min="0" max="100" required onkeyup="calculateTotal()">
                </div>
                
                <div class="subject-field">
                    <label>Hindi (out of 100): *</label>
                    <input type="number" name="hindi" min="0" max="100" required onkeyup="calculateTotal()">
                </div>
                
                <div class="subject-field">
                    <label>Computer Science (out of 100): *</label>
                    <input type="number" name="computerScience" min="0" max="100" required onkeyup="calculateTotal()">
                </div>
            </div>
            
            <div class="total-section">
                <h3>📊 Calculated Results</h3>
                <div class="total-display">
                    <div class="total-item">
                        <div class="label">Total Marks</div>
                        <div class="value" id="totalMarks">0</div>
                    </div>
                    <div class="total-item">
                        <div class="label">Out of</div>
                        <div class="value">600</div>
                    </div>
                    <div class="total-item">
                        <div class="label">Percentage</div>
                        <div class="value"><span id="percentage">0</span>%</div>
                    </div>
                    <div class="total-item">
                        <div class="label">Grade</div>
                        <div class="value" id="grade">-</div>
                    </div>
                </div>
            </div>
            
            <div class="btn-container">
                <button type="submit" class="btn btn-submit">💾 Save Marks</button>
                <a href="adminDashboard.jsp" class="btn btn-back">← Back to Dashboard</a>
            </div>
        </form>
    </div>
    
    <script>
        function calculateTotal() {
            var math = parseInt(document.getElementsByName("mathematics")[0].value) || 0;
            var science = parseInt(document.getElementsByName("science")[0].value) || 0;
            var english = parseInt(document.getElementsByName("english")[0].value) || 0;
            var social = parseInt(document.getElementsByName("socialStudies")[0].value) || 0;
            var hindi = parseInt(document.getElementsByName("hindi")[0].value) || 0;
            var computer = parseInt(document.getElementsByName("computerScience")[0].value) || 0;
            
            var total = math + science + english + social + hindi + computer;
            var percentage = (total / 600 * 100).toFixed(2);
            var grade = getGrade(percentage);
            
            document.getElementById("totalMarks").innerText = total;
            document.getElementById("percentage").innerText = percentage;
            document.getElementById("grade").innerText = grade;
        }
        
        function getGrade(percentage) {
            if(percentage >= 90) return "A+";
            else if(percentage >= 80) return "A";
            else if(percentage >= 70) return "B+";
            else if(percentage >= 60) return "B";
            else if(percentage >= 50) return "C";
            else if(percentage >= 40) return "D";
            else return "F";
        }
        
        function validateMarks() {
            var inputs = document.querySelectorAll('input[type="number"]');
            for(var i = 0; i < inputs.length; i++) {
                var value = parseInt(inputs[i].value);
                if(value < 0 || value > 100) {
                    alert("Marks must be between 0 and 100!");
                    return false;
                }
            }
            return true;
        }
    </script>
</body>
</html>
