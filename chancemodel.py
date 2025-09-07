import pandas as pd
import mysql.connector
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestRegressor
import joblib

# Connect to DB and fetch last admission details
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="CareerGuidanceandCollegeAdmissionChancesPredictionSystem"
)
cursor = db.cursor(dictionary=True)

query = """
SELECT lad.id, lad.marks_starting, lad.marks_ending, 
       c.course, d.department, col.name as college
FROM guidanceapp_lastadmissiondetails lad
JOIN guidanceapp_courserequest cr ON lad.course_request_id = cr.id
JOIN guidanceapp_course c ON cr.course_id = c.id
JOIN guidanceapp_department d ON c.department_id = d.id
JOIN guidanceapp_college col ON cr.college_id = col.id
"""
cursor.execute(query)
data = cursor.fetchall()
df = pd.DataFrame(data)

# Mapping stream to courses
def course_list_parsing(data, users_course):

    stream_to_courses = data

def generate_admission_chance(row, marks):
    start = row['marks_starting']
    end = row['marks_ending']
    if marks >= end:
        return 100.0
    elif marks >= start:
        return 90.0 + (marks - start) / (end - start) * 10
    else:
        diff = start - marks
        return max(0, 70 - diff * 5)

def train_model():
    rows = []
    for idx, row in df.iterrows():
        for marks in range(0, 101, 5):
            chance = generate_admission_chance(row, marks)
            rows.append({
                "marks": marks,
                "course": row['course'],
                "department": row['department'],
                "college": row['college'],
                "chance": chance
            })

    train_df = pd.DataFrame(rows)
    le_course = LabelEncoder()
    train_df['course_enc'] = le_course.fit_transform(train_df['course'])
    le_department = LabelEncoder()
    train_df['department_enc'] = le_department.fit_transform(train_df['department'])
    le_college = LabelEncoder()
    train_df['college_enc'] = le_college.fit_transform(train_df['college'])

    X = train_df[['marks', 'course_enc', 'department_enc', 'college_enc']]
    y = train_df['chance']

    model = RandomForestRegressor(n_estimators=100, random_state=42)
    model.fit(X, y)

    joblib.dump(model, 'admission_model.pkl')
    joblib.dump(le_course, 'le_course.pkl')
    joblib.dump(le_department, 'le_department.pkl')
    joblib.dump(le_college, 'le_college.pkl')

    print("Model trained and saved!")

def predict(marks, course, college):
    model = joblib.load('admission_model.pkl')
    le_course = joblib.load('le_course.pkl')
    le_department = joblib.load('le_department.pkl')
    le_college = joblib.load('le_college.pkl')

    department = df[df['course'] == course]['department'].iloc[0]

    try:
        course_enc = le_course.transform([course])[0]
        department_enc = le_department.transform([department])[0]
        college_enc = le_college.transform([college])[0]
    except ValueError as e:
        print(f"Encoding error: {e}")
        return None

    features = pd.DataFrame([[marks, course_enc, department_enc, college_enc]],
                            columns=['marks', 'course_enc', 'department_enc', 'college_enc'])
    chance = model.predict(features)[0]
    return chance

if __name__ == "__main__":
    # Train model first (run only once or when data updates)
    train_model()

    student_stream = input("Enter your current stream (science, commerce, humanities): ").strip().lower()
    if student_stream not in stream_to_courses:
        print("Invalid stream!")
        exit()

    # List eligible courses for the stream
    courses_list = stream_to_courses[student_stream]
    print("\nEligible courses for your stream:")
    for i, c in enumerate(courses_list, 1):
        print(f"{i}. {c}")

    try:
        choice = int(input("Select a course by number: "))
        if choice < 1 or choice > len(courses_list):
            print("Invalid choice!")
            exit()
    except ValueError:
        print("Enter a valid number!")
        exit()

    selected_course = courses_list[choice - 1]
    marks = float(input("Enter your marks (out of 100): "))

    # Find all colleges offering the course
    colleges = df[df['course'] == selected_course]['college'].unique()
    if len(colleges) == 0:
        print(f"No colleges found offering {selected_course}")
        exit()

    print(f"\nAdmission chances for course '{selected_course}':")
    for college in colleges:
        chance = predict(marks, selected_course, college)
        if chance is not None:
            print(f"College: {college}, Predicted Chance: {chance:.2f}%")
        else:
            print(f"Prediction failed for college: {college}")
