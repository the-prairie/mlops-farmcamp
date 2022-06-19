resource "google_service_account" "service_account" {
  project      = var.project_id
  account_id   = "${var.name}"
  display_name = "${title(var.name)} Service Account"
}


resource "google_project_iam_member" "project" {
  count                      = length(var.roles)
  project = var.project_id
  role    = var.roles[count.index]
  member  = "serviceAccount:${google_service_account.service_account.email}"
}
