<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Parent Login - ScholarHub</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 12px;
            position: relative;
            overflow: hidden;
        }
        
        body::before {
            content: '';
            position: absolute;
            width: 450px;
            height: 450px;
            background: rgba(255, 255, 255, 0.08);
            border-radius: 50%;
            top: -180px;
            right: -120px;
            animation: float 15s infinite ease-in-out;
        }
        
        body::after {
            content: '';
            position: absolute;
            width: 380px;
            height: 380px;
            background: rgba(255, 255, 255, 0.06);
            border-radius: 50%;
            bottom: -120px;
            left: -120px;
            animation: float 12s infinite ease-in-out reverse;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(20px); }
        }
        
        .login-container {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 580px;
            animation: slideUp 0.6s ease;
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .login-box {
            background: rgba(255, 255, 255, 0.98);
            padding: 24px 35px 22px 35px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(10px);
        }
        
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .icon-wrapper {
            width: 60px;
            height: 60px;
            margin: 0 auto 12px;
            background: linear-gradient(135deg, #10b981, #059669);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            box-shadow: 0 8px 20px rgba(16, 185, 129, 0.4);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        h2 {
            color: #111827;
            font-size: 22px;
            font-weight: 600;
            margin-bottom: 4px;
        }
        
        .subtitle {
            color: #6b7280;
            font-size: 13px;
            letter-spacing: 0.3px;
        }
        
        .error-msg {
            background: #fee2e2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 9px 14px;
            border-radius: 10px;
            margin-bottom: 14px;
            font-size: 13px;
            text-align: center;
            animation: shake 0.5s;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-10px); }
            75% { transform: translateX(10px); }
        }
        
        .form-group {
            margin-bottom: 14px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            color: #374151;
            font-weight: 600;
            font-size: 13px;
            letter-spacing: 0.2px;
        }
        
        input[type="text"], 
        input[type="email"] {
            width: 100%;
            padding: 10px 13px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
            background: #fafbfc;
        }
        
        input:focus {
            outline: none;
            border-color: #10b981;
            background: white;
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
        }
        
        input::placeholder {
            color: #9ca3af;
            font-size: 13px;
        }
        
        .row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
        }
        
        button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
            margin-top: 4px;
        }
        
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.5);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        .back-link {
            text-align: center;
            margin-top: 14px;
            padding-top: 12px;
            border-top: 1px solid #e5e7eb;
        }
        
        .back-link a {
            color: #10b981;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }
        
        .back-link a:hover {
            color: #059669;
        }
        
        @media (max-width: 640px) {
            body { padding: 10px; }
            .login-box { padding: 22px 25px 20px 25px; }
            .login-container { max-width: 460px; }
            .row { grid-template-columns: 1fr; gap: 0; }
        }
        
        @media (max-height: 700px) {
            .login-box { padding: 20px 30px 18px 30px; }
            .header { margin-bottom: 16px; }
            .icon-wrapper { width: 55px; height: 55px; font-size: 26px; margin-bottom: 10px; }
            .form-group { margin-bottom: 12px; }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="header">
                <div class="icon-wrapper">👪</div>
                <h2>Parent Login</h2>
                <p class="subtitle">Access your child's academic information</p>
            </div>
            
            <% if(request.getParameter("error") != null) { %>
                <div class="error-msg">
                    ❌ <%= request.getParameter("error") %>
                </div>
            <% } %>
            
            <form action="<%= request.getContextPath() %>/ParentLoginServlet" method="post">
                <div class="form-group">
                    <label for="parentName">Parent Name</label>
                    <input type="text" id="parentName" name="parentName" placeholder="Enter your full name" required autofocus>
                </div>
                
                <div class="form-group">
                    <label for="parentEmail">Email Address</label>
                    <input type="email" id="parentEmail" name="parentEmail" placeholder="Enter your email address" required>
                </div>
                
                <div class="row">
                    <div class="form-group">
                        <label for="studentClass">Class</label>
                        <input type="text" id="studentClass" name="studentClass" placeholder="e.g., 10" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="studentSection">Section</label>
                        <input type="text" id="studentSection" name="studentSection" placeholder="e.g., A" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="studentRollNo">Student Roll Number</label>
                    <input type="text" id="studentRollNo" name="studentRollNo" placeholder="Enter student's roll number" required>
                </div>
                
                <button type="submit">🔐 Sign In</button>
            </form>
            
            <div class="back-link">
                <a href="<%= request.getContextPath() %>/index.jsp">← Back to Home</a>
            </div>
        </div>
    </div>
</body>
</html>
