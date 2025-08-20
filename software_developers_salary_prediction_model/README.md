## Software Developer Salary Prediction
This project uses the [Stack Overflow 2025 Developer Survey](https://survey.stackoverflow.co/) dataset to build a simple machine learning model that predicts developer salaries based on a few key features. The goal was to create a lightweight app where users can input basic information and get a salary estimate.


## Description
I started the project with data preprocessing where I cleaned the data by handling missing values, outliers, grouping countries with low respondents, and encoding categorical features. I tested Linear Regression, Decision Tree, and Random Forest and settled on the grid-searched Decision Tree as the best model.

**Features used:** Country, Age, Education Level, Years of Coding Experience, Industry.


## Data Source
The dataset is from the Stack Overflow 2025 Developer Survey: https://survey.stackoverflow.co/.


## Deployment
The app is deployed on Streamlit Community Cloud: https://software-dev-salary-prediction.streamlit.app/.


## Local Setup
1. Clone the repo.
2. Install requirements: `pip install -r requirements.txt`.
3. Run the app: streamlit run `app.py`.
4. For the notebook: Open `salary_prediction.ipynb` in Jupyter.

## Technologies
1. Python (pandas, scikit-learn, Streamlit)
2. Model saved with pickle.
