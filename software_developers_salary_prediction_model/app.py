import streamlit as st
import pickle
import numpy as np

def load_model():
    with open('model.pkl', 'rb') as file:
        data = pickle.load(file)
    return data

data = load_model()

regressor_loaded = data["model"]
new_Country = data["new_Country"]
new_Age = data["new_Age"]
new_EdLevel = data["new_EdLevel"]
new_Industry = data["new_Industry"]

def predict_salary():
    st.title("Software Developer Salary Prediction App")
    st.write("This app predicts the salary of a software developer based on various features.")
    st.write("### Please enter the following details:")

    countries = (
        "Argentina",
        "Australia",
        "Austria",
        "Belgium",
        "Brazil",
        "Bulgaria",
        "Canada",
        "Czech Republic",
        "Denmark",
        "Finland",
        "France",
        "Germany",
        "Greece",
        "Hungary",
        "India",
        "Ireland",
        "Israel",
        "Italy",
        "Japan",
        "Mexico",
        "Netherlands",
        "New Zealand",
        "Norway",
        "Poland",
        "Portugal",
        "Romania",
        "Russian Federation",
        "South Africa",
        "Spain",
        "Sweden",
        "Switzerland",
        "Turkey",
        "Ukraine",
        "United Kingdom of Great Britain and Northern Ireland",
        "United States of America",
        "Other Countries"
    )

    age = (
        "18-24",
        "25-34", 
        "35-44",          
        "45-54",
        "55-64", 
        "65+",
        "Prefer not to say"
    )

    education = ( 
        "Less than a Bachelors", 
        "Bachelor’s Degree",
        "Post Grad",
        "Master’s Degree"
    )

    industry = (
        "Banking/Financial Services",
        "Computer Systems Design and Services",
        "Energy",
        "Fintech",
        "Government",
        "Healthcare",
        "Higher Education",
        "Insurance",
        "Internet, Telecomm or Information Services",
        "Manufacturing",
        "Media & Advertising Services",
        "Retail and Consumer Services",
        "Software Development",
        "Transportation, or Supply Chain",
        "Other:"
    )

    country = st.selectbox("Country", countries)
    age = st.selectbox("Age", age)
    education = st.selectbox("Education Level", education)
    experience = st.slider("Years of Experience", 0, 100, 0)
    industry = st.selectbox("Industry", industry)

    ok = st.button("Estimate Salary")
    if ok:
        X_test = np.array([[country, age, education, experience, industry]])
        X_test[:, 0] = new_Country.transform(X_test[:,0])
        X_test[:, 1] = new_Age.transform(X_test[:,1])
        X_test[:, 2] = new_EdLevel.transform(X_test[:,2])
        X_test[:, 4] = new_Industry.transform(X_test[:,4])
        X_test = X_test.astype(float)

        salary = regressor_loaded.predict(X_test)
        st.success(f"The estimated salary is: ${salary[0]:,.2f}")

predict_salary()   

