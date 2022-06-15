
DB_PASSWORD=$(gcloud beta secrets versions access --project=${GCP_PROJECT} --secret=${DB_PASSWORD_NAME} latest)
BACKEND_URI=postgresql://${DB_USERNAME}:${DB_PASSWORD}@${DB_PRIVATE_IP}:3306/${DB_NAME}

mlflow db upgrade ${BACKEND_URI}

mlflow server \
  --backend-store-uri ${BACKEND_URI} \
  --default-artifact-root ${GCS_BACKEND} \
  --host 0.0.0.0 \
  --port ${PORT}