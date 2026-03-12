package com.student.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.student.util.MongoDBUtil;
import org.bson.Document;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/AddHomeworkServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,   // 2MB
    maxFileSize = 1024 * 1024 * 10,        // 10MB
    maxRequestSize = 1024 * 1024 * 50      // 50MB
)
public class AddHomeworkServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "homework_uploads";
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("role") == null || 
           !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }
        
        String adminEmail = (String) session.getAttribute("adminEmail");
        
        try {
            // Get form parameters
            String title = request.getParameter("title");
            String subject = request.getParameter("subject");
            String description = request.getParameter("description");
            String className = request.getParameter("className");
            String section = request.getParameter("section");
            String dueDate = request.getParameter("dueDate");
            
            System.out.println("📚 Adding homework: " + title + " for Class " + className + "-" + section);
            
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> homeworkCollection = database.getCollection("homework");
            MongoCollection<Document> studentCollection = database.getCollection("students");
            MongoCollection<Document> notificationCollection = database.getCollection("notifications");
            
            String attachmentPath = null;
            
            // Handle file upload if present
            try {
                Part filePart = request.getPart("attachment");
                
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = getSubmittedFileName(filePart);
                    
                    if (fileName != null && !fileName.isEmpty()) {
                        // Create upload directory in webapp folder
                        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
                        File uploadDir = new File(uploadPath);
                        
                        // Create directory if it doesn't exist
                        if (!uploadDir.exists()) {
                            boolean created = uploadDir.mkdirs();
                            System.out.println("📁 Upload directory created: " + created + " at " + uploadPath);
                        }
                        
                        // Generate unique filename
                        String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                        String filePath = uploadPath + File.separator + uniqueFileName;
                        
                        // Save the file
                        filePart.write(filePath);
                        attachmentPath = UPLOAD_DIR + "/" + uniqueFileName;
                        System.out.println("📎 File uploaded successfully: " + attachmentPath);
                    }
                }
            } catch (Exception fileEx) {
                System.out.println("⚠️ File upload failed (continuing without file): " + fileEx.getMessage());
                fileEx.printStackTrace();
                // Continue without file - don't fail the entire operation
            }
            
            // Insert homework
            Document homeworkDoc = new Document()
                .append("title", title)
                .append("subject", subject)
                .append("description", description)
                .append("className", className)
                .append("section", section)
                .append("dueDate", dueDate)
                .append("assignedDate", LocalDateTime.now().toString())
                .append("assignedBy", adminEmail != null ? adminEmail : "admin")
                .append("attachmentPath", attachmentPath)
                .append("active", true);
            
            homeworkCollection.insertOne(homeworkDoc);
            System.out.println("✅ Homework added to database");
            
            // Notify all students of this class
            int notifiedCount = 0;
            for (Document student : studentCollection.find(
                    new Document("className", className).append("section", section))) {
                
                try {
                    Document notification = new Document()
                        .append("toUserType", "student")
                        .append("toUserId", student.getString("rollNumber"))
                        .append("studentId", student.getString("studentId"))
                        .append("studentName", student.getString("fullName"))
                        .append("title", "📚 New Homework: " + subject)
                        .append("message", title + " | Due Date: " + dueDate + "\n\n" + description)
                        .append("type", "HOMEWORK")
                        .append("priority", "MEDIUM")
                        .append("timestamp", LocalDateTime.now().toString())
                        .append("isRead", false);
                    
                    notificationCollection.insertOne(notification);
                    notifiedCount++;
                } catch (Exception notifEx) {
                    System.out.println("⚠️ Failed to notify student: " + student.getString("fullName"));
                }
            }
            
            System.out.println("🔔 " + notifiedCount + " students notified");
            
            session.setAttribute("successMessage", "✅ Homework assigned successfully! " + notifiedCount + " students notified.");
            response.sendRedirect("admin/addHomework.jsp");
            
        } catch (Exception e) {
            System.out.println("❌ Error adding homework: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Error adding homework: " + e.getMessage());
            response.sendRedirect("admin/addHomework.jsp");
        }
    }
    
    // Helper method to extract filename from Part
    private String getSubmittedFileName(Part part) {
        try {
            String contentDisp = part.getHeader("content-disposition");
            if (contentDisp == null) return null;
            
            String[] tokens = contentDisp.split(";");
            for (String token : tokens) {
                if (token.trim().startsWith("filename")) {
                    String fileName = token.substring(token.indexOf("=") + 2, token.length() - 1);
                    // Handle both Windows and Unix path separators
                    int lastSlash = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
                    return fileName.substring(lastSlash + 1);
                }
            }
        } catch (Exception e) {
            System.out.println("Error extracting filename: " + e.getMessage());
        }
        return null;
    }
}
