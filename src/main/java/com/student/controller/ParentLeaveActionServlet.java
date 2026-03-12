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

@WebServlet("/ParentLeaveActionServlet")
public class ParentLeaveActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ✅ Parent session check (your project uses userType)
        if (session == null || session.getAttribute("userType") == null
                || !"parent".equals(session.getAttribute("userType"))) {
            response.sendRedirect("parent/parentLogin.jsp");
            return;
        }

        // ✅ child roll number stored in session
        String studentRollNumber = (String) session.getAttribute("studentRollNumber");
        String parentName = (String) session.getAttribute("parentName");

        if (studentRollNumber == null || studentRollNumber.trim().isEmpty()) {
            response.sendRedirect("parent/parentLogin.jsp");
            return;
        }

        String leaveId = request.getParameter("leaveId");
        String action = request.getParameter("action"); // approve / reject
        String parentRemark = request.getParameter("parentRemark");

        if (leaveId == null || leaveId.trim().isEmpty()
                || action == null || action.trim().isEmpty()
                || parentRemark == null || parentRemark.trim().isEmpty()) {
            response.sendRedirect("parent/pendingLeaves.jsp");
            return;
        }

        String newStatus = "approve".equalsIgnoreCase(action) ? "PENDING_ADMIN" : "REJECTED_BY_PARENT";

        try {
            MongoDatabase db = MongoDBUtil.getDatabase();
            MongoCollection<Document> leaveCol = db.getCollection("leaveRequests");

            // Update only if still pending parent
            Document filter = new Document("leaveId", leaveId)
                    .append("rollNumber", studentRollNumber)
                    .append("status", "PENDING_PARENT");

            Document updateFields = new Document()
                    .append("status", newStatus)
                    .append("parentRemark", parentRemark)
                    .append("parentActionAt", new Date().toString());

            leaveCol.updateOne(filter, new Document("$set", updateFields));

            // ✅ Notification: Student gets parent decision
            String decisionText = "PENDING_ADMIN".equals(newStatus) ? "approved" : "rejected";
            String parentDisplay = (parentName == null || parentName.trim().isEmpty()) ? "Parent" : parentName;

            NotificationUtil.create(
                    "student",
                    studentRollNumber,
                    "Leave Update",
                    parentDisplay + " " + decisionText + " your leave (" + leaveId + ").",
                    "LEAVE",
                    leaveId
            );

            // ✅ Notification: Admin gets request only if parent approved
            if ("PENDING_ADMIN".equals(newStatus)) {
                NotificationUtil.create(
                        "admin",
                        NotificationUtil.ADMIN_ID,
                        "Leave Pending Approval",
                        "Leave " + leaveId + " is approved by parent and waiting for your decision.",
                        "LEAVE",
                        leaveId
                );
            }

            response.sendRedirect("parent/pendingLeaves.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("parent/pendingLeaves.jsp");
        }
    }
}
