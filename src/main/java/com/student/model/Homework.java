package com.student.model;

import org.bson.types.ObjectId;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class Homework {
    private ObjectId id;
    private String title;
    private String subject;
    private String description;
    private String className;
    private String section;
    private LocalDate dueDate;
    private LocalDateTime assignedDate;
    private String assignedBy; // Teacher email
    private String attachmentPath; // Optional file path
    private boolean active;
    
    // Constructors
    public Homework() {
        this.assignedDate = LocalDateTime.now();
        this.active = true;
    }
    
    // Getters and Setters
    public ObjectId getId() { return id; }
    public void setId(ObjectId id) { this.id = id; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getClassName() { return className; }
    public void setClassName(String className) { this.className = className; }
    
    public String getSection() { return section; }
    public void setSection(String section) { this.section = section; }
    
    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }
    
    public LocalDateTime getAssignedDate() { return assignedDate; }
    public void setAssignedDate(LocalDateTime assignedDate) { this.assignedDate = assignedDate; }
    
    public String getAssignedBy() { return assignedBy; }
    public void setAssignedBy(String assignedBy) { this.assignedBy = assignedBy; }
    
    public String getAttachmentPath() { return attachmentPath; }
    public void setAttachmentPath(String attachmentPath) { this.attachmentPath = attachmentPath; }
    
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
