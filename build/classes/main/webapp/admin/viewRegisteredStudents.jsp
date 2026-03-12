<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
    
    String eventId = request.getParameter("eventId");
    if(eventId == null || eventId.isEmpty()) {
        response.sendRedirect("viewEventRegistrations.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Registered Students</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1100px;
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
        .event-info {
            background-color: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 5px solid #667eea;
        }
        .event-info h2 {
            margin: 0 0 15px 0;
            color: #667eea;
        }
        .event-detail {
            margin: 5px 0;
            color: #555;
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
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px;
            text-align: left;
            font-weight: bold;
        }
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .no-data {
            text-align: center;
            padding: 40px;
            color: #999;
            font-size: 18px;
        }
        .registration-date {
            font-size: 12px;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="container">
        <a href="viewEventRegistrations.jsp" class="back-btn">← Back to All Events</a>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> eventsCollection = database.getCollection("events");
                MongoCollection<Document> registrationsCollection = database.getCollection("eventRegistrations");
                MongoCollection<Document> studentsCollection = database.getCollection("students");
                
                // Get event details
                Document event = eventsCollection.find(new Document("eventId", eventId)).first();
                
                if(event == null) {
        %>
                    <div class="no-data">
                        ❌ Event not found!
                    </div>
        <%
                    return;
                }
                
                String eventName = event.getString("eventName");
                String eventType = event.getString("eventType");
                String eventDate = event.getString("eventDate");
                String eventTime = event.getString("eventTime");
                String eventLocation = event.getString("eventLocation");
        %>
        
        <h1>👥 Registered Students</h1>
        
        <div class="event-info">
            <h2> <%= eventName %></h2>
            <div class="event-detail"><strong>Event ID:</strong> <%= eventId %></div>
            <div class="event-detail"><strong>Type:</strong> <%= eventType %></div>
            <div class="event-detail"><strong>Date & Time:</strong> <%= eventDate %> at <%= eventTime %></div>
            <div class="event-detail"><strong>Location:</strong> <%= eventLocation %></div>
        </div>
        
        <%
                // Get all registrations for this event
                ArrayList<Document> registrationsList = registrationsCollection
                        .find(new Document("eventId", eventId))
                        .into(new ArrayList<>());
                
                if(registrationsList.isEmpty()) {
        %>
                    <div class="no-data">
                        📭 No students have registered for this event yet!
                    </div>
        <%
                } else {
        %>
                    <h3>Total Registered: <strong><%= registrationsList.size() %></strong> students</h3>
                    
                    <table>
                        <thead>
                            <tr>
                                <th>Sr. No.</th>
                                <th>Roll Number</th>
                                <th>Student Name</th>
                                <th>Class</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Registration Date</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int srNo = 1;
                                for(Document registration : registrationsList) {
                                    String rollNumber = registration.getString("rollNumber");
                                    String registrationDate = registration.getString("registrationDate");
                                    
                                    // Get student details
                                    Document student = studentsCollection.find(new Document("rollNumber", rollNumber)).first();
                                    
                                    if(student != null) {
                                        String fullName = student.getString("fullName");
                                        String className = student.getString("className");
                                        String section = student.getString("section");
                                        String email = student.getString("email");
                                        String phone = student.getString("phoneNumber");
                            %>
                            <tr>
                                <td><%= srNo++ %></td>
                                <td><strong><%= rollNumber %></strong></td>
                                <td><%= fullName %></td>
                                <td>Class <%= className %>-<%= section %></td>
                                <td><%= email %></td>
                                <td><%= phone %></td>
                                <td><span class="registration-date"><%= registrationDate %></span></td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
</body>
</html>
