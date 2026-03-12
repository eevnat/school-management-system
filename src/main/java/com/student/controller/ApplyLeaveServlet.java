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
import com.student.util.NotificationUtil;

import org.bson.Document;

import java.io.IOException;
import java.util.Date;

@WebServlet("/ApplyLeaveServlet")
public class ApplyLeaveServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null
                || !"student".equals(session.getAttribute("role"))) {
            response.sendRedirect("student/studentLogin.jsp");
            return;
        }

        String rollNumber = (String) session.getAttribute("rollNumber");
        String studentName = (String) session.getAttribute("studentName");
        String className = (String) session.getAttribute("studentClass");
        String section = (String) session.getAttribute("studentSection");

        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");
        String leaveType = request.getParameter("leaveType");
        String reason = request.getParameter("reason");

        // basic server-side validation
        if (fromDate == null || toDate == null || leaveType == null || reason == null
                || fromDate.trim().isEmpty() || toDate.trim().isEmpty()
                || leaveType.trim().isEmpty() || reason.trim().isEmpty()) {
            response.sendRedirect("student/applyLeave.jsp?error=1");
            return;
        }

        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> leaveCol = db.getCollection("leaveRequests");

            long count = leaveCol.countDocuments();
            String leaveId = "LEV" + String.format("%03d", count + 1);

            Document doc = new Document("leaveId", leaveId)
                    .append("rollNumber", rollNumber)
                    .append("studentName", studentName)
                    .append("className", className)
                    .append("section", section)
                    .append("fromDate", fromDate)
                    .append("toDate", toDate)
                    .append("leaveType", leaveType)
                    .append("reason", reason)
                    .append("status", "PENDING_PARENT")
                    .append("appliedAt", new Date().toString())
                    .append("parentRemark", null)
                    .append("adminRemark", null);

            // 1) Insert leave request
            leaveCol.insertOne(doc);

            // 2) ✅ Create notification for Parent
            // In your project, Parent is linked to a student using studentRollNumber,
            // so we use rollNumber as the parent "toUserId" as well.
            NotificationUtil.create(
                    "parent",
                    rollNumber,
                    "New Leave Request",
                    studentName + " applied for leave (" + leaveId + "). Please approve.",
                    "LEAVE",
                    leaveId
            );

            response.sendRedirect("student/applyLeave.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("student/applyLeave.jsp?error=1");
        }
    }
}
