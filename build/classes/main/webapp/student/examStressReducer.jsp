<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.*" %>
<%@ page import="com.student.util.MongoDBUtil" %>
<%@ page import="org.bson.Document" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.util.*" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    
    String studentClass = (String) session.getAttribute("studentClass");
    String studentSection = (String) session.getAttribute("studentSection");
    String rollNumber = (String) session.getAttribute("rollNumber");
    String studentName = (String) session.getAttribute("studentName");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exam Stress Reducer - Student Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
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
            background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
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
        
        .back-btn:hover {
            background: rgba(255,255,255,0.3);
        }
        
        .content {
            padding: 40px;
        }
        
        .motivation-banner {
            background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 30px;
        }
        
        .motivation-banner h2 {
            color: #333;
            margin-bottom: 10px;
            font-size: 24px;
        }
        
        .motivation-banner p {
            color: #555;
            font-size: 16px;
        }
        
        .calendar-countdown {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            border-radius: 20px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .calendar-countdown::before {
            content: '📅';
            position: absolute;
            font-size: 200px;
            opacity: 0.08;
            top: -40px;
            right: -40px;
        }
        
        .calendar-header {
            text-align: center;
            margin-bottom: 25px;
            position: relative;
            z-index: 1;
        }
        
        .calendar-header h3 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .exam-title {
            font-size: 18px;
            opacity: 0.95;
            margin-bottom: 5px;
        }
        
        .exam-date-display {
            font-size: 16px;
            opacity: 0.9;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 10px;
        }
        
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            max-width: 800px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }
        
        .calendar-box {
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(10px);
            padding: 25px 15px;
            border-radius: 15px;
            text-align: center;
            border: 2px solid rgba(255,255,255,0.2);
        }
        
        .calendar-number {
            font-size: 56px;
            font-weight: bold;
            display: block;
            line-height: 1;
            margin-bottom: 10px;
        }
        
        .calendar-label {
            font-size: 14px;
            opacity: 0.9;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
        }
        
        .all-subjects-section {
            margin-bottom: 30px;
        }
        
        .section-header {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 25px;
        }
        
        .section-header h3 {
            font-size: 22px;
            margin-bottom: 5px;
        }
        
        .section-header p {
            opacity: 0.9;
            font-size: 14px;
        }
        
        .syllabus-section {
            background: #f8f9fa;
            padding: 30px;
            border-radius: 15px;
            margin-bottom: 25px;
            border-left: 5px solid #667eea;
        }
        
        .syllabus-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
        }
        
        .syllabus-header h3 {
            color: #333;
            font-size: 22px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .subject-badge {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: bold;
        }
        
        .progress-stats {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .progress-card {
            background: white;
            padding: 20px;
            border-radius: 12px;
            text-align: center;
            border: 2px solid #e0e0e0;
        }
        
        .progress-card h4 {
            font-size: 32px;
            color: #667eea;
            margin-bottom: 5px;
        }
        
        .progress-card p {
            font-size: 14px;
            color: #666;
        }
        
        .subject-checklist {
            background: white;
            border-radius: 15px;
            padding: 25px;
            border: 2px solid #e0e0e0;
        }
        
        .subject-title {
            font-size: 20px;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 2px solid #f0f0f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .subject-progress {
            font-size: 14px;
            color: #667eea;
            font-weight: 600;
        }
        
        .topic-item {
            display: flex;
            align-items: center;
            gap: 15px;
            padding: 15px;
            border-bottom: 1px solid #f0f0f0;
            transition: all 0.3s;
        }
        
        .topic-item:hover {
            background: #f8f9fa;
            padding-left: 20px;
        }
        
        .topic-item:last-child {
            border-bottom: none;
        }
        
        .topic-checkbox {
            width: 24px;
            height: 24px;
            cursor: pointer;
            accent-color: #10b981;
        }
        
        .topic-label {
            flex: 1;
            color: #333;
            font-size: 15px;
            cursor: pointer;
        }
        
        .topic-item.completed .topic-label {
            text-decoration: line-through;
            color: #999;
        }
        
        .tips-section {
            background: #d1fae5;
            border-left: 5px solid #10b981;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
        }
        
        .tips-section h3 {
            color: #065f46;
            margin-bottom: 15px;
            font-size: 20px;
        }
        
        .tip-item {
            background: white;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 10px;
            display: flex;
            align-items: start;
            gap: 10px;
        }
        
        .tip-item i {
            color: #10b981;
            font-size: 18px;
            margin-top: 2px;
        }
        
        .no-exam-msg {
            text-align: center;
            padding: 60px 20px;
            color: #6b7280;
        }
        
        .no-exam-msg i {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.3;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1><i class="fas fa-brain"></i> Exam Stress Reducer</h1>
        <a href="studentDashboard.jsp" class="back-btn">
            <i class="fas fa-arrow-left"></i> Back
        </a>
    </div>
    
    <div class="content">
        <!-- Motivation Banner -->
        <div class="motivation-banner">
            <h2>🌟 You've Got This, <%= studentName %>!</h2>
            <p>Stay calm, stay focused, and prepare smartly. Success is within your reach!</p>
        </div>
        
        <%
            try {
                MongoDatabase db = MongoDBUtil.getDatabase();
                MongoCollection<Document> col = db.getCollection("exams");

                // Filter exams for student's class OR "All"
                Document filter = new Document("$or", java.util.Arrays.asList(
                    new Document("class", studentClass),
                    new Document("class", "All")
                ));

                // Find nearest upcoming exam and collect ALL subjects from that exam
                LocalDate today = LocalDate.now();
                Document nearestExamDoc = null;
                LocalDate nearestExamStartDate = null;
                long minDays = Long.MAX_VALUE;
                DateTimeFormatter inputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

                // First, find the exam with the nearest starting date
                for(Document examDoc : col.find(filter)) {
                    List<Document> schedule = (List<Document>) examDoc.get("schedule");
                    
                    if(schedule != null && !schedule.isEmpty()) {
                        // Find the earliest date in this exam's schedule
                        LocalDate earliestDate = null;
                        for(Document scheduleItem : schedule) {
                            String dateStr = scheduleItem.getString("date");
                            if(dateStr != null) {
                                try {
                                    LocalDate examDate = LocalDate.parse(dateStr, inputFormatter);
                                    if(!examDate.isBefore(today)) {
                                        if(earliestDate == null || examDate.isBefore(earliestDate)) {
                                            earliestDate = examDate;
                                        }
                                    }
                                } catch(Exception e) {
                                    // Skip invalid dates
                                }
                            }
                        }
                        
                        // Check if this exam has the nearest start date
                        if(earliestDate != null) {
                            long daysUntil = ChronoUnit.DAYS.between(today, earliestDate);
                            if(daysUntil < minDays) {
                                minDays = daysUntil;
                                nearestExamStartDate = earliestDate;
                                nearestExamDoc = examDoc;
                            }
                        }
                    }
                }
                
                if (nearestExamDoc == null) {
        %>
                    <div class="no-exam-msg">
                        <i class="fas fa-calendar-check"></i>
                        <h2>🎉 No Upcoming Exams!</h2>
                        <p>Enjoy your stress-free days. Use this time to review past concepts and stay ahead!</p>
                    </div>
        <%
                } else {
                    // Extract exam details
                    String examTitle = nearestExamDoc.getString("title");
                    String category = nearestExamDoc.getString("category");
                    
                    // Get ALL subjects from the entire exam schedule (all dates)
                    List<Document> allSubjectsInExam = new ArrayList<>();
                    List<Document> schedule = (List<Document>) nearestExamDoc.get("schedule");
                    
                    String firstTime = null;
                    LocalDate firstExamDate = null;
                    
                    if(schedule != null) {
                        // Add ALL schedule items, regardless of date
                        for(Document scheduleItem : schedule) {
                            String dateStr = scheduleItem.getString("date");
                            try {
                                LocalDate examDate = LocalDate.parse(dateStr, inputFormatter);
                                if(!examDate.isBefore(today)) {
                                    allSubjectsInExam.add(scheduleItem);
                                    
                                    // Track the first/earliest exam date and time
                                    if(firstExamDate == null || examDate.isBefore(firstExamDate)) {
                                        firstExamDate = examDate;
                                        firstTime = scheduleItem.getString("time");
                                    }
                                }
                            } catch(Exception e) {
                                // Skip invalid dates
                            }
                        }
                    }
                    
                    // Use the earliest exam date for countdown
                    if(firstExamDate == null) {
                        firstExamDate = nearestExamStartDate;
                    }
                    
                    long daysLeft = ChronoUnit.DAYS.between(today, firstExamDate);
                    
                    DateTimeFormatter outputFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy");
                    String formattedStartDate = firstExamDate.format(outputFormatter);
        %>
        
        <!-- Calendar-Style Countdown -->
        <div class="calendar-countdown">
            <div class="calendar-header">
                <h3>⏰ Next Exam Countdown</h3>
                <div class="exam-title">
                    <strong><%= examTitle %></strong> (<%= category %>)<br>
                    <span style="font-size: 14px;"><%= allSubjectsInExam.size() %> Subject(s) in this exam</span>
                </div>
                <div class="exam-date-display">
                    <i class="fas fa-calendar-alt"></i>
                    Starts on <%= formattedStartDate %><%= firstTime != null ? " at " + firstTime : "" %>
                </div>
            </div>
            
            <div class="calendar-grid">
                <div class="calendar-box">
                    <span class="calendar-number" id="days"><%= daysLeft %></span>
                    <span class="calendar-label">Days</span>
                </div>
                <div class="calendar-box">
                    <span class="calendar-number" id="hours">00</span>
                    <span class="calendar-label">Hours</span>
                </div>
                <div class="calendar-box">
                    <span class="calendar-number" id="minutes">00</span>
                    <span class="calendar-label">Minutes</span>
                </div>
                <div class="calendar-box">
                    <span class="calendar-number" id="seconds">00</span>
                    <span class="calendar-label">Seconds</span>
                </div>
            </div>
        </div>
        
        <!-- All Subjects Section -->
        <div class="all-subjects-section">
            <div class="section-header">
                <h3>📚 Complete Exam Timetable & Syllabus Tracker</h3>
                <p>All subjects scheduled for this exam - Check off topics as you complete them</p>
            </div>
            
            <%
                // Sort subjects by date and time
                Collections.sort(allSubjectsInExam, new Comparator<Document>() {
                    public int compare(Document d1, Document d2) {
                        try {
                            LocalDate date1 = LocalDate.parse(d1.getString("date"), inputFormatter);
                            LocalDate date2 = LocalDate.parse(d2.getString("date"), inputFormatter);
                            int dateCompare = date1.compareTo(date2);
                            if(dateCompare != 0) return dateCompare;
                            
                            String time1 = d1.getString("time");
                            String time2 = d2.getString("time");
                            if(time1 != null && time2 != null) {
                                return time1.compareTo(time2);
                            }
                            return 0;
                        } catch(Exception e) {
                            return 0;
                        }
                    }
                });
                
                // Loop through all subjects in the exam
                for(int subIdx = 0; subIdx < allSubjectsInExam.size(); subIdx++) {
                    Document scheduleItem = allSubjectsInExam.get(subIdx);
                    
                    String subject = scheduleItem.getString("subject");
                    String code = scheduleItem.getString("code");
                    String timeStr = scheduleItem.getString("time");
                    String dateStr = scheduleItem.getString("date");
                    String syllabusText = scheduleItem.getString("syllabus");
                    
                    // Format the date
                    String displayDate = "";
                    try {
                        LocalDate examDate = LocalDate.parse(dateStr, inputFormatter);
                        displayDate = examDate.format(outputFormatter);
                    } catch(Exception e) {
                        displayDate = dateStr;
                    }
                    
                    // Convert syllabus text to list
                    List<String> syllabusList = new ArrayList<>();
                    if(syllabusText != null && !syllabusText.trim().isEmpty()) {
                        String[] lines = syllabusText.split("\\r?\\n");
                        for(String line : lines) {
                            line = line.trim();
                            if(!line.isEmpty()) {
                                if(line.contains(",")) {
                                    String[] parts = line.split(",");
                                    for(String part : parts) {
                                        part = part.trim();
                                        if(!part.isEmpty()) {
                                            syllabusList.add(part);
                                        }
                                    }
                                } else {
                                    syllabusList.add(line);
                                }
                            }
                        }
                    }
            %>
            
            <div class="syllabus-section">
                <div class="syllabus-header">
                    <h3>
                        <i class="fas fa-book"></i> 
                        <%= subject %><%= code != null ? " (" + code + ")" : "" %>
                    </h3>
                    <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                        <span class="subject-badge">📅 <%= displayDate %></span>
                        <span class="subject-badge">⏰ <%= timeStr != null ? timeStr : "TBA" %></span>
                    </div>
                </div>
                
                <% if (!syllabusList.isEmpty()) { %>
                <div class="progress-stats">
                    <div class="progress-card">
                        <h4 id="totalTopics_<%= subIdx %>"><%= syllabusList.size() %></h4>
                        <p>Total Topics</p>
                    </div>
                    <div class="progress-card">
                        <h4 id="completedTopics_<%= subIdx %>">0</h4>
                        <p>Completed ✅</p>
                    </div>
                    <div class="progress-card">
                        <h4 id="pendingTopics_<%= subIdx %>"><%= syllabusList.size() %></h4>
                        <p>Pending ⏳</p>
                    </div>
                    <div class="progress-card">
                        <h4 id="completionPercent_<%= subIdx %>">0%</h4>
                        <p>Progress</p>
                    </div>
                </div>
                
                <div class="subject-checklist">
                    <div class="subject-title">
                        <span>Syllabus Checklist</span>
                        <span class="subject-progress" id="subjectProgress_<%= subIdx %>">0/<%= syllabusList.size() %> Done</span>
                    </div>
                    
                    <%
                        for (int i = 0; i < syllabusList.size(); i++) {
                            String topic = syllabusList.get(i);
                    %>
                    <div class="topic-item" id="topic_<%= subIdx %>_<%= i %>">
                        <input type="checkbox" class="topic-checkbox" id="check_<%= subIdx %>_<%= i %>" 
                               data-subject="<%= subIdx %>" onchange="updateProgress(<%= subIdx %>)">
                        <label class="topic-label" for="check_<%= subIdx %>_<%= i %>"><%= topic %></label>
                    </div>
                    <%
                        }
                    %>
                </div>
                <% } else { %>
                <div style="background: #fff3cd; padding: 20px; border-radius: 10px; text-align: center;">
                    <p style="color: #856404; font-size: 16px;">📝 No detailed syllabus available for this subject</p>
                </div>
                <% } %>
            </div>
            
            <%
                }
            %>
        </div>
        
        <!-- Study Tips -->
        <div class="tips-section">
            <h3><i class="fas fa-lightbulb"></i> Smart Study Tips</h3>
            
            <div class="tip-item">
                <i class="fas fa-clock"></i>
                <p><strong>Study in intervals:</strong> Use the Pomodoro technique - 25 mins study, 5 mins break</p>
            </div>
            
            <div class="tip-item">
                <i class="fas fa-bed"></i>
                <p><strong>Get proper sleep:</strong> 7-8 hours of sleep improves memory retention by 40%</p>
            </div>
            
            <div class="tip-item">
                <i class="fas fa-apple-alt"></i>
                <p><strong>Eat brain foods:</strong> Nuts, fruits, and plenty of water keep your mind sharp</p>
            </div>
            
            <div class="tip-item">
                <i class="fas fa-repeat"></i>
                <p><strong>Revise regularly:</strong> Review topics multiple times instead of cramming at the last minute</p>
            </div>
            
            <div class="tip-item">
                <i class="fas fa-users"></i>
                <p><strong>Group study:</strong> Discuss difficult topics with friends to understand better</p>
            </div>
        </div>

<script>
    // FIXED Countdown Timer
    const examDateStr = '<%= firstExamDate.toString() %>';
    const examTimeStr = '<%= firstTime != null ? firstTime : "09:00 AM" %>';
    
    // Convert time format "11:00 AM" to 24-hour format
    function convertTo24Hour(time12h) {
        if (!time12h) return '09:00';
        
        const parts = time12h.trim().split(' ');
        if(parts.length < 2) return '09:00';
        
        const [time, modifier] = parts;
        let [hours, minutes] = time.split(':');
        
        hours = parseInt(hours, 10);
        
        if (modifier.toUpperCase() === 'PM' && hours !== 12) {
            hours = hours + 12;
        } else if (modifier.toUpperCase() === 'AM' && hours === 12) {
            hours = 0;
        }
        
        return hours.toString().padStart(2, '0') + ':' + minutes;
    }
    
    const time24 = convertTo24Hour(examTimeStr);
    const examDateTime = new Date(examDateStr + 'T' + time24 + ':00');
    
    function updateCountdown() {
        const now = new Date().getTime();
        const distance = examDateTime.getTime() - now;
        
        const days = Math.floor(distance / (1000 * 60 * 60 * 24));
        const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((distance % (1000 * 60)) / 1000);
        
        document.getElementById('days').textContent = days >= 0 ? days : 0;
        document.getElementById('hours').textContent = hours >= 0 ? hours.toString().padStart(2, '0') : '00';
        document.getElementById('minutes').textContent = minutes >= 0 ? minutes.toString().padStart(2, '0') : '00';
        document.getElementById('seconds').textContent = seconds >= 0 ? seconds.toString().padStart(2, '0') : '00';
        
        if (distance < 0) {
            clearInterval(timer);
            document.getElementById('days').textContent = '0';
            document.getElementById('hours').textContent = '00';
            document.getElementById('minutes').textContent = '00';
            document.getElementById('seconds').textContent = '00';
        }
    }
    
    const timer = setInterval(updateCountdown, 1000);
    updateCountdown();
    
    // Progress Tracker for each subject
    function updateProgress(subjectIndex) {
        const checkboxes = document.querySelectorAll(`input[data-subject="${subjectIndex}"]`);
        const total = checkboxes.length;
        let completed = 0;
        
        checkboxes.forEach((checkbox, index) => {
            const topicItem = document.getElementById(`topic_${subjectIndex}_${index}`);
            if (checkbox.checked) {
                completed++;
                if(topicItem) topicItem.classList.add('completed');
            } else {
                if(topicItem) topicItem.classList.remove('completed');
            }
        });
        
        const pending = total - completed;
        const percentage = total > 0 ? Math.round((completed / total) * 100) : 0;
        
        const completedEl = document.getElementById(`completedTopics_${subjectIndex}`);
        const pendingEl = document.getElementById(`pendingTopics_${subjectIndex}`);
        const percentEl = document.getElementById(`completionPercent_${subjectIndex}`);
        const progressEl = document.getElementById(`subjectProgress_${subjectIndex}`);
        
        if(completedEl) completedEl.textContent = completed;
        if(pendingEl) pendingEl.textContent = pending;
        if(percentEl) percentEl.textContent = percentage + '%';
        if(progressEl) progressEl.textContent = completed + '/' + total + ' Done';
        
        // Save to localStorage
        const checkedState = Array.from(checkboxes).map(cb => cb.checked);
        localStorage.setItem(`examChecklist_<%= examTitle %>_subject_${subjectIndex}`, JSON.stringify(checkedState));
    }
    
    // Load saved progress for all subjects
    window.addEventListener('load', function() {
        <%
            for(int subIdx = 0; subIdx < allSubjectsInExam.size(); subIdx++) {
        %>
        const saved_<%= subIdx %> = localStorage.getItem('examChecklist_<%= examTitle %>_subject_<%= subIdx %>');
        if (saved_<%= subIdx %>) {
            try {
                const checkedState = JSON.parse(saved_<%= subIdx %>);
                const checkboxes = document.querySelectorAll(`input[data-subject="<%= subIdx %>"]`);
                checkboxes.forEach((checkbox, index) => {
                    if (checkedState[index]) {
                        checkbox.checked = true;
                    }
                });
                updateProgress(<%= subIdx %>);
            } catch(e) {
                console.error('Error loading saved progress:', e);
            }
        }
        <%
            }
        %>
    });
</script>

        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-exam-msg'>❌ Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</div>

</body>
</html>
