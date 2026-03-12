package com.student.controller; // Make sure this matches your package structure

import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import org.bson.Document;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.student.util.MongoDBUtil;

@WebServlet("/AddExamServlet") // URL Mapping
public class AddExamServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        // Check if admin is logged in
        if(session.getAttribute("role") == null || !session.getAttribute("role").equals("admin")) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }

        try {
            // 1. Retrieve Main Info
            String examName = request.getParameter("examName");
            String targetClass = request.getParameter("targetClass");
            String examCategory = request.getParameter("examCategory");
            String examNote = request.getParameter("examNote");
            
            // 2. Retrieve Dynamic Arrays
            String[] dates = request.getParameterValues("dates[]");
            String[] times = request.getParameterValues("times[]");
            String[] codes = request.getParameterValues("codes[]");
            String[] subjects = request.getParameterValues("subjects[]");
            String[] syllabi = request.getParameterValues("syllabi[]");

            // 3. Create Schedule List
            List<Document> scheduleList = new ArrayList<>();
            
            if (dates != null) {
                for (int i = 0; i < dates.length; i++) {
                    Document row = new Document()
                        .append("date", dates[i])
                        .append("time", times[i])
                        .append("code", codes[i])
                        .append("subject", subjects[i])
                        .append("syllabus", (syllabi != null && i < syllabi.length) ? syllabi[i] : "");
                    
                    scheduleList.add(row);
                }
            }

            // 4. Build Final Document
            Document examDoc = new Document()
                .append("title", examName)
                .append("class", targetClass)
                .append("category", examCategory)
                .append("note", examNote)
                .append("schedule", scheduleList)
                .append("createdAt", new Date());

            // 5. Insert into MongoDB
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> collection = db.getCollection("exams");
            collection.insertOne(examDoc);

            // 6. Redirect to SUCCESS
            // NOTE: Using "admin/" prefix assuming JSP is in admin folder
            response.sendRedirect("admin/examDashboard.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/examDashboard.jsp?error=1");
        }
    }
}
