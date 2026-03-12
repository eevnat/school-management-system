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

@WebServlet("/AddStudentServlet")
public class AddStudentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get all form data from addStudent.jsp
        String studentId = request.getParameter("studentId");
        String rollNumber = request.getParameter("rollNumber");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String className = request.getParameter("className");
        String section = request.getParameter("section");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Get parent information
        String parentName = request.getParameter("parentName");
        String parentContact = request.getParameter("parentContact");
        String parentEmail = request.getParameter("parentEmail");
        
        System.out.println("📝 Attempting to add student: " + fullName);
        System.out.println("👪 Parent: " + parentName + " (" + parentEmail + ")");
        
        // Check if passwords match
        if(!password.equals(confirmPassword)) {
            System.out.println("❌ Passwords do not match!");
            response.sendRedirect("admin/addStudent.jsp?error=2");
            return;
        }
        
        try {
            // Connect to MongoDB
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> studentsCollection = database.getCollection("students");
            
            // Check if student ID or roll number already exists
            Document existingStudent = studentsCollection.find(
                new Document("$or", java.util.Arrays.asList(
                    new Document("studentId", studentId),
                    new Document("rollNumber", rollNumber)
                ))
            ).first();
            
            if(existingStudent != null) {
                System.out.println("❌ Student ID or Roll Number already exists!");
                response.sendRedirect("admin/addStudent.jsp?error=3");
                return;
            }
            
            // Create student document with parent information
            Document studentDoc = new Document("studentId", studentId)
                    .append("rollNumber", rollNumber)
                    .append("fullName", fullName)
                    .append("email", email)
                    .append("phoneNumber", phoneNumber)
                    .append("className", className)
                    .append("section", section)
                    .append("dateOfBirth", dateOfBirth)
                    .append("gender", gender)
                    .append("address", address)
                    .append("password", password)
                    .append("parentName", parentName)
                    .append("parentContact", parentContact)
                    .append("parentEmail", parentEmail)
                    .append("createdDate", new java.util.Date().toString());
            
            // Insert student into MongoDB
            studentsCollection.insertOne(studentDoc);
            
            System.out.println("✅ Student added successfully: " + fullName);
            System.out.println("   Roll Number: " + rollNumber);
            System.out.println("   Parent Email: " + parentEmail);
            
            // Redirect to admin dashboard with success message
            response.sendRedirect("admin/adminDashboard.jsp?success=1");
            
        } catch (Exception e) {
            // If any error occurs
            System.out.println("❌ Error adding student: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin/addStudent.jsp?error=1");
        }
    }
}
