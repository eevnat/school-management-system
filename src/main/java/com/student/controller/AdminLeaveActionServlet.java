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
import java.util.Date;

@WebServlet("/AdminLeaveActionServlet")
public class AdminLeaveActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String leaveId = request.getParameter("leaveId");
        String action = request.getParameter("action");
        String adminRemark = request.getParameter("adminRemark");

        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> col = db.getCollection("leaveRequests");

            Document filter = new Document("leaveId", leaveId).append("status", "PENDING_ADMIN");

            String newStatus;
            if("approve".equals(action)) newStatus = "APPROVED";
            else newStatus = "REJECTED_BY_ADMIN";

            Document update = new Document("$set", new Document()
                    .append("status", newStatus)
                    .append("adminRemark", adminRemark)
                    .append("adminActionAt", new Date().toString()));

            col.updateOne(filter, update);

            response.sendRedirect("admin/viewLeaveRequests.jsp");
        } catch(Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/viewLeaveRequests.jsp");
        }
    }
}
