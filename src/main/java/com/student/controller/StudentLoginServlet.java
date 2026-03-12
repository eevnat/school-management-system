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

@WebServlet("/StudentLoginServlet")
public class StudentLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String rollNumber = request.getParameter("rollNumber");
        String password = request.getParameter("password");
        
        System.out.println("📝 Student login attempt - Roll Number: " + rollNumber);
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> studentsCollection = database.getCollection("students");
            
            Document query = new Document("rollNumber", rollNumber).append("password", password);
            Document studentDoc = studentsCollection.find(query).first();
            
            if(studentDoc != null) {
                System.out.println("✅ Student login successful: " + studentDoc.getString("fullName"));
                
                HttpSession session = request.getSession();
                session.setAttribute("studentId", studentDoc.getString("studentId"));
                session.setAttribute("rollNumber", studentDoc.getString("rollNumber"));
                session.setAttribute("studentName", studentDoc.getString("fullName"));
                session.setAttribute("studentEmail", studentDoc.getString("email"));
                session.setAttribute("studentClass", studentDoc.getString("className"));
                session.setAttribute("studentSection", studentDoc.getString("section"));
                session.setAttribute("role", "student");
                
                response.sendRedirect("student/studentDashboard.jsp");
            } else {
                System.out.println("❌ Student login failed!");
                response.sendRedirect("student/studentLogin.jsp?error=1");
            }
        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("student/studentLogin.jsp?error=1");
        }
    }
}
