FROM agrigorev/zoomcamp-model:mlops-3.9.7-slim

# Install pipenv and compilation dependencies
RUN pip install -U pip
RUN pip install pipenv

WORKDIR /app

COPY [ "Pipfile", "Pipfile.lock", "./"]

# Install python dependencies to system
RUN pipenv install --system --deploy

COPY [ "scoring.py", "./"]

ENTRYPOINT [ "python", "scoring.py"]