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

@WebServlet("/ParentLoginServlet")
public class ParentLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get parent login credentials
        String parentName = request.getParameter("parentName");
        String parentEmail = request.getParameter("parentEmail");
        String studentClass = request.getParameter("studentClass");
        String studentSection = request.getParameter("studentSection");
        String studentRollNo = request.getParameter("studentRollNo");
        
        System.out.println("🔐 Parent login attempt:");
        System.out.println("   Parent: " + parentName);
        System.out.println("   Email: " + parentEmail);
        System.out.println("   Student: Class " + studentClass + "-" + studentSection + ", Roll: " + studentRollNo);
        
        try {
            // Connect to MongoDB
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> studentsCollection = database.getCollection("students");
            
            // Find student with matching credentials
            Document query = new Document("rollNumber", studentRollNo)
                    .append("className", studentClass)
                    .append("section", studentSection)
                    .append("parentName", parentName)
                    .append("parentEmail", parentEmail);
            
            Document student = studentsCollection.find(query).first();
            
            if(student != null) {
                // Login successful
                System.out.println("✅ Parent login successful!");
                System.out.println("   Student: " + student.getString("fullName"));
                
                // Create session
                HttpSession session = request.getSession();
                session.setAttribute("parentName", parentName);
                session.setAttribute("parentEmail", parentEmail);
                session.setAttribute("studentId", student.getString("studentId"));
                session.setAttribute("studentName", student.getString("fullName"));
                session.setAttribute("studentRollNumber", student.getString("rollNumber"));
                session.setAttribute("studentClass", student.getString("className"));
                session.setAttribute("studentSection", student.getString("section"));
                session.setAttribute("userType", "parent");
                
                // Redirect to parent dashboard
                response.sendRedirect("parent/parentDashboard.jsp");
                
            } else {
                // Login failed - credentials don't match
                System.out.println("❌ Parent login failed - Invalid credentials");
                response.sendRedirect("parent/parentLogin.jsp?error=Invalid credentials. Please check all details.");
            }
            
        } catch (Exception e) {
            System.out.println("❌ Error during parent login: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("parent/parentLogin.jsp?error=System error. Please try again.");
        }
    }
}
