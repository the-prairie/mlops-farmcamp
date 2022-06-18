FROM python:3.9.7-slim

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Install pipenv and compilation dependencies
RUN pip install -U pip
RUN pip install pipenv


WORKDIR /app

COPY [ "Pipfile", "Pipfile.lock", "./"]

# Install python dependencies to system
RUN pipenv install --system --deploy

COPY [ "models", "models/"]
COPY [ "predict.py", "./"]

ENTRYPOINT [ "uvicorn", "predict:app", "--host", "0.0.0.0", "--port", "9696"]