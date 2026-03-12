<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login - ScholarHub</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px;
            position: relative;
            overflow: hidden;
        }
        
        /* Animated background circles */
        body::before {
            content: '';
            position: absolute;
            width: 450px;
            height: 450px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 50%;
            top: -200px;
            right: -150px;
            animation: float 18s infinite ease-in-out;
        }
        
        body::after {
            content: '';
            position: absolute;
            width: 380px;
            height: 380px;
            background: rgba(255, 255, 255, 0.08);
            border-radius: 50%;
            bottom: -150px;
            left: -120px;
            animation: float 14s infinite ease-in-out reverse;
        }
        
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(25px); }
        }
        
        .login-container {
            position: relative;
            z-index: 1;
            width: 100%;
            max-width: 460px;
            animation: fadeInUp 0.8s ease;
        }
        
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .login-box {
            background: white;
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 25px 70px rgba(0, 0, 0, 0.35);
            backdrop-filter: blur(10px);
        }
        
        .header {
            text-align: center;
            margin-bottom: 32px;
        }
        
        .icon-wrapper {
            width: 80px;
            height: 80px;
            margin: 0 auto 18px;
            background: linear-gradient(135deg, #3b82f6, #2563eb);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.4);
            animation: pulse 2.5s infinite ease-in-out;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); box-shadow: 0 8px 20px rgba(59, 130, 246, 0.4); }
            50% { transform: scale(1.05); box-shadow: 0 12px 28px rgba(59, 130, 246, 0.5); }
        }
        
        h2 {
            color: #111827;
            font-size: 26px;
            font-weight: 600;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }
        
        .subtitle {
            color: #6b7280;
            font-size: 14px;
            letter-spacing: 0.3px;
            font-weight: 400;
        }
        
        .error-msg {
            background: #fee2e2;
            border: 1px solid #fecaca;
            color: #dc2626;
            padding: 12px 16px;
            border-radius: 12px;
            margin-bottom: 22px;
            font-size: 13px;
            text-align: center;
            animation: shake 0.5s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }
        
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            50% { transform: translateX(8px); }
            75% { transform: translateX(-8px); }
        }
        
        .form-group {
            margin-bottom: 22px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            color: #374151;
            font-weight: 600;
            font-size: 14px;
            letter-spacing: 0.2px;
        }
        
        input[type="text"], 
        input[type="password"] {
            width: 100%;
            padding: 13px 16px;
            border: 2px solid #e5e7eb;
            border-radius: 12px;
            font-size: 15px;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background: #fafbfc;
            font-family: inherit;
        }
        
        input:focus {
            outline: none;
            border-color: #3b82f6;
            background: white;
            box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1);
            transform: translateY(-1px);
        }
        
        input::placeholder {
            color: #9ca3af;
            font-size: 14px;
        }
        
        button {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
            box-shadow: 0 4px 16px rgba(59, 130, 246, 0.4);
            margin-top: 8px;
            letter-spacing: 0.3px;
        }
        
        button:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 24px rgba(59, 130, 246, 0.5);
        }
        
        button:active {
            transform: translateY(-1px);
            box-shadow: 0 4px 16px rgba(59, 130, 246, 0.4);
        }
        
        .back-link {
            text-align: center;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #e5e7eb;
        }
        
        .back-link a {
            color: #3b82f6;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        
        .back-link a:hover {
            color: #2563eb;
            transform: translateX(-3px);
        }
        
        .footer {
            text-align: center;
            color: white;
            margin-top: 20px;
            font-size: 13px;
            opacity: 0.92;
            letter-spacing: 0.3px;
            animation: fadeIn 1s ease 0.4s backwards;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 0.92; }
        }
        
        /* Responsive */
        @media (max-width: 768px) {
            .login-box { padding: 35px 30px; }
            h2 { font-size: 24px; }
        }
        
        @media (max-width: 480px) {
            .login-container { max-width: 380px; }
            .login-box { padding: 30px 24px; }
            .icon-wrapper { width: 70px; height: 70px; font-size: 36px; }
            h2 { font-size: 22px; }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="header">
                <div class="icon-wrapper">👨‍🎓</div>
                <h2>Student Login</h2>
                <p class="subtitle">Welcome back! Please enter your credentials</p>
            </div>
            
            <% 
                String error = request.getParameter("error");
                if(error != null) {
            %>
                <div class="error-msg">
                    <span>❌</span>
                    <span>Invalid roll number or password. Please try again.</span>
                </div>
            <% } %>
            
			<form action="StudentLoginServlet" method="post">                <div class="form-group">
                    <label>Roll Number</label>
                    <input type="text" name="rollNumber" placeholder="Enter your roll number" required autofocus>
                </div>
                
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Enter your password" required>
                </div>
                
                <button type="submit">🔐 Sign In</button>
            </form>
            
            <div class="back-link">
                <a href="../index.jsp">
                    <span>←</span>
                    <span>Back to Home</span>
                </a>
            </div>
        </div>
        
        <div class="footer">
            © <%= java.time.Year.now() %> ScholarHub • All Rights Reserved
        </div>
    </div>
</body>
</html>
