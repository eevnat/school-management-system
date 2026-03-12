<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.util.*" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    
    String studentId = (String) session.getAttribute("studentId");
    String rollNumber = (String) session.getAttribute("rollNumber");
    String studentName = (String) session.getAttribute("studentName");
    String studentClass = (String) session.getAttribute("studentClass");
    String studentSection = (String) session.getAttribute("studentSection");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Academic Dashboard - Student Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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
        
        .welcome-section {
            background: linear-gradient(135deg, #e0c3fc 0%, #8ec5fc 100%);
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 30px;
            text-align: center;
        }
        
        .welcome-section h2 {
            color: #333;
            margin-bottom: 10px;
        }
        
        .welcome-section p {
            color: #555;
            font-size: 14px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            padding: 25px;
            border-radius: 15px;
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .stat-card::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: rgba(255,255,255,0.1);
            transform: rotate(45deg);
        }
        
        .stat-card.overall {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        
        .stat-card.attendance {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        
        .stat-card.rank {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        
        .stat-card h3 {
            font-size: 42px;
            margin-bottom: 5px;
            position: relative;
            z-index: 1;
        }
        
        .stat-card p {
            opacity: 0.9;
            font-size: 14px;
            position: relative;
            z-index: 1;
        }
        
        .chart-section {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .chart-section h3 {
            color: #333;
            margin-bottom: 20px;
            font-size: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .chart-container {
            position: relative;
            height: 350px;
        }
        
        .suggestions-section {
            background: #fff3cd;
            border-left: 5px solid #ffc107;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 30px;
        }
        
        .suggestions-section h3 {
            color: #856404;
            margin-bottom: 15px;
            font-size: 20px;
        }
        
        .suggestion-item {
            background: white;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 10px;
            display: flex;
            align-items: start;
            gap: 10px;
        }
        
        .suggestion-item i {
            color: #ffc107;
            font-size: 20px;
            margin-top: 2px;
        }
        
        .suggestion-item p {
            color: #333;
            line-height: 1.5;
        }
        
        .performance-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .subject-card {
            background: white;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s;
        }
        
        .subject-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.1);
        }
        
        .subject-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .subject-name {
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }
        
        .subject-score {
            font-size: 28px;
            font-weight: bold;
            color: #667eea;
        }
        
        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 10px;
        }
        
        .progress-fill {
            height: 100%;
            border-radius: 10px;
            transition: width 0.5s ease;
        }
        
        .progress-fill.excellent {
            background: linear-gradient(90deg, #10b981, #059669);
        }
        
        .progress-fill.good {
            background: linear-gradient(90deg, #3b82f6, #2563eb);
        }
        
        .progress-fill.average {
            background: linear-gradient(90deg, #f59e0b, #d97706);
        }
        
        .progress-fill.poor {
            background: linear-gradient(90deg, #ef4444, #dc2626);
        }
        
        .subject-status {
            font-size: 12px;
            font-weight: 600;
            color: #666;
        }
        
        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        
        .no-data i {
            font-size: 64px;
            opacity: 0.3;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-chart-line"></i> My Academic Dashboard</h1>
        <a href="studentDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <div class="welcome-section">
            <h2>📊 Welcome, <%= studentName %>!</h2>
            <p>Track your academic progress and get personalized insights</p>
        </div>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> marksCollection = database.getCollection("marks");
                MongoCollection<Document> attendanceCollection = database.getCollection("attendance");
                
                // EXACT SAME LOGIC as viewMarks.jsp - Fetch ONE document
                Document marks = marksCollection.find(new Document("rollNumber", rollNumber)).first();
                
                if(marks == null) {
        %>
                    <div class="no-data">
                        <i class="fas fa-chart-bar"></i>
                        <h2>📭 Marks Not Added Yet!</h2>
                        <p>Your marks haven't been uploaded by the admin yet. Please check back later.</p>
                    </div>
        <%
                } else {
                    // Extract marks from the document (SAME as viewMarks.jsp)
                    int math = marks.getInteger("mathematics", 0);
                    int science = marks.getInteger("science", 0);
                    int english = marks.getInteger("english", 0);
                    int social = marks.getInteger("socialStudies", 0);
                    int hindi = marks.getInteger("hindi", 0);
                    int computer = marks.getInteger("computerScience", 0);
                    int total = marks.getInteger("totalMarks", 0);
                    double percentage = marks.getDouble("percentage") != null ? marks.getDouble("percentage") : 0.0;
                    String grade = marks.getString("grade");
                    
                    // Build subject marks map for chart
                    Map<String, Integer> subjectMarks = new LinkedHashMap<>();
                    subjectMarks.put("Mathematics", math);
                    subjectMarks.put("Science", science);
                    subjectMarks.put("English", english);
                    subjectMarks.put("Social Studies", social);
                    subjectMarks.put("Hindi", hindi);
                    subjectMarks.put("Computer Science", computer);
                    
                    // Calculate attendance
                    int presentCount = 0;
                    int totalDays = 0;
                    
                    Document attendanceQuery = studentId != null && !studentId.isEmpty() ? 
                        new Document("studentId", studentId) : new Document("rollNumber", rollNumber);
                    
                    for (Document attendance : attendanceCollection.find(attendanceQuery)) {
                        totalDays++;
                        String status = attendance.getString("status");
                        if ("PRESENT".equals(status) || "LATE".equals(status)) {
                            presentCount++;
                        }
                    }
                    
                    double attendancePercentage = totalDays > 0 ? (double)presentCount / totalDays * 100 : 0;
                    
                    // Calculate rank
                    int rank = 1;
                    MongoCollection<Document> studentCollection = database.getCollection("students");
                    
                    for (Document student : studentCollection.find(new Document("className", studentClass).append("section", studentSection))) {
                        String otherRoll = student.getString("rollNumber");
                        if (otherRoll != null && !otherRoll.equals(rollNumber)) {
                            Document otherMarks = marksCollection.find(new Document("rollNumber", otherRoll)).first();
                            if (otherMarks != null) {
                                Double otherPercentage = otherMarks.getDouble("percentage");
                                if (otherPercentage != null && otherPercentage > percentage) {
                                    rank++;
                                }
                            }
                        }
                    }
        %>
        
        <div class="stats-grid">
            <div class="stat-card overall">
                <h3><%= String.format("%.1f", percentage) %>%</h3>
                <p>Overall Performance</p>
            </div>
            <div class="stat-card attendance">
                <h3><%= String.format("%.1f", attendancePercentage) %>%</h3>
                <p>Attendance Rate</p>
            </div>
            <div class="stat-card rank">
                <h3>#<%= rank %></h3>
                <p>Class Rank</p>
            </div>
        </div>
        
        <!-- Subject-wise Performance Chart -->
        <div class="chart-section">
            <h3><i class="fas fa-chart-bar"></i> Subject-wise Performance</h3>
            <div class="chart-container">
                <canvas id="performanceChart"></canvas>
            </div>
        </div>
        
        <!-- Detailed Subject Cards -->
        <div class="performance-grid">
            <%
                for (Map.Entry<String, Integer> entry : subjectMarks.entrySet()) {
                    String subject = entry.getKey();
                    int marksObtained = entry.getValue();
                    double subjectPercentage = marksObtained;
                    
                    String progressClass = subjectPercentage >= 85 ? "excellent" : 
                                         subjectPercentage >= 70 ? "good" : 
                                         subjectPercentage >= 50 ? "average" : "poor";
                    
                    String statusText = subjectPercentage >= 85 ? "Excellent! Keep it up!" : 
                                       subjectPercentage >= 70 ? "Good performance" : 
                                       subjectPercentage >= 50 ? "Need improvement" : "Focus required";
            %>
            <div class="subject-card">
                <div class="subject-header">
                    <span class="subject-name"><%= subject %></span>
                    <span class="subject-score"><%= marksObtained %>/100</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill <%= progressClass %>" style="width: <%= subjectPercentage %>%"></div>
                </div>
                <div class="subject-status"><%= statusText %></div>
            </div>
            <%
                }
            %>
        </div>
        
        <!-- AI-Powered Suggestions -->
        <div class="suggestions-section">
            <h3><i class="fas fa-lightbulb"></i> Personalized Improvement Suggestions</h3>
            
            <%
                List<String> suggestions = new ArrayList<>();
                
                // Rule 1: Low attendance
                if (attendancePercentage < 75 && totalDays > 0) {
                    suggestions.add("Your attendance is below 75%. Regular attendance improves understanding and grades significantly!");
                }
                
                // Rule 2: Overall performance
                if (percentage < 50) {
                    suggestions.add("Focus on improving your overall performance. Consider spending 2 extra hours daily on weak subjects.");
                } else if (percentage < 70) {
                    suggestions.add("You're doing okay! Push harder to reach above 70% for better opportunities.");
                } else if (percentage >= 85) {
                    suggestions.add("Outstanding performance! Maintain consistency and help classmates who need support.");
                }
                
                // Rule 3: Subject-specific
                for (Map.Entry<String, Integer> entry : subjectMarks.entrySet()) {
                    if (entry.getValue() < 50) {
                        suggestions.add("Focus more on " + entry.getKey() + ". Consider extra practice and asking teachers for help.");
                    }
                }
                
                // Rule 4: Rank-based
                if (rank <= 3) {
                    suggestions.add("You're in the top 3! Aim to maintain this position and inspire others.");
                } else if (rank <= 10) {
                    suggestions.add("Great job being in top 10! A little more effort can get you to top 3.");
                }
                
                // Default suggestion
                if (suggestions.isEmpty()) {
                    suggestions.add("Keep up the consistent performance! Balance studies with extracurricular activities.");
                }
                
                for (String suggestion : suggestions) {
            %>
            <div class="suggestion-item">
                <i class="fas fa-star"></i>
                <p><%= suggestion %></p>
            </div>
            <%
                }
            %>
        </div>

<script>
    // Create REALISTIC performance chart
    const ctx = document.getElementById('performanceChart');
    const chartCtx = ctx.getContext('2d');
    
    // Build arrays from JSP data
    const subjects = [];
    const marks = [];
    
    <%
        for (Map.Entry<String, Integer> entry : subjectMarks.entrySet()) {
    %>
        subjects.push('<%= entry.getKey() %>');
        marks.push(<%= entry.getValue() %>);
    <%
        }
    %>
    
    // Create gradient colors for bars
    const backgroundColors = subjects.map((_, index) => {
        const colors = [
            ['rgba(102, 126, 234, 0.85)', 'rgba(102, 126, 234, 0.4)'],
            ['rgba(240, 147, 251, 0.85)', 'rgba(240, 147, 251, 0.4)'],
            ['rgba(79, 172, 254, 0.85)', 'rgba(79, 172, 254, 0.4)'],
            ['rgba(16, 185, 129, 0.85)', 'rgba(16, 185, 129, 0.4)'],
            ['rgba(245, 158, 11, 0.85)', 'rgba(245, 158, 11, 0.4)'],
            ['rgba(239, 68, 68, 0.85)', 'rgba(239, 68, 68, 0.4)']
        ];
        const gradient = chartCtx.createLinearGradient(0, 0, 0, 350);
        const colorPair = colors[index % colors.length];
        gradient.addColorStop(0, colorPair[0]);
        gradient.addColorStop(1, colorPair[1]);
        return gradient;
    });
    
    new Chart(chartCtx, {
        type: 'bar',
        data: {
            labels: subjects,
            datasets: [{
                label: 'Marks Scored',
                data: marks,
                backgroundColor: backgroundColors,
                borderColor: [
                    'rgb(102, 126, 234)',
                    'rgb(240, 147, 251)',
                    'rgb(79, 172, 254)',
                    'rgb(16, 185, 129)',
                    'rgb(245, 158, 11)',
                    'rgb(239, 68, 68)'
                ],
                borderWidth: 3,
                borderRadius: 12,
                barThickness: 65
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top',
                    labels: {
                        font: { size: 14, weight: 'bold' },
                        color: '#333',
                        padding: 15,
                        usePointStyle: true,
                        pointStyle: 'rectRounded'
                    }
                },
                tooltip: {
                    backgroundColor: 'rgba(0, 0, 0, 0.9)',
                    padding: 16,
                    titleFont: { size: 16, weight: 'bold' },
                    bodyFont: { size: 14 },
                    borderColor: 'rgba(255, 255, 255, 0.2)',
                    borderWidth: 1,
                    displayColors: true,
                    callbacks: {
                        title: function(context) {
                            return '📚 ' + context[0].label;
                        },
                        label: function(context) {
                            const score = context.parsed.y;
                            return [
                                'Score: ' + score + ' / 100',
                                'Percentage: ' + score + '%'
                            ];
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    max: 100,
                    title: {
                        display: true,
                        text: '📊 Marks Obtained (out of 100)',
                        font: { size: 14, weight: 'bold' },
                        color: '#333',
                        padding: 12
                    },
                    ticks: {
                        stepSize: 10,
                        font: { size: 12 },
                        color: '#555'
                    },
                    grid: {
                        color: 'rgba(0, 0, 0, 0.08)',
                        borderDash: [5, 5]
                    }
                },
                x: {
                    title: {
                        display: true,
                        text: '📖 Subjects',
                        font: { size: 14, weight: 'bold' },
                        color: '#333',
                        padding: 12
                    },
                    ticks: {
                        font: { size: 13, weight: '600' },
                        color: '#333'
                    },
                    grid: {
                        display: false
                    }
                }
            },
            animation: {
                duration: 1800,
                easing: 'easeInOutCubic'
            }
        }
    });
</script>

        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</div>

</body>
</html>
