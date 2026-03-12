package com.student.model;

public class Parent {
    private String studentRollNo;
    private String studentClass;
    private String studentSection;
    private String parentName;
    private String parentContact;
    private String parentEmail;
    
    // Constructors
    public Parent() {
    }
    
    public Parent(String studentRollNo, String studentClass, String studentSection, 
                  String parentName, String parentContact, String parentEmail) {
        this.studentRollNo = studentRollNo;
        this.studentClass = studentClass;
        this.studentSection = studentSection;
        this.parentName = parentName;
        this.parentContact = parentContact;
        this.parentEmail = parentEmail;
    }
    
    // Getters and Setters
    public String getStudentRollNo() {
        return studentRollNo;
    }
    
    public void setStudentRollNo(String studentRollNo) {
        this.studentRollNo = studentRollNo;
    }
    
    public String getStudentClass() {
        return studentClass;
    }
    
    public void setStudentClass(String studentClass) {
        this.studentClass = studentClass;
    }
    
    public String getStudentSection() {
        return studentSection;
    }
    
    public void setStudentSection(String studentSection) {
        this.studentSection = studentSection;
    }
    
    public String getParentName() {
        return parentName;
    }
    
    public void setParentName(String parentName) {
        this.parentName = parentName;
    }
    
    public String getParentContact() {
        return parentContact;
    }
    
    public void setParentContact(String parentContact) {
        this.parentContact = parentContact;
    }
    
    public String getParentEmail() {
        return parentEmail;
    }
    
    public void setParentEmail(String parentEmail) {
        this.parentEmail = parentEmail;
    }
}
