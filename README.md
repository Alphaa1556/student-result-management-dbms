 🎓 Student Result Management System
> A Database Management System (DBMS) mini project built with **MySQL**

---

## 📌 Project Overview

A relational database application to manage student academic records — including departments, courses, exams, and results. Demonstrates core DBMS concepts like normalization, joins, stored procedures, and triggers.

---

## 🗄️ Database Schema

| Table | Description |
|-------|-------------|
| `Department` | Academic departments |
| `Student` | Student personal & academic info |
| `Course` | Courses offered per department |
| `Exam` | Exam schedule and semester info |
| `Result` | Marks and grades per student per course |
| `Grade_Log` | Audit log of grade changes (filled by Trigger) |

---

## ⚙️ Features

- ✅ Normalized schema (3NF)
- ✅ Primary Keys, Foreign Keys, UNIQUE & CHECK constraints
- ✅ Sample data with 5 students, 5 courses, 2 exams
- ✅ SQL Queries — JOINs, GROUP BY, Window Functions (RANK)
- ✅ Stored Procedure — `GetReportCard(student_id)`
- ✅ Trigger — auto-logs grade changes to `Grade_Log`

---

## 🚀 How to Run

1. Open **MySQL Workbench** (or any MySQL client)
2. Open the file `student_result_management.sql`
3. Run the entire file (`Ctrl + Shift + Enter` in Workbench)
4. All tables are created, data is inserted, and queries execute automatically

---

## 📁 Files

```
student-result-management/
│
├── student_result_management.sql   ← Main SQL file (run this)
├── index.html      ← Live web demo (open in browser)
├── app.py <- Backend 
└── README.md
```

---

## 🛠️ Tech Stack

- **Database:** MySQL 8.x
- **Language:** SQL (DDL + DML)
- **Tool:** MySQL Workbench

---

## 👤 Author

**[Yash Khanavkar]**  
Mahatma Gandhi Mission's College Of Engineering And Technology   
GitHub:(https://github.com/Alphaa1556/)
