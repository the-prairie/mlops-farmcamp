variable "role" {
  description = "The role assigned to the service account (e.g. roles/cloudsql.editor)"
  type        = string
}

variable "name" {
  description = "The service account name (e.g. cloud-sql-proxy)"
  type        = string
}