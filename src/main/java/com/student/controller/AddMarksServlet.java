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

@WebServlet("/AddMarksServlet")
public class AddMarksServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String rollNumber = request.getParameter("rollNumber");
        
        System.out.println("📝 AddMarksServlet called!");
        System.out.println("Roll Number: " + rollNumber);
        
        try {
            int mathematics = Integer.parseInt(request.getParameter("mathematics"));
            int science = Integer.parseInt(request.getParameter("science"));
            int english = Integer.parseInt(request.getParameter("english"));
            int socialStudies = Integer.parseInt(request.getParameter("socialStudies"));
            int hindi = Integer.parseInt(request.getParameter("hindi"));
            int computerScience = Integer.parseInt(request.getParameter("computerScience"));
            
            // Calculate totals
            int totalMarks = mathematics + science + english + socialStudies + hindi + computerScience;
            double percentage = (totalMarks / 600.0) * 100;
            String grade = calculateGrade(percentage);
            
            System.out.println("Total: " + totalMarks + ", Percentage: " + percentage + ", Grade: " + grade);
            
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> marksCollection = database.getCollection("marks");
            
            // Check if marks already exist for this student
            Document existingMarks = marksCollection.find(new Document("rollNumber", rollNumber)).first();
            
            if(existingMarks != null) {
                // Update existing marks
                Document updateDoc = new Document("$set", new Document()
                        .append("mathematics", mathematics)
                        .append("science", science)
                        .append("english", english)
                        .append("socialStudies", socialStudies)
                        .append("hindi", hindi)
                        .append("computerScience", computerScience)
                        .append("totalMarks", totalMarks)
                        .append("percentage", percentage)
                        .append("grade", grade)
                        .append("updatedDate", new java.util.Date().toString()));
                
                marksCollection.updateOne(new Document("rollNumber", rollNumber), updateDoc);
                System.out.println("✅ Marks updated successfully!");
            } else {
                // Insert new marks
                Document marksDoc = new Document("rollNumber", rollNumber)
                        .append("mathematics", mathematics)
                        .append("science", science)
                        .append("english", english)
                        .append("socialStudies", socialStudies)
                        .append("hindi", hindi)
                        .append("computerScience", computerScience)
                        .append("totalMarks", totalMarks)
                        .append("percentage", percentage)
                        .append("grade", grade)
                        .append("createdDate", new java.util.Date().toString());
                
                marksCollection.insertOne(marksDoc);
                System.out.println("✅ Marks added successfully!");
            }
            
            response.sendRedirect("admin/addMarks.jsp?success=1");
            
        } catch (Exception e) {
            System.out.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("admin/addMarks.jsp?error=1");
        }
    }
    
    private String calculateGrade(double percentage) {
        if(percentage >= 90) return "A+";
        else if(percentage >= 80) return "A";
        else if(percentage >= 70) return "B+";
        else if(percentage >= 60) return "B";
        else if(percentage >= 50) return "C";
        else if(percentage >= 40) return "D";
        else return "F";
    }
}
