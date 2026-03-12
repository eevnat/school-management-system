package com.student.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.student.util.MongoDBUtil;

import org.bson.Document;

import java.io.IOException;

@WebServlet("/AddEventServlet")
public class AddEventServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String eventName = request.getParameter("eventName");
        String eventType = request.getParameter("eventType");
        String eventDescription = request.getParameter("eventDescription");
        String eventDate = request.getParameter("eventDate");
        String eventTime = request.getParameter("eventTime");
        String eventLocation = request.getParameter("eventLocation");
        String maxParticipants = request.getParameter("maxParticipants");
        String registrationDeadline = request.getParameter("registrationDeadline");
        String eligibility = request.getParameter("eligibility");
        String contactPerson = request.getParameter("contactPerson");
        
        System.out.println("🎉 Creating event: " + eventName);
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> eventsCollection = database.getCollection("events");
            
            // Generate event ID
            long eventCount = eventsCollection.countDocuments();
            String eventId = "EVT" + String.format("%03d", eventCount + 1);
            
            // Create event document
            Document eventDoc = new Document("eventId", eventId)
                    .append("eventName", eventName)
                    .append("eventType", eventType)
                    .append("eventDescription", eventDescription)
                    .append("eventDate", eventDate)
                    .append("eventTime", eventTime)
                    .append("eventLocation", eventLocation)
                    .append("maxParticipants", maxParticipants != null && !maxParticipants.isEmpty() ? maxParticipants : "Unlimited")
                    .append("registrationDeadline", registrationDeadline)
                    .append("eligibility", eligibility)
                    .append("contactPerson", contactPerson != null && !contactPerson.isEmpty() ? contactPerson : "Not Specified")
                    .append("createdDate", new java.util.Date().toString())
                    .append("registeredCount", 0)
                    .append("status", "Active");
            
            // Insert into database
            eventsCollection.insertOne(eventDoc);
            
            System.out.println("✅ Event created successfully!");
            System.out.println("   Event ID: " + eventId);
            System.out.println("   Event Name: " + eventName);
            System.out.println("   Date: " + eventDate + " at " + eventTime);
            
            response.sendRedirect("admin/addEvent.jsp?success=1");
            
        } catch (Exception e) {
            System.out.println("❌ Error creating event: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin/addEvent.jsp?error=1");
        }
    }
}
