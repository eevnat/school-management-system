package com.student.model;

import org.bson.types.ObjectId;
import java.time.LocalDateTime;

public class BehaviorLog {
    private ObjectId id;
    private String studentId;
    private String studentName;
    private String className;
    private String section;
    private String type; // POSITIVE, WARNING, SEVERE
    private String category; // Discipline, Participation, Conduct, etc.
    private String description;
    private String loggedBy; // Teacher/Admin email
    private LocalDateTime timestamp;
    private boolean notifyParent;
    
    // Constructors
    public BehaviorLog() {
        this.timestamp = LocalDateTime.now();
        this.notifyParent = true;
    }
    
    // Getters and Setters
    public ObjectId getId() { return id; }
    public void setId(ObjectId id) { this.id = id; }
    
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    
    public String getStudentName() { return studentName; }
    public void setStudentName(String studentName) { this.studentName = studentName; }
    
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    
    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }
    
    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getLoggedBy() { return loggedBy; }
    public void setLoggedBy(String loggedBy) { this.loggedBy = loggedBy; }
    
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    
    public boolean isNotifyParent() { return notifyParent; }
    public void setNotifyParent(boolean notifyParent) { this.notifyParent = notifyParent; }
}
