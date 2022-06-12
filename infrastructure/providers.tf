provider "google" {
  project = var.gcp_project_name
  region  = var.gcp_region_name
  zone    = "${var.gcp_region_name}-a"
}