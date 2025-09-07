# geminiapi.py
import os
import json
import google.generativeai as genai

# Configure Gemini API
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyBQNP60L_SVXniGmLQLupaNc3cMtmjAg-c")
genai.configure(api_key=GEMINI_API_KEY)

def get_course_suggestions(user_stream, courses, departments):
    """
    Ask Gemini to recommend courses based on user's stream.
    Returns a Python list of course names.
    """
    prompt = f"""
    A student has completed: {user_stream}.
    Available courses: {', '.join(courses)}.
    Departments: {', '.join(departments)}.

    Suggest only the  suitable course names as a plain JSON list without extra text.
    Example: ["BSc Computer Science", "BSc Mathematics"]
    """

    model = genai.GenerativeModel("gemini-1.5-flash")
    response = model.generate_content(prompt)

    try:
        return json.loads(response.text)
    except json.JSONDecodeError:
        return []

