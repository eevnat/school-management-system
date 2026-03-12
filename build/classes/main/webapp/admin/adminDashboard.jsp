<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection" %>
<%@ page import="com.mongodb.client.MongoDatabase" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="com.student.util.NotificationUtil" %>
<%@ page import="org.bson.Document" %>

<%
    // Check if admin is logged in (security check)
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }

    String adminName = (String) session.getAttribute("adminName");

    // unread notification count (ADMIN)
    long unreadCount = 0;
    try {
        MongoDatabase db = MongoDBUtil.getDatabase();
        MongoCollection<Document> col = db.getCollection("notifications");

        // Treat missing isRead as unread too: isRead in [false, null]
        Document filter = new Document("toUserType", "admin")
                .append("toUserId", NotificationUtil.ADMIN_ID)
                .append("isRead", new Document("$in", java.util.Arrays.asList(false, null)));

        unreadCount = col.countDocuments(filter);
    } catch(Exception e) {
        unreadCount = 0;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        
        .dashboard {
            max-width: 1400px;
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
            font-size: 32px;
        }
        
        .welcome {
            text-align: center;
            color: #666;
            font-size: 18px;
            margin-bottom: 30px;
        }
        
        .section-title {
            color: #667eea;
            font-size: 22px;
            font-weight: bold;
            margin: 30px 0 20px 0;
            padding-bottom: 10px;
            border-bottom: 3px solid #667eea;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .menu-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 25px;
            border-radius: 12px;
            text-align: center;
            text-decoration: none;
            transition: transform 0.3s, box-shadow 0.3s;
            display: block;
            position: relative;
            min-height: 140px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }
        
        .menu-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.3);
        }
        
        .menu-card.attendance {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .menu-card.homework {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .menu-card.behavior {
            background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
        }
        
        .menu-card.reports {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        
        .card-icon {
            font-size: 36px;
            margin-bottom: 12px;
        }
        
        .card-title {
            margin: 0 0 8px 0;
            font-size: 18px;
            color: white;
            font-weight: bold;
        }
        
        .card-description {
            margin: 0;
            font-size: 13px;
            opacity: 0.9;
            color: white;
            line-height: 1.4;
        }
        
        .logout-btn {
            display: block;
            width: 150px;
            margin: 30px auto 0;
            padding: 12px;
            background-color: #e74c3c;
            color: white;
            text-align: center;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            transition: background-color 0.3s, transform 0.3s;
        }
        
        .logout-btn:hover {
            background-color: #c0392b;
            transform: translateY(-2px);
        }

        .notif-badge {
            position: absolute;
            top: 12px;
            right: 12px;
            background: #e53e3e;
            color: #fff;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: bold;
            min-width: 20px;
            text-align: center;
            line-height: 1.2;
            box-shadow: 0 2px 8px rgba(0,0,0,0.3);
        }
        
        .feature-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            background: #10b981;
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
        }
        
        @media (max-width: 768px) {
            .menu-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard">
        <h1><i class="fas fa-user-shield"></i> Admin Dashboard</h1>
        <div class="welcome">Welcome back, <strong><%= adminName %></strong>! </div>

        <!-- NEW SECTION: Attendance & Daily Operations -->
        <div class="section-title">
            <i class="fas fa-calendar-check"></i> Attendance & Daily Operations
        </div>
        <div class="menu-grid">
            <a href="markAttendance.jsp" class="menu-card attendance">
                <span class="feature-badge">NEW</span>
                <div class="card-icon"><i class="fas fa-clipboard-check"></i></div>
                <div class="card-title">Mark Attendance</div>
                <div class="card-description">Daily attendance marking with auto parent alerts</div>
            </a>

            <a href="viewAttendanceReport.jsp" class="menu-card reports">
                <span class="feature-badge">NEW</span>
                <div class="card-icon"><i class="fas fa-chart-line"></i></div>
                <div class="card-title">Attendance Reports</div>
                <div class="card-description">Monthly reports & defaulters list (<75%)</div>
            </a>

            <a href="addHomework.jsp" class="menu-card homework">
                <span class="feature-badge">NEW</span>
                <div class="card-icon"><i class="fas fa-book"></i></div>
                <div class="card-title">Assign Homework</div>
                <div class="card-description">Post homework with attachments & due dates</div>
            </a>

            <a href="viewHomework.jsp" class="menu-card homework">
                <div class="card-icon"><i class="fas fa-tasks"></i></div>
                <div class="card-title">View All Homework</div>
                <div class="card-description">Track homework completion status</div>
            </a>
        </div>

        <!-- NEW SECTION: Behavior & Discipline -->
        <div class="section-title">
            <i class="fas fa-star"></i> Behavior & Discipline
        </div>
        <div class="menu-grid">
            <a href="addBehaviorLog.jsp" class="menu-card behavior">
                <span class="feature-badge">NEW</span>
                <div class="card-icon"><i class="fas fa-clipboard-list"></i></div>
                <div class="card-title">Add Behavior Log</div>
                <div class="card-description">Record positive, warnings & severe incidents</div>
            </a>

            <a href="viewBehaviorLogs.jsp" class="menu-card behavior">
                <div class="card-icon"><i class="fas fa-history"></i></div>
                <div class="card-title">View Behavior History</div>
                <div class="card-description">Student-wise behavior tracking</div>
            </a>
        </div>

        <!-- EXISTING SECTION: Student Management -->
        <div class="section-title">
            <i class="fas fa-users"></i> Student Management
        </div>
        <div class="menu-grid">
            <a href="addStudent.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-user-plus"></i></div>
                <div class="card-title">Add Student</div>
                <div class="card-description">Register new student in system</div>
            </a>

            <a href="viewStudents.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-users-cog"></i></div>
                <div class="card-title">View Students</div>
                <div class="card-description">View, edit, delete students</div>
            </a>

            <a href="addMarks.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-pencil-alt"></i></div>
                <div class="card-title">Add Marks</div>
                <div class="card-description">Add subject-wise marks</div>
            </a>

            <a href="examDashboard.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-file-alt"></i></div>
                <div class="card-title">Exam Management</div>
                <div class="card-description">Manage unit/semester exams, olympiads, competitions</div>
            </a>

            <a href="viewReportCards.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-chart-bar"></i></div>
                <div class="card-title">View Report Cards</div>
                <div class="card-description">Generate and view reports</div>
            </a>
        </div>

        <!-- EXISTING SECTION: Events & Communication -->
        <div class="section-title">
            <i class="fas fa-bullhorn"></i> Events & Communication
        </div>
        <div class="menu-grid">
            <a href="addEvent.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-calendar-plus"></i></div>
                <div class="card-title">Add Event</div>
                <div class="card-description">Create new school event</div>
            </a>

            <a href="viewEventRegistrations.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-list-check"></i></div>
                <div class="card-title">Event Registrations</div>
                <div class="card-description">View registered students</div>
            </a>

            <a href="addNotice.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-clipboard"></i></div>
                <div class="card-title">Notice Board</div>
                <div class="card-description">Create and manage notices</div>
            </a>

            <a href="viewLeaveRequests.jsp" class="menu-card">
                <div class="card-icon"><i class="fas fa-envelope-open-text"></i></div>
                <div class="card-title">Leave Requests</div>
                <div class="card-description">Approve / Reject Parent-approved leaves</div>
            </a>

            <a href="notifications.jsp" class="menu-card">
                <% if(unreadCount > 0) { %>
                    <span class="notif-badge"><%= unreadCount %></span>
                <% } %>
                <div class="card-icon"><i class="fas fa-bell"></i></div>
                <div class="card-title">Notifications</div>
                <div class="card-description">View alerts (leave approvals, event registrations, notices)</div>
            </a>
        </div>

        <a href="../LogoutServlet" class="logout-btn">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
    </div>
</body>
</html>
