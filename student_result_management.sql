-- ============================================================
--  STUDENT RESULT MANAGEMENT SYSTEM
--  Database Management System - Mini Project
--  Language : MySQL 8.x
--  Author   : [Your Name]
--  GitHub   : github.com/[your-username]/student-result-management
-- ============================================================


-- ============================================================
-- STEP 1 : CREATE & SELECT DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS student_result_db;
USE student_result_db;


-- ============================================================
-- STEP 2 : CREATE TABLES
-- ============================================================

-- ------------------------------------------------------------
-- TABLE 1 : Department
-- Stores all academic departments
-- ------------------------------------------------------------
CREATE TABLE Department (
    dept_id    INT          AUTO_INCREMENT PRIMARY KEY,
    dept_name  VARCHAR(100) NOT NULL UNIQUE,
    hod_name   VARCHAR(100)
);

-- ------------------------------------------------------------
-- TABLE 2 : Student
-- Stores student personal and academic info
-- dept_id is a Foreign Key referencing Department
-- ------------------------------------------------------------
CREATE TABLE Student (
    student_id  INT          AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    dob         DATE,
    gender      ENUM('Male', 'Female', 'Other'),
    email       VARCHAR(150) UNIQUE,
    phone       VARCHAR(15),
    dept_id     INT,
    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- TABLE 3 : Course
-- Stores courses offered by each department
-- dept_id is a Foreign Key referencing Department
-- ------------------------------------------------------------
CREATE TABLE Course (
    course_id    INT          AUTO_INCREMENT PRIMARY KEY,
    course_name  VARCHAR(150) NOT NULL,
    credits      INT          DEFAULT 4,
    dept_id      INT,
    FOREIGN KEY (dept_id)
        REFERENCES Department(dept_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ------------------------------------------------------------
-- TABLE 4 : Exam
-- Stores exam details for each semester
-- ------------------------------------------------------------
CREATE TABLE Exam (
    exam_id        INT         AUTO_INCREMENT PRIMARY KEY,
    exam_name      VARCHAR(100) NOT NULL,
    exam_date      DATE,
    semester       INT          CHECK (semester BETWEEN 1 AND 8),
    academic_year  VARCHAR(10)
);

-- ------------------------------------------------------------
-- TABLE 5 : Result
-- Core table - links Student, Course, and Exam
-- Stores marks and grade for each student per course per exam
-- ------------------------------------------------------------
CREATE TABLE Result (
    result_id       INT            AUTO_INCREMENT PRIMARY KEY,
    student_id      INT            NOT NULL,
    course_id       INT            NOT NULL,
    exam_id         INT            NOT NULL,
    marks_obtained  DECIMAL(5, 2),
    max_marks       DECIMAL(5, 2)  DEFAULT 100,
    grade           VARCHAR(2),
    FOREIGN KEY (student_id)
        REFERENCES Student(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id)
        REFERENCES Course(course_id)
        ON DELETE CASCADE,
    FOREIGN KEY (exam_id)
        REFERENCES Exam(exam_id)
        ON DELETE CASCADE,
    UNIQUE KEY unique_result (student_id, course_id, exam_id)
);

-- ------------------------------------------------------------
-- TABLE 6 : Grade_Log
-- Audit table - automatically filled by Trigger (Step 6)
-- Records every grade change with timestamp
-- ------------------------------------------------------------
CREATE TABLE Grade_Log (
    log_id      INT       AUTO_INCREMENT PRIMARY KEY,
    result_id   INT,
    old_grade   VARCHAR(2),
    new_grade   VARCHAR(2),
    changed_at  DATETIME  DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- STEP 3 : INSERT SAMPLE DATA
-- ============================================================

-- Departments
INSERT INTO Department (dept_name, hod_name) VALUES
    ('Computer Science',        'Dr. Ramesh Gupta'),
    ('Information Technology',  'Dr. Sunita Sharma'),
    ('Electronics',             'Dr. Anil Mehta');

-- Students
INSERT INTO Student (name, dob, gender, email, phone, dept_id) VALUES
    ('Aarav Patel',  '2003-05-12', 'Male',   'aarav@mail.com',  '9800001111', 1),
    ('Priya Shah',   '2003-08-22', 'Female', 'priya@mail.com',  '9800002222', 1),
    ('Rohan Mehta',  '2002-11-01', 'Male',   'rohan@mail.com',  '9800003333', 2),
    ('Sneha Joshi',  '2003-01-15', 'Female', 'sneha@mail.com',  '9800004444', 2),
    ('Karan Verma',  '2002-07-30', 'Male',   'karan@mail.com',  '9800005555', 3);

-- Courses
INSERT INTO Course (course_name, credits, dept_id) VALUES
    ('Data Structures',     4, 1),
    ('Database Management', 4, 1),
    ('Computer Networks',   3, 1),
    ('Web Technologies',    3, 2),
    ('Digital Electronics', 4, 3);

-- Exams
INSERT INTO Exam (exam_name, exam_date, semester, academic_year) VALUES
    ('Mid-Term Exam Sem 3', '2024-09-15', 3, '2024-25'),
    ('End-Term Exam Sem 3', '2024-11-20', 3, '2024-25');

-- Results
INSERT INTO Result (student_id, course_id, exam_id, marks_obtained, max_marks, grade) VALUES
    (1, 1, 1, 78,  100, 'B+'),
    (1, 2, 1, 91,  100, 'O'),
    (1, 1, 2, 82,  100, 'A'),
    (1, 2, 2, 88,  100, 'A+'),
    (2, 1, 1, 55,  100, 'C'),
    (2, 2, 1, 61,  100, 'B'),
    (2, 1, 2, 60,  100, 'B'),
    (2, 2, 2, 70,  100, 'B+'),
    (3, 4, 1, 45,  100, 'D'),
    (3, 4, 2, 50,  100, 'C'),
    (4, 4, 1, 88,  100, 'A+'),
    (4, 4, 2, 92,  100, 'O'),
    (5, 5, 1, 35,  100, 'F'),
    (5, 5, 2, 48,  100, 'D');


-- ============================================================
-- STEP 4 : VERIFY — SHOW ALL TABLES
-- ============================================================

-- Show all table names in this database
SHOW TABLES;

-- Show structure of each table
DESCRIBE Department;
DESCRIBE Student;
DESCRIBE Course;
DESCRIBE Exam;
DESCRIBE Result;
DESCRIBE Grade_Log;

-- Show all data in each table
SELECT * FROM Department;
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM Exam;
SELECT * FROM Result;


-- ============================================================
-- STEP 5 : SQL QUERIES
-- ============================================================

-- Q1 : All students with their department name
SELECT s.student_id, s.name, s.gender, d.dept_name
FROM Student s
JOIN Department d ON s.dept_id = d.dept_id
ORDER BY d.dept_name, s.name;

-- Q2 : Full result sheet (student + course + exam + marks)
SELECT s.name        AS Student,
       c.course_name AS Course,
       e.exam_name   AS Exam,
       r.marks_obtained,
       r.max_marks,
       r.grade
FROM Result r
JOIN Student s ON r.student_id = s.student_id
JOIN Course  c ON r.course_id  = c.course_id
JOIN Exam    e ON r.exam_id    = e.exam_id
ORDER BY s.name, e.exam_name;

-- Q3 : Average marks per student with rank
SELECT s.name,
       ROUND(AVG(r.marks_obtained), 2)                          AS avg_marks,
       RANK() OVER (ORDER BY AVG(r.marks_obtained) DESC)        AS rank_pos
FROM Result r
JOIN Student s ON r.student_id = s.student_id
GROUP BY s.student_id, s.name
ORDER BY avg_marks DESC;

-- Q4 : Students who failed in any subject
SELECT DISTINCT s.name        AS Student,
                c.course_name AS Course,
                r.marks_obtained
FROM Result r
JOIN Student s ON r.student_id = s.student_id
JOIN Course  c ON r.course_id  = c.course_id
WHERE r.grade = 'F';

-- Q5 : Pass / Fail count per course
SELECT c.course_name,
       SUM(CASE WHEN r.grade != 'F' THEN 1 ELSE 0 END) AS passed,
       SUM(CASE WHEN r.grade  = 'F' THEN 1 ELSE 0 END) AS failed
FROM Result r
JOIN Course c ON r.course_id = c.course_id
GROUP BY c.course_id, c.course_name;

-- Q6 : Department-wise average marks
SELECT d.dept_name,
       ROUND(AVG(r.marks_obtained), 2) AS dept_avg
FROM Result r
JOIN Student    s ON r.student_id = s.student_id
JOIN Department d ON s.dept_id    = d.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY dept_avg DESC;


-- ============================================================
-- STEP 6 : STORED PROCEDURE
-- Generates a report card for a given student_id
-- Usage : CALL GetReportCard(1);
-- ============================================================

DELIMITER //

CREATE PROCEDURE GetReportCard(IN p_student_id INT)
BEGIN
    SELECT s.name          AS Student,
           d.dept_name     AS Department,
           e.exam_name     AS Exam,
           e.semester      AS Semester,
           c.course_name   AS Course,
           r.marks_obtained,
           r.max_marks,
           r.grade
    FROM Result r
    JOIN Student    s ON r.student_id = s.student_id
    JOIN Course     c ON r.course_id  = c.course_id
    JOIN Exam       e ON r.exam_id    = e.exam_id
    JOIN Department d ON s.dept_id    = d.dept_id
    WHERE s.student_id = p_student_id
    ORDER BY e.semester, c.course_name;
END //

DELIMITER ;

-- Call the procedure
CALL GetReportCard(1);


-- ============================================================
-- STEP 7 : TRIGGER
-- Automatically logs any grade change into Grade_Log table
-- ============================================================

DELIMITER //

CREATE TRIGGER after_grade_update
AFTER UPDATE ON Result
FOR EACH ROW
BEGIN
    IF OLD.grade <> NEW.grade THEN
        INSERT INTO Grade_Log (result_id, old_grade, new_grade)
        VALUES (OLD.result_id, OLD.grade, NEW.grade);
    END IF;
END //

DELIMITER ;

-- Test the trigger (update a grade and check Grade_Log)
UPDATE Result SET grade = 'A' WHERE result_id = 13;

-- Verify trigger ran
SELECT * FROM Grade_Log;


-- ============================================================
-- END OF PROJECT
-- ============================================================
