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

@WebServlet("/MarkAttendanceServlet")
public class MarkAttendanceServlet extends HttpServlet {
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
        String attendanceDate = request.getParameter("attendanceDate");
        String className = request.getParameter("className");
        String section = request.getParameter("section");
        String[] studentIds = request.getParameterValues("studentIds[]");
        String[] statuses = request.getParameterValues("statuses[]");
        
        System.out.println("📝 Marking attendance for Class " + className + "-" + section);
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> attendanceCollection = database.getCollection("attendance");
            MongoCollection<Document> studentCollection = database.getCollection("students");
            MongoCollection<Document> notificationCollection = database.getCollection("notifications");
            
            int markedCount = 0;
            int absentCount = 0;
            
            for (int i = 0; i < studentIds.length; i++) {
                String studentId = studentIds[i];
                String status = statuses[i];
                
                // Get student details
                Document student = studentCollection.find(
                    new Document("studentId", studentId)
                ).first();
                
                if (student != null) {
                    // Check if attendance already marked for this date
                    Document existing = attendanceCollection.find(
                        new Document("studentId", studentId)
                            .append("date", attendanceDate)
                    ).first();
                    
                    if (existing != null) {
                        // Update existing record
                        attendanceCollection.updateOne(
                            new Document("_id", existing.getObjectId("_id")),
                            new Document("$set", new Document()
                                .append("status", status)
                                .append("markedBy", adminEmail)
                                .append("timestamp", LocalDateTime.now().toString()))
                        );
                        System.out.println("✏️ Updated attendance for: " + student.getString("fullName"));
                    } else {
                        // Insert new record
                        Document attendanceDoc = new Document()
                            .append("studentId", studentId)
                            .append("studentName", student.getString("fullName"))
                            .append("rollNumber", student.getString("rollNumber"))
                            .append("className", className)
                            .append("section", section)
                            .append("date", attendanceDate)
                            .append("status", status)
                            .append("markedBy", adminEmail)
                            .append("timestamp", LocalDateTime.now().toString());
                        
                        attendanceCollection.insertOne(attendanceDoc);
                        System.out.println("✅ Marked attendance for: " + student.getString("fullName") + " - " + status);
                    }
                    
                    // Auto-notify parent if ABSENT
                    if ("ABSENT".equals(status)) {
                        absentCount++;
                        Document notification = new Document()
                            .append("toUserType", "parent")
                            .append("toUserId", student.getString("parentEmail"))
                            .append("studentId", studentId)
                            .append("studentName", student.getString("fullName"))
                            .append("title", "🚨 Absence Alert")
                            .append("message", "Your ward " + student.getString("fullName") + 
                                   " was marked ABSENT on " + attendanceDate + ". Please contact school if this is an error.")
                            .append("type", "ATTENDANCE")
                            .append("priority", "HIGH")
                            .append("timestamp", LocalDateTime.now().toString())
                            .append("isRead", false);
                        
                        notificationCollection.insertOne(notification);
                        System.out.println("🔔 Parent notified: " + student.getString("parentEmail"));
                    }
                    
                    markedCount++;
                }
            }
            
            System.out.println("✅ Attendance marked successfully!");
            System.out.println("   Total: " + markedCount + " students");
            System.out.println("   Absent: " + absentCount + " students");
            
            session.setAttribute("successMessage", 
                "✅ Attendance marked for " + markedCount + " students! " + 
                (absentCount > 0 ? absentCount + " parents notified for absent students." : ""));
            response.sendRedirect("admin/markAttendance.jsp");
            
        } catch (Exception e) {
            System.out.println("❌ Error marking attendance: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Error marking attendance: " + e.getMessage());
            response.sendRedirect("admin/markAttendance.jsp");
        }
    }
}
