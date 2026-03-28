from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app)  # Allow frontend to talk to backend

# ─── DATABASE CONNECTION ────────────────────────────────────
def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="yash1556",       # ← Change this to YOUR MySQL password
        database="student_result_db"
    )

def query(sql, params=(), fetch=True):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute(sql, params)
    if fetch:
        result = cursor.fetchall()
        cursor.close(); db.close()
        return result
    db.commit()
    last_id = cursor.lastrowid
    cursor.close(); db.close()
    return last_id

# ─── HELPER ─────────────────────────────────────────────────
def calc_grade(marks, max_marks):
    pct = (marks / max_marks) * 100
    if pct >= 90: return 'O'
    if pct >= 80: return 'A+'
    if pct >= 70: return 'A'
    if pct >= 60: return 'B+'
    if pct >= 55: return 'B'
    if pct >= 45: return 'C'
    if pct >= 35: return 'D'
    return 'F'

# ─── DEPARTMENTS ────────────────────────────────────────────
@app.route('/api/departments', methods=['GET'])
def get_departments():
    return jsonify(query("SELECT * FROM Department"))

# ─── STUDENTS ───────────────────────────────────────────────
@app.route('/api/students', methods=['GET'])
def get_students():
    return jsonify(query("""
        SELECT s.student_id, s.name, s.dob, s.gender,
               s.email, s.phone, d.dept_name
        FROM Student s
        LEFT JOIN Department d ON s.dept_id = d.dept_id
        ORDER BY s.name
    """))

@app.route('/api/students', methods=['POST'])
def add_student():
    d = request.json
    try:
        last_id = query(
            "INSERT INTO Student (name, dob, gender, email, phone, dept_id) VALUES (%s,%s,%s,%s,%s,%s)",
            (d['name'], d.get('dob'), d.get('gender'), d.get('email'), d.get('phone'), d.get('dept_id')),
            fetch=False
        )
        return jsonify({"success": True, "student_id": last_id})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/students/<int:sid>', methods=['DELETE'])
def delete_student(sid):
    query("DELETE FROM Student WHERE student_id=%s", (sid,), fetch=False)
    return jsonify({"success": True})

# ─── COURSES ────────────────────────────────────────────────
@app.route('/api/courses', methods=['GET'])
def get_courses():
    return jsonify(query("""
        SELECT c.course_id, c.course_name, c.credits, d.dept_name
        FROM Course c
        LEFT JOIN Department d ON c.dept_id = d.dept_id
        ORDER BY c.course_name
    """))

@app.route('/api/courses', methods=['POST'])
def add_course():
    d = request.json
    try:
        last_id = query(
            "INSERT INTO Course (course_name, credits, dept_id) VALUES (%s,%s,%s)",
            (d['course_name'], d.get('credits', 4), d.get('dept_id')),
            fetch=False
        )
        return jsonify({"success": True, "course_id": last_id})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/courses/<int:cid>', methods=['DELETE'])
def delete_course(cid):
    query("DELETE FROM Course WHERE course_id=%s", (cid,), fetch=False)
    return jsonify({"success": True})

# ─── EXAMS ──────────────────────────────────────────────────
@app.route('/api/exams', methods=['GET'])
def get_exams():
    return jsonify(query("SELECT * FROM Exam ORDER BY exam_date"))

@app.route('/api/exams', methods=['POST'])
def add_exam():
    d = request.json
    try:
        last_id = query(
            "INSERT INTO Exam (exam_name, exam_date, semester, academic_year) VALUES (%s,%s,%s,%s)",
            (d['exam_name'], d.get('exam_date'), d.get('semester'), d.get('academic_year')),
            fetch=False
        )
        return jsonify({"success": True, "exam_id": last_id})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/exams/<int:eid>', methods=['DELETE'])
def delete_exam(eid):
    query("DELETE FROM Exam WHERE exam_id=%s", (eid,), fetch=False)
    return jsonify({"success": True})

# ─── RESULTS ────────────────────────────────────────────────
@app.route('/api/results', methods=['GET'])
def get_results():
    rows = query("""
        SELECT r.result_id, s.name AS student, c.course_name,
               e.exam_name, r.marks_obtained, r.max_marks, r.grade
        FROM Result r
        JOIN Student s ON r.student_id = s.student_id
        JOIN Course  c ON r.course_id  = c.course_id
        JOIN Exam    e ON r.exam_id    = e.exam_id
        ORDER BY s.name
    """)
    for r in rows:
        r['marks_obtained'] = float(r['marks_obtained'] or 0)
        r['max_marks']      = float(r['max_marks'] or 100)
    return jsonify(rows)

@app.route('/api/results', methods=['POST'])
def add_result():
    d = request.json
    marks = float(d['marks_obtained'])
    max_m = float(d.get('max_marks', 100))
    grade = calc_grade(marks, max_m)
    try:
        existing = query(
            "SELECT result_id FROM Result WHERE student_id=%s AND course_id=%s AND exam_id=%s",
            (d['student_id'], d['course_id'], d['exam_id'])
        )
        if existing:
            query(
                "UPDATE Result SET marks_obtained=%s, max_marks=%s, grade=%s WHERE result_id=%s",
                (marks, max_m, grade, existing[0]['result_id']),
                fetch=False
            )
            return jsonify({"success": True, "action": "updated", "grade": grade})
        else:
            last_id = query(
                "INSERT INTO Result (student_id, course_id, exam_id, marks_obtained, max_marks, grade) VALUES (%s,%s,%s,%s,%s,%s)",
                (d['student_id'], d['course_id'], d['exam_id'], marks, max_m, grade),
                fetch=False
            )
            return jsonify({"success": True, "action": "inserted", "result_id": last_id, "grade": grade})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

@app.route('/api/results/<int:rid>', methods=['DELETE'])
def delete_result(rid):
    query("DELETE FROM Result WHERE result_id=%s", (rid,), fetch=False)
    return jsonify({"success": True})

# ─── REPORT CARD ────────────────────────────────────────────
@app.route('/api/report/<int:sid>', methods=['GET'])
def get_report(sid):
    exam_id = request.args.get('exam_id')
    sql = """
        SELECT s.name, d.dept_name, e.exam_name, e.semester,
               c.course_name, c.credits,
               r.marks_obtained, r.max_marks, r.grade
        FROM Result r
        JOIN Student    s ON r.student_id = s.student_id
        JOIN Department d ON s.dept_id    = d.dept_id
        JOIN Course     c ON r.course_id  = c.course_id
        JOIN Exam       e ON r.exam_id    = e.exam_id
        WHERE r.student_id = %s
    """
    params = [sid]
    if exam_id:
        sql += " AND r.exam_id = %s"
        params.append(exam_id)
    sql += " ORDER BY e.semester, c.course_name"
    rows = query(sql, params)
    for r in rows:
        r['marks_obtained'] = float(r['marks_obtained'] or 0)
        r['max_marks']      = float(r['max_marks'] or 100)
        r['credits']        = int(r['credits'] or 0)
        r['semester']       = int(r['semester'] or 0)
    return jsonify(rows)

# ─── DASHBOARD STATS ────────────────────────────────────────
@app.route('/api/stats', methods=['GET'])
def get_stats():
    counts = query("""
        SELECT
            (SELECT COUNT(*) FROM Student)    AS students,
            (SELECT COUNT(*) FROM Course)     AS courses,
            (SELECT COUNT(*) FROM Exam)       AS exams,
            (SELECT COUNT(*) FROM Result)     AS results
    """)[0]
    pass_rate = query("""
        SELECT ROUND(100.0 * SUM(CASE WHEN grade != 'F' THEN 1 ELSE 0 END) / COUNT(*), 1) AS rate
        FROM Result
    """)[0]
    top = query("""
        SELECT s.name, ROUND(AVG(r.marks_obtained), 1) AS avg_marks
        FROM Result r JOIN Student s ON r.student_id = s.student_id
        GROUP BY s.student_id ORDER BY avg_marks DESC LIMIT 5
    """)
    failed = query("""
        SELECT DISTINCT s.name, c.course_name, r.marks_obtained
        FROM Result r
        JOIN Student s ON r.student_id = s.student_id
        JOIN Course  c ON r.course_id  = c.course_id
        WHERE r.grade = 'F'
    """)
    dept_stats = query("""
        SELECT d.dept_name,
               COUNT(DISTINCT s.student_id) AS students,
               ROUND(AVG(r.marks_obtained), 1) AS avg_marks,
               SUM(CASE WHEN r.grade='F' THEN 1 ELSE 0 END) AS failures
        FROM Department d
        LEFT JOIN Student s ON s.dept_id = d.dept_id
        LEFT JOIN Result  r ON r.student_id = s.student_id
        GROUP BY d.dept_id
    """)
    grade_dist = query("""
        SELECT grade, COUNT(*) AS count FROM Result GROUP BY grade ORDER BY count DESC
    """)
    return jsonify({
        "counts": counts,
        "pass_rate": pass_rate.get('rate', 0),
        "top_students": top,
        "failed_students": failed,
        "dept_stats": dept_stats,
        "grade_dist": grade_dist
    })

# ─── RUN ────────────────────────────────────────────────────
if __name__ == '__main__':
    print("✅ Flask server running at http://localhost:5000")
    app.run(debug=True, port=5000)
