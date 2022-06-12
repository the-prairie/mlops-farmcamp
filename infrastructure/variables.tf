
variable "db_username" {
  description = "The Postgres username"
  type        = string
}

variable "gcp_project_name" {
  description = "The name of the GCP project where the db and Cloud SQL Proxy will be created"
  type        = string
}

variable "gcp_region_name" {
  description = "The GCP region where the db and Cloud SQL Proxy will be created"
  type        = string
  default     = "us-central1"
}

variable "project" {
  type    = string
  default = "mlops-00"
}