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

@WebServlet("/MarkNotificationReadServlet")
public class MarkNotificationReadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        // Identify who is logged in
        String userType = null;  // student/parent/admin
        String userId = null;

        // Student
        if ("student".equals(session.getAttribute("role"))) {
            userType = "student";
            userId = (String) session.getAttribute("rollNumber");
        }
        // Admin
        else if ("admin".equals(session.getAttribute("role"))) {
            userType = "admin";
            userId = "ADMIN";
        }
        // Parent
        else if ("parent".equals(session.getAttribute("userType"))) {
            userType = "parent";
            userId = (String) session.getAttribute("studentRollNumber");
        }

        if (userType == null || userId == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String notificationId = request.getParameter("notificationId");
        String redirectTo = request.getParameter("redirectTo"); // optional

        if (notificationId == null || notificationId.trim().isEmpty()) {
            response.sendRedirect(redirectTo != null ? redirectTo : "index.jsp");
            return;
        }

        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> col = db.getCollection("notifications");

            // Only allow marking read for own notification
            Document filter = new Document("_id", new ObjectId(notificationId))
                    .append("toUserType", userType)
                    .append("toUserId", userId);

            Document update = new Document("$set", new Document("isRead", true));

            col.updateOne(filter, update);

        } catch (Exception e) {
            e.printStackTrace();
        }

        if (redirectTo == null || redirectTo.trim().isEmpty()) {
            // send back based on user
            if ("student".equals(userType)) response.sendRedirect("student/notifications.jsp");
            else if ("parent".equals(userType)) response.sendRedirect("parent/notifications.jsp");
            else response.sendRedirect("admin/notifications.jsp");
        } else {
            response.sendRedirect(redirectTo);
        }
    }
}
