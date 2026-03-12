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
import java.io.PrintWriter;

@WebServlet("/GetStudentsServlet")
public class GetStudentsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> collection = database.getCollection("students");
            
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            
            for (Document student : collection.find()) {
                if (!first) json.append(",");
                json.append("{")
                    .append("\"studentId\":\"").append(student.getString("studentId")).append("\",")
                    .append("\"name\":\"").append(student.getString("fullName")).append("\",")
                    .append("\"class\":\"").append(student.getString("className")).append("\",")
                    .append("\"section\":\"").append(student.getString("section")).append("\"")
                    .append("}");
                first = false;
            }
            json.append("]");
            
            out.print(json.toString());
            System.out.println("✅ Student list sent to client");
            
        } catch (Exception e) {
            System.out.println("❌ Error fetching students: " + e.getMessage());
            e.printStackTrace();
            out.print("[]");
        }
    }
}
