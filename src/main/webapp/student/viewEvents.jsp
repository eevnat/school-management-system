<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("student")) {
        response.sendRedirect("studentLogin.jsp");
        return;
    }
    
    String rollNumber = (String) session.getAttribute("rollNumber");
    String studentName = (String) session.getAttribute("studentName");
    String studentClass = (String) session.getAttribute("studentClass");
%>
<!DOCTYPE html>
<html>
<head>
    <title>School Events</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1200px;
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
        }
        .student-info {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }
        .back-btn {
            padding: 10px 20px;
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 20px;
        }
        .events-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            margin-top: 30px;
        }
        .event-card {
            background-color: white;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            padding: 25px;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        .event-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0,0,0,0.15);
        }
        .event-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 15px;
        }
        .event-title {
            font-size: 20px;
            font-weight: bold;
            color: #333;
            margin: 0;
        }
        .event-type-badge {
            padding: 5px 12px;
            border-radius: 5px;
            font-size: 12px;
            font-weight: bold;
        }
        .type-sports { background-color: #e74c3c; color: white; }
        .type-cultural { background-color: #9b59b6; color: white; }
        .type-academic { background-color: #3498db; color: white; }
        .type-competition { background-color: #f39c12; color: white; }
        .type-workshop { background-color: #1abc9c; color: white; }
        .type-seminar { background-color: #34495e; color: white; }
        .type-festival { background-color: #e67e22; color: white; }
        .type-other { background-color: #95a5a6; color: white; }
        .event-description {
            color: #666;
            font-size: 14px;
            margin: 15px 0;
            line-height: 1.6;
        }
        .event-details {
            margin: 15px 0;
        }
        .event-detail-item {
            display: flex;
            margin: 8px 0;
            font-size: 14px;
        }
        .detail-icon {
            width: 25px;
            margin-right: 8px;
        }
        .detail-text {
            color: #555;
        }
        .register-btn {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 15px;
        }
        .register-btn:hover {
            opacity: 0.9;
        }
        .registered-btn {
            background: #27ae60;
            cursor: default;
        }
        .no-events {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }
        .status-closed {
            background-color: #95a5a6;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="studentDashboard.jsp" class="back-btn">← Back to Dashboard</a>
        
        <h1>🎉 School Events</h1>
        <div class="student-info">
            Welcome, <strong><%= studentName %></strong> | Class <%= studentClass %>
        </div>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> eventsCollection = database.getCollection("events");
                MongoCollection<Document> registrationsCollection = database.getCollection("eventRegistrations");
                
                // Get all active events
                ArrayList<Document> eventsList = eventsCollection
                        .find(new Document("status", "Active"))
                        .into(new ArrayList<>());
                
                if(eventsList.isEmpty()) {
        %>
                    <div class="no-events">
                        <h2>📭 No Events Available</h2>
                        <p>There are currently no events to display. Check back later!</p>
                    </div>
        <%
                } else {
        %>
                    <div class="events-grid">
        <%
                    for(Document event : eventsList) {
                        String eventId = event.getString("eventId");
                        String eventName = event.getString("eventName");
                        String eventType = event.getString("eventType");
                        String eventDescription = event.getString("eventDescription");
                        String eventDate = event.getString("eventDate");
                        String eventTime = event.getString("eventTime");
                        String eventLocation = event.getString("eventLocation");
                        String eligibility = event.getString("eligibility");
                        String maxParticipants = event.getString("maxParticipants");
                        String registrationDeadline = event.getString("registrationDeadline");
                        
                        // Check if student is eligible
                        boolean isEligible = eligibility.equals("All") || eligibility.contains(studentClass);
                        
                        // Check if student already registered
                        Document registration = registrationsCollection.find(
                            new Document("eventId", eventId).append("rollNumber", rollNumber)
                        ).first();
                        boolean isRegistered = (registration != null);
                        
                        String typeBadgeClass = "type-" + eventType.toLowerCase();
        %>
                        <div class="event-card">
                            <div class="event-header">
                                <h3 class="event-title"><%= eventName %></h3>
                                <span class="event-type-badge <%= typeBadgeClass %>"><%= eventType %></span>
                            </div>
                            
                            <p class="event-description"><%= eventDescription %></p>
                            
                            <div class="event-details">
                                <div class="event-detail-item">
                                    <span class="detail-icon">📅</span>
                                    <span class="detail-text"><strong>Date:</strong> <%= eventDate %></span>
                                </div>
                                <div class="event-detail-item">
                                    <span class="detail-icon">🕐</span>
                                    <span class="detail-text"><strong>Time:</strong> <%= eventTime %></span>
                                </div>
                                <div class="event-detail-item">
                                    <span class="detail-icon">📍</span>
                                    <span class="detail-text"><strong>Location:</strong> <%= eventLocation %></span>
                                </div>
                                <div class="event-detail-item">
                                    <span class="detail-icon">👥</span>
                                    <span class="detail-text"><strong>Max Capacity:</strong> <%= maxParticipants %></span>
                                </div>
                                <div class="event-detail-item">
                                    <span class="detail-icon">📚</span>
                                    <span class="detail-text"><strong>Eligible:</strong> <%= eligibility %></span>
                                </div>
                                <div class="event-detail-item">
                                    <span class="detail-icon">⏰</span>
                                    <span class="detail-text"><strong>Register by:</strong> <%= registrationDeadline %></span>
                                </div>
                            </div>
                            
                            <% if(isRegistered) { %>
                                <button class="register-btn registered-btn" disabled>✅ Already Registered</button>
                            <% } else if(!isEligible) { %>
                                <button class="register-btn status-closed" disabled>❌ Not Eligible</button>
                            <% } else { %>
                                <form action="../RegisterEventServlet" method="post">
                                    <input type="hidden" name="eventId" value="<%= eventId %>">
                                    <input type="hidden" name="rollNumber" value="<%= rollNumber %>">
                                    <button type="submit" class="register-btn">📝 Register Now</button>
                                </form>
                            <% } %>
                        </div>
        <%
                    }
        %>
                    </div>
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-events'>❌ Error loading events: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</body>
</html>
