# 🎓 ScholarHub – Advanced School Management System

ScholarHub is a **full-stack School Management System** built using **Java Servlets, JSP, and MongoDB**.
The platform enables schools to manage academic activities, student records, attendance, examinations, behavior tracking, and communication between administrators, students, and parents.

This system is designed with **role-based access control** where **Admins, Students, and Parents** interact with different dashboards.

---

# 🚀 System Modules

## 👨‍💼 Admin Panel

The Admin has complete control over the academic system.

Features:

• Add / Update / Delete Students
• View Registered Students
• Mark Student Attendance
• Manage Behavior Logs
• Add Homework
• Add Notices & Announcements
• Create Exams
• Add Student Marks
• Review Leave Requests
• Manage School Events
• View Detailed Academic Reports
• Generate Student Report Cards
• View Event Registrations

---

## 👨‍🎓 Student Portal

Students can access their academic information and interact with the system.

Features:

• Secure Student Login
• Student Dashboard
• View Attendance Records
• View Behavior Logs
• Access Homework
• View Exam Schedule
• View Marks
• View Report Cards
• Apply for Leave
• Track Leave Status
• View School Events
• Receive Notifications
• Academic Dashboard

Extra Feature:

🎯 **Exam Stress Reducer Module** – A small section designed to reduce exam stress and provide motivational support to students.

---

## 👨‍👩‍👧 Parent Portal

Parents can monitor their child's academic progress.

Features:

• Parent Login
• Parent Dashboard
• View Child Attendance
• View Child Behavior Logs
• Track Homework
• Monitor Exam Results
• View Report Cards
• Receive Notifications
• Review Leave Requests
• View School Events

---

# 🧠 Core Functionalities

### 📊 Attendance Management

Admins can mark attendance and generate attendance reports.

### 📘 Homework Management

Teachers/Admins can assign homework which students can view in their dashboard.

### 🧾 Behavior Tracking

Student behavior logs can be recorded and reviewed by parents.

### 📝 Examination System

Admins can:

• Create exams
• Assign marks
• Generate report cards

### 📅 Event Management

Admins can create school events and students can register for them.

### 📢 Notification System

Students and parents receive important announcements.

### 🏖 Leave Management

Students can apply for leave and admins can approve or reject requests.

---

# 🛠 Tech Stack

| Technology    | Usage              |
| ------------- | ------------------ |
| Java          | Backend logic      |
| Java Servlets | Controller layer   |
| JSP           | Dynamic webpages   |
| MongoDB       | Database           |
| Apache Tomcat | Application server |
| HTML / CSS    | Frontend           |
| Eclipse IDE   | Development        |
| Git & GitHub  | Version control    |

---

# 🗂 Project Architecture

The system follows a **layered architecture**:

Controller Layer
Handles requests and responses.

Model Layer
Defines system entities like Student, Attendance, Homework etc.

Utility Layer
Contains database and notification utilities.

View Layer
JSP pages for Admin, Student, and Parent dashboards.

---

# 📂 Project Structure

```plaintext
src/main/java
│
├── com.student.controller
│   ├── AdminLoginServlet
│   ├── StudentLoginServlet
│   ├── ParentLoginServlet
│   ├── AddStudentServlet
│   ├── DeleteStudentServlet
│   ├── UpdateStudentServlet
│   ├── AddMarksServlet
│   ├── AddHomeworkServlet
│   ├── AddEventServlet
│   ├── AddNoticeServlet
│   ├── MarkAttendanceServlet
│   ├── ApplyLeaveServlet
│   └── LogoutServlet
│
├── com.student.model
│   ├── Student
│   ├── Parent
│   ├── Attendance
│   ├── Homework
│   └── BehaviorLog
│
└── com.student.util
    ├── MongoDBUtil
    └── NotificationUtil
```

---

# 💾 Database

Database: **MongoDB**

Collections include:

• students
• parents
• attendance
• homework
• exams
• marks
• behaviorLogs
• notices
• events
• leaves

---

# ⚙️ Installation

### Clone Repository

```bash
git clone https://github.com/eevnat/school-management-system.git
```

### Import into Eclipse

File → Import → Existing Project

### Configure Server

Add **Apache Tomcat Server**

### Run Application

```
http://localhost:8080/studentcardgenerator
```

---

# 📸 Screenshots

Recommended screenshots:
Main Page:


• Admin Dashboard
• Student Dashboard
• Parent Dashboard
• Attendance System
• MongoDB Collections

---

# 🎯 What I Learned

Through this project I gained experience in:

✔ Java Servlet based backend development
✔ Role-based authentication systems
✔ Session management
✔ MongoDB database integration
✔ Multi-user system architecture
✔ MVC inspired application design

---

# 👩‍💻 Author

Tanvee Desai | Samruddhi Patil
MCA Students


---

⭐ If you found this project interesting, consider giving it a star on GitHub!
