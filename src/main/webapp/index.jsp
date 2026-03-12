<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ScholarHub - Student Management Portal</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 15px;
      position: relative;
      overflow: hidden;
    }
    
    /* Animated background circles */
    body::before {
      content: '';
      position: absolute;
      width: 500px;
      height: 500px;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 50%;
      top: -250px;
      right: -250px;
      animation: float 20s infinite ease-in-out;
    }
    
    body::after {
      content: '';
      position: absolute;
      width: 400px;
      height: 400px;
      background: rgba(255, 255, 255, 0.08);
      border-radius: 50%;
      bottom: -200px;
      left: -200px;
      animation: float 15s infinite ease-in-out reverse;
    }
    
    @keyframes float {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(30px); }
    }
    
    .container {
      max-width: 980px;
      width: 100%;
      position: relative;
      z-index: 1;
    }
    
    /* Header */
    .header {
      text-align: center;
      color: white;
      margin-bottom: 30px;
      animation: fadeInDown 0.8s ease;
    }
    
    @keyframes fadeInDown {
      from { opacity: 0; transform: translateY(-30px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .logo {
      font-size: 42px;
      font-weight: 700;
      margin-bottom: 8px;
      letter-spacing: -1px;
      text-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
    }
    
    .tagline {
      font-size: 16px;
      opacity: 0.95;
      font-weight: 300;
      letter-spacing: 0.5px;
    }
    
    /* Main Card */
    .main-card {
      background: white;
      border-radius: 24px;
      padding: 35px 40px;
      box-shadow: 0 25px 70px rgba(0, 0, 0, 0.35);
      animation: fadeInUp 0.8s ease;
      backdrop-filter: blur(10px);
    }
    
    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(30px); }
      to { opacity: 1; transform: translateY(0); }
    }
    
    .welcome {
      text-align: center;
      margin-bottom: 32px;
    }
    
    .welcome h2 {
      font-size: 24px;
      color: #111827;
      margin-bottom: 8px;
      font-weight: 600;
    }
    
    .welcome p {
      color: #6b7280;
      font-size: 14px;
      letter-spacing: 0.3px;
    }
    
    /* Role Cards Grid */
    .roles {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 20px;
      max-width: 840px;
      margin: 0 auto;
    }
    
    .role {
      display: block;
      text-decoration: none;
      background: #fafbfc;
      border: 2px solid #e5e7eb;
      border-radius: 16px;
      padding: 26px 20px;
      text-align: center;
      transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
      position: relative;
      overflow: hidden;
    }
    
    /* Gradient overlay on hover */
    .role::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      opacity: 0;
      transition: opacity 0.4s ease;
      z-index: 0;
    }
    
    .role.admin::before { background: linear-gradient(135deg, rgba(102, 126, 234, 0.05), rgba(118, 75, 162, 0.05)); }
    .role.student::before { background: linear-gradient(135deg, rgba(59, 130, 246, 0.05), rgba(37, 99, 235, 0.05)); }
    .role.parent::before { background: linear-gradient(135deg, rgba(16, 185, 129, 0.05), rgba(5, 150, 105, 0.05)); }
    
    .role:hover {
      transform: translateY(-8px);
      box-shadow: 0 16px 36px rgba(0, 0, 0, 0.18);
    }
    
    .role:hover::before { opacity: 1; }
    
    .role.admin:hover { border-color: #667eea; }
    .role.student:hover { border-color: #3b82f6; }
    .role.parent:hover { border-color: #10b981; }
    
    .role > * { position: relative; z-index: 1; }
    
    .role-icon {
      width: 65px;
      height: 65px;
      margin: 0 auto 16px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 30px;
      transition: transform 0.4s ease;
      box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
    }
    
    .role:hover .role-icon {
      transform: scale(1.1) rotate(5deg);
    }
    
    .role.admin .role-icon { background: linear-gradient(135deg, #667eea, #764ba2); }
    .role.student .role-icon { background: linear-gradient(135deg, #3b82f6, #2563eb); }
    .role.parent .role-icon { background: linear-gradient(135deg, #10b981, #059669); }
    
    .role h3 {
      font-size: 18px;
      color: #111827;
      margin-bottom: 8px;
      font-weight: 600;
      letter-spacing: 0.2px;
    }
    
    .role p {
      font-size: 13px;
      color: #6b7280;
      line-height: 1.5;
      letter-spacing: 0.2px;
    }
    
    /* Footer */
    .footer {
      text-align: center;
      color: white;
      margin-top: 25px;
      font-size: 13px;
      opacity: 0.92;
      letter-spacing: 0.3px;
      animation: fadeIn 1s ease 0.5s backwards;
    }
    
    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 0.92; }
    }
    
    /* Responsive */
    @media (max-width: 900px) {
      .roles { grid-template-columns: 1fr; max-width: 380px; }
    }
    
    @media (max-width: 768px) {
      .logo { font-size: 36px; }
      .tagline { font-size: 15px; }
      .main-card { padding: 30px 25px; }
      .welcome h2 { font-size: 22px; }
      .header { margin-bottom: 25px; }
    }
    
    @media (max-width: 480px) {
      .logo { font-size: 32px; }
      .main-card { padding: 28px 20px; }
      .role { padding: 24px 18px; }
      .role-icon { width: 58px; height: 58px; font-size: 26px; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="logo">ScholarHub</div>
      <div class="tagline">Connecting Students, Parents & Educators!</div>
    </div>
    
    <div class="main-card">
      <div class="welcome">
        <h2>Welcome to ScholarHub</h2>
        <p>Select your role to continue</p>
      </div>
      
      <div class="roles">
        <a href="admin/adminLogin.jsp" class="role admin">
          <div class="role-icon">👨‍🏫</div>
          <h3>Admin</h3>
          <p>Manage students, marks, events, notices and system</p>
        </a>
        
        <a href="student/studentLogin.jsp" class="role student">
          <div class="role-icon">👨‍🎓</div>
          <h3>Student</h3>
          <p>View marks, report card, notices, events and alerts</p>
        </a>
        
        <a href="parent/parentLogin.jsp" class="role parent">
          <div class="role-icon">👪</div>
          <h3>Parent</h3>
          <p>Track child's performance, notices and approvals</p>
        </a>
      </div>
    </div>
    
    <div class="footer">
      © <%= java.time.Year.now() %> ScholarHub • All Rights Reserved
    </div>
  </div>
</body>
</html>
