### *MLflow*

[See github repo here for MLflow](https://github.com/mlflow/mlflow)


### *Getting Started with MLflow*

Goals:
- Prepare local environment
- Select best model

*Prepare local environment*

Create a new virtual environment `python3 -m venv mlflow_env`

Activate and run `pip install -r requirements.txt`

Setup backend database (SQLlite DB) for MLflow -> `mlflow ui --backend-store-uri sqlite:///mlflow.db`


### *Experiment Tracking with MLflow*

Goals:
- Add parameter tuning to notebook
- Select best model

