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
import org.bson.Document;

import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/AddBehaviorLogServlet")
public class AddBehaviorLogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("role") == null || 
           !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }
        
        String adminEmail = (String) session.getAttribute("adminEmail");
        String studentId = request.getParameter("studentId");
        String type = request.getParameter("type"); // POSITIVE, WARNING, SEVERE
        String category = request.getParameter("category");
        String description = request.getParameter("description");
        boolean notifyParent = "on".equals(request.getParameter("notifyParent"));
        
        System.out.println("📋 Adding behavior log for Student ID: " + studentId);
        System.out.println("   Type: " + type + " | Category: " + category);
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> behaviorCollection = database.getCollection("behavior_logs");
            MongoCollection<Document> studentCollection = database.getCollection("students");
            MongoCollection<Document> notificationCollection = database.getCollection("notifications");
            
            // Get student details
            Document student = studentCollection.find(
                new Document("studentId", studentId)
            ).first();
            
            if (student != null) {
                // Insert behavior log
                Document behaviorDoc = new Document()
                    .append("studentId", studentId)
                    .append("studentName", student.getString("fullName"))
                    .append("rollNumber", student.getString("rollNumber"))
                    .append("className", student.getString("className"))
                    .append("section", student.getString("section"))
                    .append("type", type)
                    .append("category", category)
                    .append("description", description)
                    .append("loggedBy", adminEmail)
                    .append("timestamp", LocalDateTime.now().toString())
                    .append("notifyParent", notifyParent);
                
                behaviorCollection.insertOne(behaviorDoc);
                System.out.println("✅ Behavior log added for: " + student.getString("fullName"));
                
                // Notify parent if requested
                if (notifyParent) {
                    String emoji = type.equals("POSITIVE") ? "👍" : 
                                 (type.equals("WARNING") ? "⚠️" : "🚨");
                    
                    Document notification = new Document()
                        .append("toUserType", "parent")
                        .append("toUserId", student.getString("parentEmail"))
                        .append("studentId", studentId)
                        .append("studentName", student.getString("fullName"))
                        .append("title", emoji + " Behavior Update: " + category)
                        .append("message", "Dear " + student.getString("parentName") + ",\n\n" +
                               "This is to inform you about a behavior incident regarding " + 
                               student.getString("fullName") + ".\n\n" +
                               "Type: " + type + "\n" +
                               "Category: " + category + "\n\n" +
                               "Details: " + description + "\n\n" +
                               "Logged by: " + adminEmail)
                        .append("type", "BEHAVIOR")
                        .append("priority", type.equals("SEVERE") ? "HIGH" : "MEDIUM")
                        .append("timestamp", LocalDateTime.now().toString())
                        .append("isRead", false);
                    
                    notificationCollection.insertOne(notification);
                    System.out.println("🔔 Parent notified: " + student.getString("parentEmail"));
                }
                
                session.setAttribute("successMessage", 
                    "✅ Behavior log added successfully!" + 
                    (notifyParent ? " Parent has been notified." : ""));
                response.sendRedirect("admin/addBehaviorLog.jsp");
            } else {
                System.out.println("❌ Student not found: " + studentId);
                session.setAttribute("errorMessage", "❌ Student not found!");
                response.sendRedirect("admin/addBehaviorLog.jsp");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error adding behavior log: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Error adding behavior log: " + e.getMessage());
            response.sendRedirect("admin/addBehaviorLog.jsp");
        }
    }
}
