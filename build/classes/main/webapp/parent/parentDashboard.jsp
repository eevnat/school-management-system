<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection" %>
<%@ page import="com.mongodb.client.MongoDatabase" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.util.Arrays" %>

<%
    // Check if parent is logged in
    if(session.getAttribute("userType") == null || !session.getAttribute("userType").equals("parent")) {
        response.sendRedirect("parentLogin.jsp");
        return;
    }

    String parentName = (String) session.getAttribute("parentName");
    String studentName = (String) session.getAttribute("studentName");
    String studentClass = (String) session.getAttribute("studentClass");
    String studentSection = (String) session.getAttribute("studentSection");
    String studentRollNumber = (String) session.getAttribute("studentRollNumber");

    // Get student ID from database
    String studentId = "";
    try {
        MongoDatabase db = MongoDBUtil.getDatabase();
        MongoCollection<Document> studentCol = db.getCollection("students");
        Document student = studentCol.find(new Document("rollNumber", studentRollNumber)).first();
        if (student != null) {
            studentId = student.getString("studentId");
            session.setAttribute("studentId", studentId);
        }
    } catch(Exception e) {
        e.printStackTrace();
    }

    // Unread notification count
    long unreadCount = 0;
    try {
        MongoDatabase db = MongoDBUtil.getDatabase();
        MongoCollection<Document> col = db.getCollection("notifications");
        Document filter = new Document("toUserType", "parent")
                .append("toUserId", studentRollNumber)
                .append("isRead", new Document("$in", Arrays.asList(false, null)));
        unreadCount = col.countDocuments(filter);
    } catch(Exception e) {
        unreadCount = 0;
    }

    // Count pending homework
    long pendingHomework = 0;
    try {
        MongoDatabase db = MongoDBUtil.getDatabase();
        MongoCollection<Document> hwCol = db.getCollection("homework");
        Document hwFilter = new Document("className", studentClass)
                .append("section", studentSection)
                .append("active", true);
        pendingHomework = hwCol.countDocuments(hwFilter);
    } catch(Exception e) {
        pendingHomework = 0;
    }

    // Count behavior logs
    long behaviorCount = 0;
    try {
        MongoDatabase db = MongoDBUtil.getDatabase();
        MongoCollection<Document> behCol = db.getCollection("behavior_logs");
        Document behFilter = new Document("studentId", studentId);
        behaviorCount = behCol.countDocuments(behFilter);
    } catch(Exception e) {
        behaviorCount = 0;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Parent Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #48bb78 0%, #38a169 100%);
            min-height: 100vh;
        }
        .navbar {
            background-color: rgba(255, 255, 255, 0.95);
            padding: 15px 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar h2 { color: #48bb78; }
        .user-info { display: flex; align-items: center; gap: 20px; }
        .user-info span { color: #333; font-weight: bold; }
        .logout-btn {
            padding: 8px 20px;
            background-color: #e53e3e;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .logout-btn:hover { background-color: #c53030; }

        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .welcome-card {
            background-color: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .welcome-card h1 { color: #333; margin-bottom: 15px; }
        .student-info {
            background-color: #f7fafc;
            padding: 15px;
            border-radius: 8px;
            margin-top: 15px;
        }
        .student-info p { color: #555; margin: 8px 0; font-size: 16px; }
        .student-info strong { color: #48bb78; }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }
        .dashboard-card {
            background-color: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            text-align: center;
            transition: transform 0.3s;
            position: relative;
        }
        .dashboard-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }
        .card-icon { font-size: 50px; margin-bottom: 15px; }
        .dashboard-card h3 { color: #333; margin-bottom: 10px; }
        .dashboard-card p { color: #666; margin-bottom: 20px; }
        .card-btn {
            display: inline-block;
            padding: 12px 25px;
            background-color: #48bb78;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            transition: background-color 0.3s;
        }
        .card-btn:hover { background-color: #38a169; }

        .notif-badge {
            position: absolute;
            top: 14px;
            right: 14px;
            background: #e53e3e;
            color: #fff;
            border-radius: 999px;
            padding: 3px 9px;
            font-size: 12px;
            font-weight: bold;
            min-width: 18px;
            text-align: center;
            line-height: 1.2;
        }
        
        .new-badge {
            position: absolute;
            top: 14px;
            right: 14px;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h2>👪 Parent Portal</h2>
        <div class="user-info">
            <span>Welcome, <%= parentName %></span>
            <a href="../LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="welcome-card">
            <h1>Welcome, <%= parentName %>!</h1>
            <p>Access your child's academic information and performance.</p>

            <div class="student-info">
                <h3 style="color: #48bb78; margin-bottom: 10px;">📚 Student Details</h3>
                <p><strong>Name:</strong> <%= studentName %></p>
                <p><strong>Class:</strong> <%= studentClass %> - <%= studentSection %></p>
                <p><strong>Roll Number:</strong> <%= studentRollNumber %></p>
            </div>
        </div>

        <div class="dashboard-grid">
            
            <!-- NEW: Child's Homework -->
            <div class="dashboard-card">
                <% if(pendingHomework > 0) { %>
                    <span class="notif-badge"><%= pendingHomework %></span>
                <% } %>
                <div class="card-icon">📚</div>
                <h3>Child's Homework</h3>
                <p>Track assigned homework & completion</p>
                <a href="childHomework.jsp" class="card-btn">View Homework</a>
            </div>
            
            <!-- NEW: Child's Attendance -->
            <div class="dashboard-card">
                <span class="new-badge">NEW</span>
                <div class="card-icon">📅</div>
                <h3>Attendance Report</h3>
                <p>View monthly attendance & absence alerts</p>
                <a href="childAttendance.jsp" class="card-btn">View Attendance</a>
            </div>
            
            <!-- NEW: Behavior History -->
            <div class="dashboard-card">
                <% if(behaviorCount > 0) { %>
                    <span class="notif-badge"><%= behaviorCount %></span>
                <% } %>
                <div class="card-icon">⭐</div>
                <h3>Behavior History</h3>
                <p>View teacher feedback & behavior logs</p>
                <a href="childBehavior.jsp" class="card-btn">View Logs</a>
            </div>
            
            <div class="dashboard-card">
                <div class="card-icon">🗓️</div>
                <h3>Exam Schedule</h3>
                <p>View upcoming exams & syllabus</p>
                <a href="viewExams.jsp" class="card-btn">View Exams</a>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">📊</div>
                <h3>View Marks</h3>
                <p>Check your child's subject-wise marks and performance</p>
                <a href="viewMarks.jsp" class="card-btn">View Marks</a>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">📄</div>
                <h3>Report Card</h3>
                <p>Download and view complete report card</p>
                <a href="viewReportCard.jsp" class="card-btn">View Report</a>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">📢</div>
                <h3>Notice Board</h3>
                <p>View important announcements and events</p>
                <a href="viewNotice.jsp" class="card-btn">View Notices</a>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">🎉</div>
                <h3>Events</h3>
                <p>Upcoming school events and activities</p>
                <a href="viewEvents.jsp" class="card-btn">View Events</a>
            </div>

            <div class="dashboard-card">
                <div class="card-icon">📝</div>
                <h3>Leave Requests</h3>
                <p>Authorize your child's leave requests (Parent Approval)</p>
                <a href="pendingLeaves.jsp" class="card-btn">View Requests</a>
            </div>

            <div class="dashboard-card">
                <% if(unreadCount > 0) { %>
                    <span class="notif-badge"><%= unreadCount %></span>
                <% } %>
                <div class="card-icon">🔔</div>
                <h3>Notifications</h3>
                <p>View alerts (leave, events, notices)</p>
                <a href="notifications.jsp" class="card-btn">View</a>
            </div>
        </div>
    </div>
</body>
</html>
