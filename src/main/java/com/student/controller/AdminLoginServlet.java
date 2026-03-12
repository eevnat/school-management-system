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

@WebServlet("/AdminLoginServlet")
public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        System.out.println("📝 Admin login attempt: " + username);
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> adminsCollection = database.getCollection("admins");
            
            Document query = new Document("username", username).append("password", password);
            Document adminDoc = adminsCollection.find(query).first();
            
            if(adminDoc != null) {
                System.out.println("✅ Admin login successful!");
                
                HttpSession session = request.getSession();
                session.setAttribute("adminId", adminDoc.getString("adminId"));
                session.setAttribute("adminUsername", adminDoc.getString("username"));
                session.setAttribute("adminName", adminDoc.getString("fullName"));
                session.setAttribute("role", "admin");
                
                response.sendRedirect(request.getContextPath() + "/admin/adminDashboard.jsp");
            } else {
                System.out.println("❌ Admin login failed!");
                response.sendRedirect(request.getContextPath() + "/admin/adminLogin.jsp?error=1");
            }
        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/adminLogin.jsp?error=1");
        }
    }
}
