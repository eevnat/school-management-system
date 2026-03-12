package com.student.util;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;

public class MongoDBUtil {
    
    // MongoDB connection URL (change if your MongoDB is on different port)
	private static final String CONNECTION_STRING = "mongodb+srv://tanveedesai1706_db_user:Wz7D6szjHBSGYI5R@cluster0.wv33irq.mongodb.net/studentreportdb";
    // Database name
    private static final String DATABASE_NAME = "studentreportdb";
    
    // MongoClient object (keeps connection open)
    private static MongoClient mongoClient = null;
    
    // Method to get MongoDB client
    public static MongoClient getMongoClient() {
        if(mongoClient == null) {
            mongoClient = MongoClients.create(CONNECTION_STRING);
            System.out.println("✅ MongoDB Connected Successfully!");
        }
        return mongoClient;
    }
    
    // Method to get database
    public static MongoDatabase getDatabase() {
        return getMongoClient().getDatabase(DATABASE_NAME);
    }
    
    // Method to close connection (optional - call when app closes)
    public static void closeConnection() {
        if(mongoClient != null) {
            mongoClient.close();
            System.out.println("❌ MongoDB Connection Closed!");
        }
    }
}
