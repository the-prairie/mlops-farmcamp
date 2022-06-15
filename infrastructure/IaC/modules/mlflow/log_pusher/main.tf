resource "google_service_account" "log_pusher" {
  account_id   = "mlflow-log-pusher"
  display_name = "mlflow log pusher"
}

resource "google_iap_app_engine_service_iam_member" "log_pusher_iap" {
  project = var.project_id
  app_id  = var.app_id
  service = var.mlflow_service
  role    = "roles/iap.httpsResourceAccessor"
  member  = "serviceAccount:${google_service_account.log_pusher.email}"
}

resource "google_storage_bucket_iam_member" "log_pusher_storage" {
  bucket = var.artifacts_bucket
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.log_pusher.email}"
}