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
import com.mongodb.client.result.DeleteResult;
import com.student.util.MongoDBUtil;
import org.bson.Document;

@WebServlet("/DeleteStudentServlet")
public class DeleteStudentServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        // Check if admin is logged in
        if(session == null || session.getAttribute("role") == null || 
           !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }
        
        String studentId = request.getParameter("studentId");
        
        if(studentId == null || studentId.trim().isEmpty()) {
            response.sendRedirect("admin/viewStudents.jsp?error=invalid");
            return;
        }
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> studentsCollection = database.getCollection("students");
            
            // Delete the student document
            Document filter = new Document("studentId", studentId);
            DeleteResult result = studentsCollection.deleteOne(filter);
            
            if(result.getDeletedCount() > 0) {
                // Successfully deleted
                response.sendRedirect("admin/viewStudents.jsp?success=deleted");
            } else {
                // Student not found
                response.sendRedirect("admin/viewStudents.jsp?error=notfound");
            }
            
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/viewStudents.jsp?error=exception");
        }
    }
}
