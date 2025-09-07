import google.generativeai as genai
import ast

# Google Gemini API Key
GOOGLE_API_KEY = 'AIzaSyDccusL4N2Em9y8z3iD_WjzmyzCDLKVdzo'

# Configure the Google Gemini API
genai.configure(api_key=GOOGLE_API_KEY)

# Set model variable
model = None
# Find the model that supports content generation
for m in genai.list_models():
    if 'generateContent' in m.supported_generation_methods:
        print(m.name)   
        model = genai.GenerativeModel('gemini-1.5-flash')
        break


def generate_gemini_response(prompt):
    # Add context related to career development and job-related queries
    context_prompt = f"This conversation is about career guidance system {prompt}"
    # Generate response using the model
    response = model.generate_content(context_prompt)
    return response.text


def gpt_score_answer(user_answer, question, correct_answer):
    prompt = f"""
Question: {question}
Correct answer: {correct_answer}
User answer: {user_answer}

Rate the user answer correctness on a scale of 0 to 100 based on how semantically similar or correct it is compared to the correct answer.
Only provide the numeric score.
"""
    response = model.generate_content(prompt)
    # The API response text is in response.text, parse the float from it
    text = response.text.strip()
    try:
        score = float(text)
    except ValueError:
        # If parsing fails, log and fallback to 0 or some default
        print(f"Could not parse score from response: '{text}'")
        score = 0.0
    return score


# def gpt_course_classifier(courses):
#     context_prompt = f"""
#     This is a list of courses and their IDs: {courses}.
#     Classify them into bio-science, computer-science, commerce, humanities.
#     Return ONLY a Python dictionary like:
#     {{
#         "bio-science": [12, 13, 14],
#         "computer-science": [1, 2, 3],
#         ...
#     }}
#     """
#     response = model.generate_content(context_prompt)
#     try:
#         return ast.literal_eval(response.text)
#     except Exception:
#         return {}

#-------------------------respective fields courses---------------------------
# import ast
# import re
# def gpt_course_classifier(courses):
#     context_prompt = f"""
#     You are given a list of courses: {courses}

#     Task: Classify them into one of the following categories:
#     - "bio-science"
#     - "computer-science"
#     - "commerce"
#     - "humanities"
#     - "management"

#     Return ONLY a valid Python dictionary in this exact format:
#     {{
#         "bio-science": [course_ids],
#         "computer-science": [course_ids],
#         "commerce": [course_ids],
#         "humanities": [course_ids],
#         "management": [course_ids]
#     }}

#     Do not return any explanation, code blocks, or extra text.
#     """
#     response = model.generate_content(context_prompt)

#     text = response.text.strip()

#     match = re.search(r"\{[\s\S]*\}", text)
#     if match:
#         dict_str = match.group(0)
#         try:
#             print(dict_str,'iiiiiiiiiiiiiiiiiiiiiii')
#             return ast.literal_eval(dict_str)
#         except Exception as e:
#             print("Eval error:", e)

#     return {}
#-----------------------------------------------------------
import re
import ast

def gpt_course_classifier(courses):
    """
    Classify courses according to 12th-grade background.
    
    Rules:
    - Bio-science students: MBBS, BDS, BSc Nursing, BPharm, BPT + optional BBA/BA/MBA/Management courses
    - Computer-science students: BSc/BTech CS, AI, Data Science, Software Eng, BTech branches + optional BBA/BA/MBA/Management courses
    - Commerce students: BCom, BBA, BA + optional Management courses
    - Humanities students: BA, BBA + optional Management courses
    - Management courses (MBA, PGDM) are open to all streams
    """
    
    context_prompt = f"""
    You are given a list of courses: {courses}

    Task: For each 12th-grade stream (bio-science, computer-science, commerce, humanities),
    return all course IDs that a student with that background can realistically take.
    Include management courses (MBA, PGDM) for all streams.

    Return ONLY a Python dictionary like:
    {{
        "bio-science": [list of course_ids],
        "computer-science": [list of course_ids],
        "commerce": [list of course_ids],
        "humanities": [list of course_ids]
    }}
    Do not include code blocks or explanations.
    """

    response = model.generate_content(context_prompt)
    text = response.text.strip()

    # Extract dictionary using regex
    match = re.search(r"\{[\s\S]*\}", text)
    if match:
        dict_str = match.group(0)
        print(dict_str,'iiiiiiiiiiiiiiiiiiiiiiiiiiiiiii')
        try:
            return ast.literal_eval(dict_str)
        except Exception as e:
            print("Eval error:", e)

    # Fallback empty dict
    return {}


# def gpt_job_recomendation(course_name, top_score):
#     prompt = f""" The participant scored {top_score} in the course {course_name}. Based on this performance, suggest 3 to 5 job roles that are most relevant to this course. Also provide a short explanation of why each role is suitable, and mention the key skills they should focus on to get hired.
# """
#     response = model.generate_content(prompt)
#     # The API response text is in response.text, parse the float from it
#     text = response.text.strip()
#     print(text,'gggggggggggggggggggg')
#     return text

def gpt_job_recomendation(course_name, top_score):
    prompt = f"""
    A participant scored **{top_score}** in the course **{course_name}**.

    Generate **3–5 job recommendations** in a **mobile-friendly, markdown format** for display in an app.

    Formatting rules:
    - Each job role starts with 🔹 **Job Role: [Role Name]**
    - Add a short line for **Why** (max 1 sentence).
    - Add a short line for **Key Skills** (3–5 skills, comma-separated).
    - Use simple, encouraging, and easy-to-read language.
    - No long paragraphs, no extra explanations, no repeated text.
    
    Example format:
    🔹 **Job Role:** Data Analyst  
    Why: Works with data to find insights.  
    Key Skills: Excel, SQL, Python, Visualization.  

    Now generate the job recommendations for this participant.
    """
    
    response = model.generate_content(prompt)
    return response.text.strip()
