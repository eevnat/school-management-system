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

@WebServlet("/MarkAllNotificationsReadServlet")
public class MarkAllNotificationsReadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String userType = null;
        String userId = null;

        if ("student".equals(session.getAttribute("role"))) {
            userType = "student";
            userId = (String) session.getAttribute("rollNumber");
        } else if ("admin".equals(session.getAttribute("role"))) {
            userType = "admin";
            userId = "ADMIN";
        } else if ("parent".equals(session.getAttribute("userType"))) {
            userType = "parent";
            userId = (String) session.getAttribute("studentRollNumber");
        }

        if (userType == null || userId == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> col = db.getCollection("notifications");

            Document filter = new Document("toUserType", userType)
                    .append("toUserId", userId)
                    .append("isRead", false);

            Document update = new Document("$set", new Document("isRead", true));

            col.updateMany(filter, update);

        } catch (Exception e) {
            e.printStackTrace();
        }

        // Back
        if ("student".equals(userType)) response.sendRedirect("student/notifications.jsp");
        else if ("parent".equals(userType)) response.sendRedirect("parent/notifications.jsp");
        else response.sendRedirect("admin/notifications.jsp");
    }
}
