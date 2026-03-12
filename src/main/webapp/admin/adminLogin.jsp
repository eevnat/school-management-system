<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Login - ScholarHub</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 15px;
            position: relative;
            overflow: hidden;
        }
        
        body::before {
            content: '';
            position: absolute;
            width: 400px;
            height: 400px;
            background: rgba(255, 255, 255, 0.08);
            border-radius: 50%;
            top: -150px;
            right: -100px;
            animation: float 15s infinite ease-in-out;
        }
        
        body::after {
            content: '';
            position: absolute;
            width: 350px;
            height: 350px;
            background: rgba(255, 255, 255, 0.06);
            border-radius: 50%;
            bottom: -100px;
            left: -100px;
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
            max-width: 520px;
            animation: slideUp 0.6s ease;
        }
        
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .login-box {
            background: rgba(255, 255, 255, 0.98);
            padding: 32px 40px 28px 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            backdrop-filter: blur(10px);
        }
        
        .header {
            text-align: center;
            margin-bottom: 28px;
        }
        
        .icon-wrapper {
            width: 70px;
            height: 70px;
            margin: 0 auto 16px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 34px;
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.4);
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        h2 {
            color: #111827;
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 6px;
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
            padding: 10px 14px;
            border-radius: 10px;
            margin-bottom: 18px;
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
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 7px;
            color: #374151;
            font-weight: 600;
            font-size: 13px;
            letter-spacing: 0.2px;
        }
        
        input[type="text"], 
        input[type="password"] {
            width: 100%;
            padding: 12px 14px;
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 14px;
            transition: all 0.3s ease;
            background: #fafbfc;
        }
        
        input:focus {
            outline: none;
            border-color: #667eea;
            background: white;
            box-shadow: 0 0 0 4px rgba(102, 126, 234, 0.1);
        }
        
        input::placeholder {
            color: #9ca3af;
        }
        
        button {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            margin-top: 6px;
        }
        
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
        }
        
        button:active {
            transform: translateY(0);
        }
        
        .back-link {
            text-align: center;
            margin-top: 18px;
            padding-top: 16px;
            border-top: 1px solid #e5e7eb;
        }
        
        .back-link a {
            color: #667eea;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-block;
        }
        
        .back-link a:hover {
            color: #764ba2;
        }
        
        @media (max-width: 580px) {
            .login-container { max-width: 420px; }
            .login-box { padding: 28px 25px 24px 25px; }
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-box">
            <div class="header">
                <div class="icon-wrapper">👨‍🏫</div>
                <h2>Admin Login</h2>
                <p class="subtitle">Welcome back! Please enter your credentials</p>
            </div>
            
            <% 
                String error = request.getParameter("error");
                if(error != null) {
            %>
                <div class="error-msg">
                    ❌ Invalid username or password. Please try again.
                </div>
            <% } %>
            
            <form action="../AdminLoginServlet" method="post">
                <div class="form-group">
                    <label>Username</label>
                    <input type="text" name="username" placeholder="Enter your username" required autofocus>
                </div>
                
                <div class="form-group">
                    <label>Password</label>
                    <input type="password" name="password" placeholder="Enter your password" required>
                </div>
                
                <button type="submit">🔐 Sign In</button>
            </form>
            
            <div class="back-link">
                <a href="../index.jsp">← Back to Home</a>
            </div>
        </div>
    </div>
</body>
</html>
