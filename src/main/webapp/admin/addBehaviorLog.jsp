<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
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
    <title>Behavior & Discipline Log - Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
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
        
        .form-section {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            font-weight: 600;
            color: #333;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 14px;
            font-family: inherit;
            transition: all 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #fa709a;
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .type-selector {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .type-card {
            padding: 20px;
            border: 3px solid #e0e0e0;
            border-radius: 15px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .type-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        
        .type-card.active.positive {
            border-color: #10b981;
            background: #d1fae5;
        }
        
        .type-card.active.warning {
            border-color: #f59e0b;
            background: #fef3c7;
        }
        
        .type-card.active.severe {
            border-color: #ef4444;
            background: #fee2e2;
        }
        
        .type-card .icon {
            font-size: 40px;
            margin-bottom: 10px;
        }
        
        .type-card h3 {
            font-size: 16px;
            margin-bottom: 5px;
        }
        
        .type-card p {
            font-size: 12px;
            color: #666;
        }
        
        .checkbox-group {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 15px;
            background: #fef3c7;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .checkbox-group input[type="checkbox"] {
            width: 20px;
            height: 20px;
            cursor: pointer;
        }
        
        .checkbox-group label {
            margin: 0;
            cursor: pointer;
            font-weight: normal;
        }
        
        .submit-btn {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
            color: white;
            padding: 15px 40px;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 18px;
            font-weight: 600;
            width: 100%;
            transition: all 0.3s;
        }
        
        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 30px rgba(250, 112, 154, 0.4);
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
        
        .student-search {
            position: relative;
        }
        
        .search-results {
            position: absolute;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            border: 2px solid #e0e0e0;
            border-top: none;
            border-radius: 0 0 10px 10px;
            max-height: 200px;
            overflow-y: auto;
            z-index: 1000;
            display: none;
        }
        
        .search-result-item {
            padding: 12px;
            cursor: pointer;
            border-bottom: 1px solid #f0f0f0;
            transition: all 0.3s;
        }
        
        .search-result-item:hover {
            background: #f8f9fa;
        }
        
        .hidden {
            display: none;
        }
        
        .manual-entry {
            background: #e0f2fe;
            padding: 15px;
            border-radius: 10px;
            margin-top: 10px;
            border-left: 4px solid #3b82f6;
        }
        
        .manual-entry p {
            margin-bottom: 10px;
            color: #1e40af;
            font-size: 14px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-clipboard-list"></i> Behavior & Discipline Log</h1>
        <a href="adminDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
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
        
        <form method="POST" action="../AddBehaviorLogServlet" class="form-section">
            
            <!-- Manual Student ID Entry -->
            <div class="form-group">
                <label>Enter Student ID <span style="color: red;">*</span></label>
                <input type="text" 
                       name="studentId" 
                       id="manualStudentId" 
                       placeholder="Enter Student ID (e.g., S001)" 
                       required>
                <div class="manual-entry">
                    <p><i class="fas fa-info-circle"></i> <strong>Note:</strong> Enter the Student ID directly. The system will validate it when you submit.</p>
                </div>
            </div>
            
            <label style="display: block; font-weight: 600; margin-bottom: 15px; margin-top: 20px;">Select Behavior Type <span style="color: red;">*</span></label>
            <div class="type-selector">
                <div class="type-card" onclick="selectType('POSITIVE', this)">
                    <div class="icon">👍</div>
                    <h3>Positive</h3>
                    <p>Good behavior, excellence</p>
                </div>
                <div class="type-card" onclick="selectType('WARNING', this)">
                    <div class="icon">⚠️</div>
                    <h3>Warning</h3>
                    <p>Minor misconduct</p>
                </div>
                <div class="type-card" onclick="selectType('SEVERE', this)">
                    <div class="icon">🚨</div>
                    <h3>Severe</h3>
                    <p>Serious violation</p>
                </div>
            </div>
            <input type="hidden" name="type" id="selectedType" required>
            
            <div class="form-group">
                <label>Category <span style="color: red;">*</span></label>
                <select name="category" required>
                    <option value="">Select Category</option>
                    <option value="Discipline">Discipline</option>
                    <option value="Participation">Class Participation</option>
                    <option value="Conduct">General Conduct</option>
                    <option value="Punctuality">Punctuality</option>
                    <option value="Academic">Academic Excellence</option>
                    <option value="Sports">Sports & Athletics</option>
                    <option value="Leadership">Leadership</option>
                    <option value="Bullying">Bullying/Harassment</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Description <span style="color: red;">*</span></label>
                <textarea name="description" placeholder="Describe the behavior in detail..." required></textarea>
            </div>
            
            <div class="checkbox-group">
                <input type="checkbox" name="notifyParent" id="notifyParent" checked>
                <label for="notifyParent">
                    <i class="fas fa-bell"></i> Send notification to parent
                </label>
            </div>
            
            <button type="submit" class="submit-btn">
                <i class="fas fa-save"></i> Log Behavior
            </button>
        </form>
    </div>
</div>

<script>
    function selectType(type, element) {
        // Remove active class from all cards
        document.querySelectorAll('.type-card').forEach(card => {
            card.classList.remove('active', 'positive', 'warning', 'severe');
        });
        
        // Add active class to selected card
        element.classList.add('active', type.toLowerCase());
        
        // Set hidden input value
        document.getElementById('selectedType').value = type;
        
        console.log('Selected type:', type);
    }
    
    // Form validation
    document.querySelector('form').addEventListener('submit', function(e) {
        const studentId = document.getElementById('manualStudentId').value.trim();
        const type = document.getElementById('selectedType').value;
        
        if (!studentId) {
            e.preventDefault();
            alert('Please enter Student ID!');
            return false;
        }
        
        if (!type) {
            e.preventDefault();
            alert('Please select a behavior type!');
            return false;
        }
        
        return true;
    });
</script>
</body>
</html>
