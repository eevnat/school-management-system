package com.student.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.student.util.MongoDBUtil;
import com.student.util.NotificationUtil;

import org.bson.Document;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

@WebServlet("/AddNoticeServlet")
public class AddNoticeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ✅ Admin security check (recommended)
        if (session == null || session.getAttribute("role") == null
                || !"admin".equals(session.getAttribute("role"))) {
            response.sendRedirect("admin/adminLogin.jsp");
            return;
        }

        String noticeId = request.getParameter("noticeId");
        String title = request.getParameter("title");
        String message = request.getParameter("message");
        String category = request.getParameter("category");
        String audience = request.getParameter("audience");
        String createdBy = (String) session.getAttribute("adminName");

        // ✅ Basic validation
        if (title == null || title.trim().isEmpty()
                || message == null || message.trim().isEmpty()
                || audience == null || audience.trim().isEmpty()) {
            response.sendRedirect("admin/addNotice.jsp?error=1");
            return;
        }

        // If your JSP is not sending noticeId, generate one safely
        if (noticeId == null || noticeId.trim().isEmpty()) {
            noticeId = "NOT" + System.currentTimeMillis();
        }

        try {
            MongoDatabase database = MongoDBUtil.getDatabase();
            MongoCollection<Document> noticesCollection = database.getCollection("notices");

            String createdDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());

            // 1) Insert notice
            Document noticeDoc = new Document("noticeId", noticeId)
                    .append("title", title)
                    .append("message", message)
                    .append("category", category)
                    .append("audience", audience) // ALL / STUDENT / PARENT (whatever you use)
                    .append("createdDate", createdDate)
                    .append("createdBy", createdBy);

            noticesCollection.insertOne(noticeDoc);

            // 2) ✅ Fan-out write notifications based on audience
            // Your project maps parent by student roll number, so parent toUserId = rollNumber
            MongoCollection<Document> studentsCollection = database.getCollection("students");

            MongoCursor<Document> cursor = studentsCollection.find().iterator();
            try {
                while (cursor.hasNext()) {
                    Document stu = cursor.next();
                    String rollNumber = stu.getString("rollNumber");
                    if (rollNumber == null || rollNumber.trim().isEmpty()) continue;

                    // If audience is ALL -> notify both
                    if ("ALL".equalsIgnoreCase(audience)) {

                        NotificationUtil.create(
                                "student",
                                rollNumber,
                                "New Notice",
                                title,
                                "NOTICE",
                                noticeId
                        );

                        NotificationUtil.create(
                                "parent",
                                rollNumber,
                                "New Notice",
                                title,
                                "NOTICE",
                                noticeId
                        );
                    }
                    // If audience is STUDENT -> only student
                    else if ("STUDENT".equalsIgnoreCase(audience)) {

                        NotificationUtil.create(
                                "student",
                                rollNumber,
                                "New Notice",
                                title,
                                "NOTICE",
                                noticeId
                        );
                    }
                    // If audience is PARENT -> only parent
                    else if ("PARENT".equalsIgnoreCase(audience)) {

                        NotificationUtil.create(
                                "parent",
                                rollNumber,
                                "New Notice",
                                title,
                                "NOTICE",
                                noticeId
                        );
                    }
                    // If audience is something else -> default notify both (safe)
                    else {
                        NotificationUtil.create(
                                "student",
                                rollNumber,
                                "New Notice",
                                title,
                                "NOTICE",
                                noticeId
                        );
                        NotificationUtil.create(
                                "parent",
                                rollNumber,
                                "New Notice",
                                title,
                                "NOTICE",
                                noticeId
                        );
                    }
                }
            } finally {
                cursor.close();
            }

            response.sendRedirect("admin/addNotice.jsp?success=1");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin/addNotice.jsp?error=1");
        }
    }
}
