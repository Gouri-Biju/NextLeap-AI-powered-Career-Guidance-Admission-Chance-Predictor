import pandas as pd
import mysql.connector
import ast
from guidanceapp.Geminiapi import gpt_course_classifier

# ---------------- DATABASE CONNECTION ----------------
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="CareerGuidanceandCollegeAdmissionChancesPredictionSystem"
)
cursor = db.cursor(dictionary=True)

# ---------------- FETCH ALL COURSES ----------------
cursor.execute("""
    SELECT c.id as course_id, c.course as course_name, d.department as department_name
    FROM guidanceapp_course c
    JOIN guidanceapp_department d ON c.department_id = d.id
""")
courses = cursor.fetchall()

# Prepare list for Gemini
course_list = [
    {
        "course_id": c["course_id"],
        "course_name": c["course_name"],
    }
    for c in courses
]

# ---------------- CLASSIFY COURSES INTO STREAMS ----------------
stream_map = gpt_course_classifier(course_list)

# ---------------- FETCH LAST ADMISSION DATA ----------------
query = """
SELECT lad.id, lad.marks_starting, lad.marks_ending, 
       c.id as course_id, c.course, d.department, col.name
FROM guidanceapp_lastadmissiondetails lad
JOIN guidanceapp_courserequest cr ON lad.course_request_id = cr.id
JOIN guidanceapp_course c ON cr.course_id = c.id
JOIN guidanceapp_department d ON c.department_id = d.id
JOIN guidanceapp_college col ON cr.college_id = col.id
"""
cursor.execute(query)
data = cursor.fetchall()
df = pd.DataFrame(data)

# ---------------- USER INPUT ----------------
student_marks = float(input("Enter your marks: "))
student_stream = input("Enter your stream (bio-science, computer-science, commerce, humanities, management): ").strip().lower()

if student_stream not in stream_map:
    print("Invalid stream entered!")
    exit()

# ---------------- FILTER COURSES BY STREAM ----------------
allowed_course_ids = stream_map[student_stream]
filtered_df = df[df['course_id'].isin(allowed_course_ids)]

if filtered_df.empty:
    print("\nNo courses found for this stream in the database.")
    exit()

# Show course options
print("\nAvailable Courses in Your Stream:")
unique_courses = filtered_df[['course_id', 'course']].drop_duplicates()
for i, row in enumerate(unique_courses.itertuples(index=False), 1):
    print(f"{i}. {row.course}")

# Ask for course choice
try:
    choice = int(input("\nEnter the course number: "))
    if choice < 1 or choice > len(unique_courses):
        print("Invalid choice!")
        exit()
except ValueError:
    print("Please enter a valid number.")
    exit()

selected_course_id = unique_courses.iloc[choice - 1]['course_id']
selected_course = unique_courses.iloc[choice - 1]['course']
filtered_df = filtered_df[filtered_df['course_id'] == selected_course_id]

# ---------------- CHANCE CALCULATION ----------------
def calculate_chance(row):
    start = row['marks_starting']
    end = row['marks_ending']

    if student_marks >= end:
        return 100.0  # above highest past admission mark
    elif student_marks >= start:
        return 90.0 + (student_marks - start) / (end - start) * 10
    else:
        diff = start - student_marks
        return max(0, 70 - diff * 5)

filtered_df['chance'] = filtered_df.apply(calculate_chance, axis=1)

# ---------------- SORT ----------------
final_df = filtered_df.sort_values(by="chance", ascending=False)

# ---------------- OUTPUT ----------------
print("\n===== Admission Prediction =====")
for _, row in final_df.iterrows():
    print(f"College: {row['name']}, Course: {row['course']}, Chance: {row['chance']:.2f}%")

# ---------------- SAVE TO CSV ----------------
final_df.to_csv("admission_predictions.csv", index=False)
print("\nResults saved to admission_predictions.csv")
