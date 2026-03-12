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
import org.bson.types.ObjectId;

import java.io.IOException;

@WebServlet("/DeleteHomeworkServlet")
public class DeleteHomeworkServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Support both GET and POST
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        processRequest(request, response);
    }
    
    private void processRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if(session == null || session.getAttribute("role") == null || 
           !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }
        
        String homeworkId = request.getParameter("homeworkId");
        
        if (homeworkId == null || homeworkId.isEmpty()) {
            System.out.println("❌ No homework ID provided");
            session.setAttribute("errorMessage", "❌ Invalid homework ID!");
            response.sendRedirect("admin/viewHomework.jsp");
            return;
        }
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> homeworkCollection = database.getCollection("homework");
            
            homeworkCollection.deleteOne(new Document("_id", new ObjectId(homeworkId)));
            
            System.out.println("✅ Homework deleted: " + homeworkId);
            
            session.setAttribute("successMessage", "✅ Homework deleted successfully!");
            response.sendRedirect("admin/viewHomework.jsp");
            
        } catch (Exception e) {
            System.out.println("❌ Error deleting homework: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "❌ Error deleting homework: " + e.getMessage());
            response.sendRedirect("admin/viewHomework.jsp");
        }
    }
}
