variable "location" {
  type        = string
  description = "Location to deploy your server"
  default     = "us-central1"
}
variable "docker_image_name" {
  type        = string
  description = "Name of the docker image"
}
variable "env_variables" {
  type        = map(any)
  description = "Env variable to be used in your container"
}
variable "project_id" {
  description = "GCP project"
  type        = string
}
variable "db_password_name" {
  description = "Name of the db password stored in secret manager"
  type        = string
}
variable "db_username" {
  description = "Username used to connect to your db"
  type        = string
}
variable "db_name" {
  description = "Name of the database"
  type        = string
}
variable "db_instance" {
  description = "Name of the database instance"
  type        = string
}
variable "gcs_backend" {
  description = "Gcs bucket used for artifacts"
  type        = string
}
variable "db_private_ip" {
  type        = string
  description = "Private ip of the db"
}
variable "module_depends_on" {
  type    = any
  default = null
}
variable "consent_screen_support_email" {
  type        = string
  description = "Person or group to contact in case of problem"
}
variable "create_brand" {
  type        = number
  description = "1 if the brand needs to be created 0 otherwise"
}
variable "brand_name" {
  type        = string
  description = "Name of the brand if it exists"
}
variable "web_app_users" {
  type        = list(string)
  description = "List of people who can acess the mlflow web app. e.g. [user:jane@example.com, group:people@example.com]"
}
variable "create_default_service" {
  description = "Whether or not to create a default app engine service"
  type        = bool
}
variable "mlflow_server" {
  description = "Name of the mlflow server deployed to app engine. If a service already have this name, it will be overwritten."
  type        = string
}
variable "network_short_name" {
  type = string
}
variable "max_appengine_instances" {
  description = "The maximum number of app engine instances to scale up to"
  type        = number
  default     = 1
}
variable "min_appengine_instances" {
  description = "The minimum number of app engine instances to scale down to"
  type        = number
  default     = 1
}
variable "oauth_client_id" {
  type        = string
  description = "Oauth client id, empty if consent screen not set up"
}
variable "oauth_client_secret" {
  type        = string
  description = "Oauth client secret, empty if consent screen not set up"
}