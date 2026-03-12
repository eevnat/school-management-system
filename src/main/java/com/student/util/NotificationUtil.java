package com.student.util;

import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import org.bson.Document;

import java.util.Date;

public class NotificationUtil {

    // ✅ Constant receiver id for admin notifications
    public static final String ADMIN_ID = "ADMIN";

    public static void create(String toUserType, String toUserId,
                              String title, String message,
                              String module, String refId) {

        MongoDatabase db = MongoDBUtil.getDatabase();
        MongoCollection<Document> col = db.getCollection("notifications");

        Document doc = new Document("toUserType", toUserType)
                .append("toUserId", toUserId)
                .append("title", title)
                .append("message", message)
                .append("module", module)   // LEAVE / EVENT / NOTICE / MARKS
                .append("refId", refId)     // leaveId / eventId / noticeId
                .append("isRead", false)
                .append("createdAt", new Date().toString());

        col.insertOne(doc);
    }
}
