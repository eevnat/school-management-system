<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.mongodb.client.MongoCollection, com.mongodb.client.MongoDatabase, com.student.util.MongoDBUtil, org.bson.Document, java.util.ArrayList" %>
<%
    if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Event Registrations</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            min-height: 100vh;
        }
        .container {
            max-width: 1300px;
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
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .back-btn {
            padding: 10px 20px;
            background-color: #95a5a6;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        .search-box {
            margin-bottom: 20px;
            text-align: center;
        }
        .search-box input {
            width: 50%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            margin-top: 8px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 15px 10px;
            text-align: left;
            font-weight: bold;
            font-size: 14px;
        }
        td {
            padding: 12px 10px;
            border-bottom: 1px solid #ddd;
            font-size: 13px;
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
        .event-type-badge {
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 11px;
            font-weight: bold;
            display: inline-block;
        }
        .type-sports { background-color: #e74c3c; color: white; }
        .type-cultural { background-color: #9b59b6; color: white; }
        .type-academic { background-color: #3498db; color: white; }
        .type-competition { background-color: #f39c12; color: white; }
        .type-workshop { background-color: #1abc9c; color: white; }
        .type-seminar { background-color: #34495e; color: white; }
        .type-festival { background-color: #e67e22; color: white; }
        .type-other { background-color: #95a5a6; color: white; }
        .view-btn {
            padding: 6px 15px;
            background-color: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
            display: inline-block;
        }
        .view-btn:hover {
            background-color: #2980b9;
        }
        .registration-count {
            font-weight: bold;
            color: #27ae60;
        }
        .status-badge {
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 11px;
            font-weight: bold;
        }
        .status-active { background-color: #d4edda; color: #155724; }
        .status-closed { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📋 Event Registrations Overview</h1>
            <a href="adminDashboard.jsp" class="back-btn">← Back to Dashboard</a>
        </div>
        
        <%
            try {
                MongoDatabase database = MongoDBUtil.getDatabase();
                MongoCollection<Document> eventsCollection = database.getCollection("events");
                MongoCollection<Document> registrationsCollection = database.getCollection("eventRegistrations");
                
                ArrayList<Document> eventsList = eventsCollection.find().into(new ArrayList<>());
                
                // Calculate statistics
                int totalEvents = eventsList.size();
                int activeEvents = 0;
                int totalRegistrations = (int) registrationsCollection.countDocuments();
                
                for(Document event : eventsList) {
                    String status = event.getString("status");
                    if("Active".equals(status)) {
                        activeEvents++;
                    }
                }
        %>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-label">Total Events</div>
                <div class="stat-value"><%= totalEvents %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Active Events</div>
                <div class="stat-value"><%= activeEvents %></div>
            </div>
            <div class="stat-card">
                <div class="stat-label">Total Registrations</div>
                <div class="stat-value"><%= totalRegistrations %></div>
            </div>
        </div>
        
        <div class="search-box">
            <input type="text" id="searchInput" placeholder="🔍 Search by event name, type, location..." onkeyup="searchTable()">
        </div>
        
        <%
                if(eventsList.isEmpty()) {
        %>
                    <div class="no-data">
                        📭 No events found! Click "Add Event" to create events.
                    </div>
        <%
                } else {
        %>
                    <table id="eventsTable">
                        <thead>
                            <tr>
                                <th>Event ID</th>
                                <th>Event Name</th>
                                <th>Type</th>
                                <th>Date & Time</th>
                                <th>Location</th>
                                <th>Eligibility</th>
                                <th>Max Capacity</th>
                                <th>Registered</th>
                                <th>Deadline</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for(Document event : eventsList) {
                                    String eventId = event.getString("eventId");
                                    String eventName = event.getString("eventName");
                                    String eventType = event.getString("eventType");
                                    String eventDate = event.getString("eventDate");
                                    String eventTime = event.getString("eventTime");
                                    String eventLocation = event.getString("eventLocation");
                                    String eligibility = event.getString("eligibility");
                                    String maxParticipants = event.getString("maxParticipants");
                                    String registrationDeadline = event.getString("registrationDeadline");
                                    String status = event.getString("status");
                                    
                                    // Count registrations for this event
                                    long registeredCount = registrationsCollection.countDocuments(new Document("eventId", eventId));
                                    
                                    String typeBadgeClass = "type-" + eventType.toLowerCase();
                                    String statusBadgeClass = status.equals("Active") ? "status-active" : "status-closed";
                            %>
                            <tr>
                                <td><strong><%= eventId %></strong></td>
                                <td><%= eventName %></td>
                                <td><span class="event-type-badge <%= typeBadgeClass %>"><%= eventType %></span></td>
                                <td><%= eventDate %><br><small><%= eventTime %></small></td>
                                <td><%= eventLocation %></td>
                                <td><%= eligibility %></td>
                                <td><%= maxParticipants %></td>
                                <td><span class="registration-count"><%= registeredCount %></span></td>
                                <td><%= registrationDeadline %></td>
                                <td><span class="status-badge <%= statusBadgeClass %>"><%= status %></span></td>
                                <td>
                                    <a href="viewRegisteredStudents.jsp?eventId=<%= eventId %>" class="view-btn">
                                        👥 View Students (<%= registeredCount %>)
                                    </a>
                                </td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
        <%
                }
            } catch(Exception e) {
                out.println("<div class='no-data'>❌ Error loading events: " + e.getMessage() + "</div>");
                e.printStackTrace();
            }
        %>
    </div>
    
    <script>
        function searchTable() {
            var input = document.getElementById("searchInput");
            var filter = input.value.toUpperCase();
            var table = document.getElementById("eventsTable");
            var tr = table.getElementsByTagName("tr");
            
            for (var i = 1; i < tr.length; i++) {
                var td = tr[i].getElementsByTagName("td");
                var found = false;
                
                for (var j = 0; j < td.length; j++) {
                    if (td[j]) {
                        var txtValue = td[j].textContent || td[j].innerText;
                        if (txtValue.toUpperCase().indexOf(filter) > -1) {
                            found = true;
                            break;
                        }
                    }
                }
                
                if (found) {
                    tr[i].style.display = "";
                } else {
                    tr[i].style.display = "none";
                }
            }
        }
    </script>
</body>
</html>
