package com.student.model;

import org.bson.types.ObjectId;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Attendance {
    private ObjectId id;
    private String studentId;
    private String studentName;
    private String className;
    private String section;
    private LocalDate date;
    private String status; // PRESENT, ABSENT, LATE
    private String markedBy; // Teacher/Admin email
    private LocalDateTime timestamp;
    private String remarks;
    
    // Constructors
    public Attendance() {
        this.timestamp = LocalDateTime.now();
    }
    
    public Attendance(String studentId, String studentName, String className, 
                     String section, LocalDate date, String status, String markedBy) {
        this.studentId = studentId;
        this.studentName = studentName;
        this.className = className;
        this.section = section;
        this.date = date;
        this.status = status;
        this.markedBy = markedBy;
        this.timestamp = LocalDateTime.now();
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
    
    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getMarkedBy() { return markedBy; }
    public void setMarkedBy(String markedBy) { this.markedBy = markedBy; }
    
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
    
    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
}
