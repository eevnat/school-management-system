<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Security check
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Schedule Exam</title>
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
            margin-bottom: 25px;
        }
        .header-section {
            display: grid;
            grid-template-columns: 1fr 1fr 1fr;
            gap: 20px;
            margin-bottom: 25px;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #e9ecef;
        }
        
        /* Table Styles */
        .schedule-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        .schedule-table th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: bold;
        }
        .schedule-table td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        .schedule-table input, .schedule-table textarea {
            width: 100%;
            padding: 8px;
            border: 2px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
            font-family: inherit;
            font-size: 14px;
        }
        .schedule-table input:focus, .schedule-table textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        .syllabus-cell textarea {
            min-height: 38px;
            resize: vertical;
        }

        /* Form Controls */
        label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: bold;
        }
        select, .form-input {
            width: 100%;
            padding: 10px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
        }
        select:focus, .form-input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        /* Buttons */
        .btn-row {
            margin-bottom: 15px;
            text-align: right;
        }
        .btn-add {
            background-color: #28a745;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
        }
        .btn-add:hover {
            background-color: #218838;
        }
        .btn-remove {
            background-color: #e74c3c;
            color: white;
            border: none;
            padding: 8px 12px;
            border-radius: 3px;
            cursor: pointer;
            font-weight: bold;
        }
        .btn-remove:hover {
            background-color: #c0392b;
        }
        .submit-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            margin-top: 20px;
            font-weight: bold;
        }
        .submit-btn:hover {
            opacity: 0.9;
        }
        
        /* Alerts */
        .alert { 
            padding: 12px; 
            margin-bottom: 20px; 
            border-radius: 5px; 
            text-align: center; 
            font-weight: bold;
        }
        .success { 
            background-color: #d4edda; 
            color: #155724; 
            border: 1px solid #c3e6cb;
        }
        .error { 
            background-color: #f8d7da; 
            color: #721c24; 
            border: 1px solid #f5c6cb;
        }
        
        .back-link {
            text-align: center;
            margin-top: 15px;
        }
        .back-link a {
            color: #666;
            text-decoration: none;
            font-weight: bold;
        }
        .back-link a:hover {
            color: #667eea;
        }
    </style>
    
    <script>
        function addRow() {
            var table = document.getElementById("examTable").getElementsByTagName('tbody')[0];
            var row = table.insertRow(-1);
            
            var cell1 = row.insertCell(0);
            cell1.innerHTML = '<input type="date" name="dates[]" required>';

            var cell2 = row.insertCell(1);
            cell2.innerHTML = '<input type="text" name="times[]" placeholder="10:30 A.M. TO 1:30 P.M." required>';

            var cell3 = row.insertCell(2);
            cell3.innerHTML = '<input type="text" name="codes[]" placeholder="041">';

            var cell4 = row.insertCell(3);
            cell4.innerHTML = '<input type="text" name="subjects[]" placeholder="MATHEMATICS" required>';
            
            var cell5 = row.insertCell(4);
            cell5.className = "syllabus-cell";
            cell5.innerHTML = '<textarea name="syllabi[]" placeholder="Ch: 1, 2, 5..."></textarea>';

            var cell6 = row.insertCell(5);
            cell6.style.textAlign = "center";
            var btn = document.createElement("button");
            btn.type = "button";
            btn.className = "btn-remove";
            btn.innerHTML = "X";
            btn.onclick = function() { 
                var rowIndex = this.parentNode.parentNode.rowIndex;
                document.getElementById("examTable").deleteRow(rowIndex);
            };
            cell6.appendChild(btn);
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>📅 Schedule Examination</h1>
        
        <% String s=request.getParameter("success"); if(s!=null && s.equals("1")){ %>
            <div class="alert success">✅ Exam Schedule Published Successfully!</div>
        <% } %>
        
        <form action="${pageContext.request.contextPath}/AddExamServlet" method="post">
            
            <!-- Top Controls -->
            <div class="header-section">
                <div>
                    <label>Exam Title / Name:</label>
                    <input type="text" name="examName" class="form-input" placeholder="e.g. Semester 1, Unit Test 2" required>
                </div>
                <div>
                    <label>Class / Target Audience:</label>
                    <select name="targetClass" class="form-input" required>
                        <option value="10">Class 10</option>
                        <option value="11">Class 11</option>
                        <option value="12">Class 12</option>
                        <option value="All">All Classes (Competitions)</option>
                    </select>
                </div>
                <div>
                    <label>Exam Category:</label>
                     <select name="examCategory" class="form-input" required>
                        <option value="Unit Test">Unit Test</option>
                        <option value="Semester">Semester Exam</option>
                        <option value="Extra">Extracurricular</option>
                    </select>
                </div>
            </div>

            <div class="btn-row">
                <button type="button" class="btn-add" onclick="addRow()">+ Add New Row</button>
            </div>
            
            <table class="schedule-table" id="examTable">
                <thead>
                    <tr>
                        <th width="15%">DAY & DATE</th>
                        <th width="20%">TIME</th>
                        <th width="10%">SUBJECT CODE</th>
                        <th width="25%">SUBJECT</th>
                        <th width="25%">SYLLABUS / PORTION</th>
                        <th width="5%"></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="date" name="dates[]" required></td>
                        <td><input type="text" name="times[]" placeholder="10:30 A.M. TO 1:30 P.M." required></td>
                        <td><input type="text" name="codes[]" placeholder="041"></td>
                        <td><input type="text" name="subjects[]" placeholder="MATHEMATICS" required></td>
                        <td class="syllabus-cell"><textarea name="syllabi[]" placeholder="Ch: 1, 2, 5..."></textarea></td>
                        <td style="text-align: center;"></td>
                    </tr>
                </tbody>
            </table>
            
             <div style="margin-top: 15px;">
                <label>Overall Note (Optional):</label>
                <textarea name="examNote" style="width:100%; height: 60px; border-radius:5px; border:2px solid #ddd; padding:10px; font-family: Arial;" placeholder="Any general instructions for the exam..."></textarea>
            </div>

            <button type="submit" class="submit-btn">📢 PUBLISH EXAM SCHEDULE</button>
            
            <div class="back-link">
                <a href="adminDashboard.jsp">← Cancel & Back to Dashboard</a>
            </div>
        </form>
    </div>
</body>
</html>
