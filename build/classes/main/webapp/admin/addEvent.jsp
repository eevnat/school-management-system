<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add Event</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
        }
        h1 {
            color: #333;
            text-align: center;
            margin-bottom: 30px;
        }
        .success-msg {
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .error-msg {
            background-color: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            text-align: center;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
        }
        input[type="text"],
        input[type="date"],
        input[type="time"],
        select,
        textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }
        input:focus, select:focus, textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        textarea {
            resize: vertical;
            min-height: 100px;
        }
        .form-row {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        .btn-container {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            font-weight: bold;
            text-decoration: none;
            display: inline-block;
        }
        .btn-submit {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-back {
            background-color: #95a5a6;
            color: white;
        }
        .info-box {
            background-color: #e3f2fd;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
            border-left: 4px solid #2196F3;
        }
        .event-icon {
            font-size: 50px;
            text-align: center;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="event-icon"></div>
        <h1>Create New Event</h1>
        
        <% 
            String success = request.getParameter("success");
            if(success != null && success.equals("1")) {
        %>
            <div class="success-msg">✅ Event created successfully!</div>
        <% } %>
        
        <% 
            String error = request.getParameter("error");
            if(error != null) {
        %>
            <div class="error-msg">❌ Failed to create event. Please try again!</div>
        <% } %>
        
        <div class="info-box">
            ℹ️ <strong>Note:</strong> Create events for students to register. Events will be visible to all students.
        </div>
        
        <form action="../AddEventServlet" method="post">
            <div class="form-group">
                <label>Event Name: *</label>
                <input type="text" name="eventName" placeholder="e.g., Annual Sports Day" required>
            </div>
            
            <div class="form-group">
                <label>Event Type: *</label>
                <select name="eventType" required>
                    <option value="">-- Select Event Type --</option>
                    <option value="Sports">🏃 Sports Event</option>
                    <option value="Cultural">🎭 Cultural Event</option>
                    <option value="Academic">📚 Academic Event</option>
                    <option value="Competition">🏆 Competition</option>
                    <option value="Workshop">🛠️ Workshop</option>
                    <option value="Seminar">💼 Seminar</option>
                    <option value="Festival">🎊 Festival Celebration</option>
                    <option value="Other">📌 Other</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Event Description: *</label>
                <textarea name="eventDescription" placeholder="Describe the event details..." required></textarea>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label>Event Date: *</label>
                    <input type="date" name="eventDate" required>
                </div>
                
                <div class="form-group">
                    <label>Event Time: *</label>
                    <input type="time" name="eventTime" required>
                </div>
            </div>
            
            <div class="form-group">
                <label>Location/Venue: *</label>
                <input type="text" name="eventLocation" placeholder="e.g., School Ground, Auditorium" required>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label>Maximum Participants:</label>
                    <input type="text" name="maxParticipants" placeholder="e.g., 100 (Leave blank for unlimited)">
                </div>
                
                <div class="form-group">
                    <label>Registration Deadline: *</label>
                    <input type="date" name="registrationDeadline" required>
                </div>
            </div>
            
            <div class="form-group">
                <label>Eligibility (Classes): *</label>
                <select name="eligibility" required>
                    <option value="">-- Select --</option>
                    <option value="All">All Classes</option>
                    <option value="10">Class 10 Only</option>
                    <option value="11">Class 11 Only</option>
                    <option value="12">Class 12 Only</option>
                    <option value="10,11">Class 10 & 11</option>
                    <option value="11,12">Class 11 & 12</option>
                </select>
            </div>
            
            <div class="form-group">
                <label>Contact Person:</label>
                <input type="text" name="contactPerson" placeholder="e.g., Mr. John (Optional)">
            </div>
            
            <div class="btn-container">
                <button type="submit" class="btn btn-submit">Create Event</button>
                <a href="adminDashboard.jsp" class="btn btn-back">← Back to Dashboard</a>
            </div>
        </form>
    </div>
</body>
</html>
