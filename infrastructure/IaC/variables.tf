variable "project_id" {
  description = "GCP project"
  type        = string
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
variable "consent_screen_support_email" {
  type        = string
  description = "Person or group to contact in case of problem (address shown in the OAuth consent screen)"
}
variable "web_app_users" {
  type        = list(string)
  description = "List of people who can acess the mlflow web app. e.g. [user:jane@example.com, group:people@example.com]"
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
variable "create_default_service" {
  description = "Whether or not to deploy a default AppEngine App"
  type        = number
}
variable "oauth_client_id" {
  type        = string
  description = "Oauth client id, empty if consent screen not set up"
}
variable "oauth_client_secret" {
  type        = string
  description = "Oauth client secret, empty if consent screen not set up"
}
variable "create_brand" {
  type        = number
  description = "1 if the brand needs to be created 0 otherwise"
}
variable "brand_name" {
  type        = string
  default     = ""
  description = "Name of the brand if it exists"
}