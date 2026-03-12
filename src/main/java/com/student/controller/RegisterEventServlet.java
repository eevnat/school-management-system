package com.student.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.student.util.MongoDBUtil;
import com.student.util.NotificationUtil;

import org.bson.Document;

import java.io.IOException;

@WebServlet("/RegisterEventServlet")
public class RegisterEventServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Optional security check: only student can register
        if (session == null || session.getAttribute("role") == null
                || !"student".equals(session.getAttribute("role"))) {
            response.sendRedirect("student/studentLogin.jsp");
            return;
        }

        // Prefer rollNumber from session (more secure than request parameter)
        String rollNumber = (String) session.getAttribute("rollNumber");
        String studentName = (String) session.getAttribute("studentName");

        String eventId = request.getParameter("eventId");

        // Basic validation
        if (rollNumber == null || rollNumber.trim().isEmpty()
                || eventId == null || eventId.trim().isEmpty()) {
            response.sendRedirect("student/viewEvents.jsp?error=1");
            return;
        }

        System.out.println("🎉 Event registration attempt:");
        System.out.println("   Roll Number: " + rollNumber);
        System.out.println("   Event ID: " + eventId);

        try {
            MongoDatabase database = MongoDBUtil.getDatabase();

            MongoCollection<Document> registrationsCollection = database.getCollection("eventRegistrations");
            MongoCollection<Document> eventsCollection = database.getCollection("events");

            // Get event name (optional, for nicer notification message)
            String eventName = eventId;
            Document eventDoc = eventsCollection.find(new Document("eventId", eventId)).first();
            if (eventDoc != null && eventDoc.getString("eventName") != null) {
                eventName = eventDoc.getString("eventName");
            } else if (eventDoc != null && eventDoc.getString("name") != null) {
                // fallback if your field is "name"
                eventName = eventDoc.getString("name");
            }

            // Check if already registered
            Document existingRegistration = registrationsCollection.find(
                    new Document("eventId", eventId).append("rollNumber", rollNumber)
            ).first();

            if (existingRegistration != null) {
                System.out.println("❌ Already registered for this event!");
                response.sendRedirect("student/viewEvents.jsp?error=already");
                return;
            }

            // Create registration document
            Document registrationDoc = new Document("eventId", eventId)
                    .append("rollNumber", rollNumber)
                    .append("registrationDate", new java.util.Date().toString())
                    .append("status", "Registered");

            // Insert registration
            registrationsCollection.insertOne(registrationDoc);

            System.out.println("✅ Registration successful!");

            // ✅ 1) Notify Student
            NotificationUtil.create(
                    "student",
                    rollNumber,
                    "Event Registration Successful",
                    "You registered successfully for: " + eventName + " (ID: " + eventId + ")",
                    "EVENT",
                    eventId
            );

            // ✅ 2) Notify Admin
            NotificationUtil.create(
                    "admin",
                    NotificationUtil.ADMIN_ID,
                    "New Event Registration",
                    (studentName != null ? studentName : "Student") + " (Roll: " + rollNumber + ") registered for: " + eventName,
                    "EVENT",
                    eventId
            );

            // ✅ 3) Notify Parent (your project maps parent using studentRollNumber)
            NotificationUtil.create(
                    "parent",
                    rollNumber,
                    "Event Registration",
                    "Your child (Roll: " + rollNumber + ") registered for: " + eventName,
                    "EVENT",
                    eventId
            );

            response.sendRedirect("student/viewEvents.jsp?success=1");

        } catch (Exception e) {
            System.out.println("❌ Error during registration: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("student/viewEvents.jsp?error=1");
        }
    }
}
