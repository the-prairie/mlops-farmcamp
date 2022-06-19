variable "project_id" {
  description = "GCP project"
  type        = string
}
variable "region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}
variable "artifacts_bucket" {
  description = "GCS bucket used to store your artifacts"
  type        = string
  default     = "oneclick-mlflow-store"
}
variable "mlflow_docker_image" {
  description = "Docker image used in container registry"
  type        = string
}
variable "network_name" {
  type        = string
  description = "Name of the network to attach to. If empty, a new network will be created"
}
variable "storage_uniform" {
  type        = bool
  description = "Wether or not uniform level acces is to be activated for the buckets"
  default     = true
}
variable "mlflow_server" {
  description = "Name of the mlflow server deployed to app engine. If a service already have this name, it will be overwritten."
  type        = string
  default     = "mlflow"
}
variable "oauth_client_id" {
  type        = string
  description = "Oauth client id, empty if consent screen not set up"
}
variable "oauth_client_secret" {
  type        = string
  description = "Oauth client secret, empty if consent screen not set up"
}
variable "oauth2_proxy_config_secret" {
  type        = string
  description = "Name of secret with oauth2 proxy config saved"
}


variable "service_account_name" {
  description = "Name of service account to create"

}