# chance_prediction.py
import os
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier

MODEL_PATH = "chance_predictor.pkl"

def train_model(df):
    """
    Train the ML model from a dataframe.
    df must contain: ['marks', 'last_year_cutoff', 'chance']
    """
    X = df[['marks', 'last_year_cutoff']]
    y = df['chance']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    model = RandomForestClassifier(random_state=42)
    model.fit(X_train, y_train)

    joblib.dump(model, MODEL_PATH)
    print(f"Model trained and saved to {MODEL_PATH}")

def predict_chance(marks, last_year_cutoff):
    """
    Predict admission chance using trained RandomForestClassifier.
    """
    if not os.path.exists(MODEL_PATH):
        raise FileNotFoundError("Model not found. Train the model first.")

    model = joblib.load(MODEL_PATH)
    prediction = model.predict([[marks, last_year_cutoff]])[0]
    return "High Chance" if prediction == 1 else "Low Chance"
