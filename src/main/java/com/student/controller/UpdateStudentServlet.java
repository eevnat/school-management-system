package com.student.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.result.UpdateResult;
import com.student.util.MongoDBUtil;
import org.bson.Document;

@WebServlet("/UpdateStudentServlet")
public class UpdateStudentServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if admin is logged in
        if(session == null || session.getAttribute("role") == null || 
           !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }
        
        String studentId = request.getParameter("studentId");
        String rollNumber = request.getParameter("rollNumber");
        String fullName = request.getParameter("fullName");
        String className = request.getParameter("className");
        String section = request.getParameter("section");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String dateOfBirth = request.getParameter("dateOfBirth");
        String gender = request.getParameter("gender");
        String address = request.getParameter("address");
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> studentsCollection = database.getCollection("students");
            
            // Create filter to find the student
            Document filter = new Document("studentId", studentId);
            
            // Create update document with new values
            Document updateDoc = new Document("$set", new Document()
                .append("rollNumber", rollNumber)
                .append("fullName", fullName)
                .append("className", className)
                .append("section", section)
                .append("email", email)
                .append("phoneNumber", phoneNumber)
                .append("dateOfBirth", dateOfBirth)
                .append("gender", gender)
                .append("address", address)
            );
            
            // Update the student document
            UpdateResult result = studentsCollection.updateOne(filter, updateDoc);
            
            if(result.getModifiedCount() > 0 || result.getMatchedCount() > 0) {
                // Successfully updated
                response.sendRedirect("admin/viewStudents.jsp?success=updated");
            } else {
                // Student not found
                response.sendRedirect("admin/viewStudents.jsp?error=notfound");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/editStudent.jsp?studentId=" + studentId + "&error=exception");
        }
    }
}
