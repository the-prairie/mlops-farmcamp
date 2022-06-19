variable "artifacts_bucket_name" {
  description = "Name of the mlflow bucket created to store artifacts"
  type        = string
}
variable "artifacts_bucket_location" {
  description = "Location of the mlflow artifact bucket deployed"
  type        = string
  default     = "EUROPE-WEST1"
}
variable "artifacts_number_of_version" {
  description = "Number of file version kept in your artifacts bucket"
  type        = number
  default     = 1
}
variable "artifacts_storage_class" {
  description = "Storage class of your artifact bucket"
  type        = string
  default     = "STANDARD"
}
variable "db_username" {
  description = "Value of the database username"
  type        = string
  default     = "admin"
}
variable "db_instance_prefix" {
  description = "prefix used as database instance name"
  type        = string
  default     = "mlflow"
}
variable "db_version" {
  description = "Database instance version in GCP"
  type        = string
  default     = "POSTGRES_14"
}
variable "db_region" {
  description = "Database region"
  type        = string
  default     = "us-central1"
}
variable "db_size" {
  description = "Database instance size"
  type        = string
  default     = "db-f1-micro"
}
variable "db_availability_type" {
  description = "Availability of your database"
  type        = string
  default     = "ZONAL"
}
variable "db_name" {
  description = "Name of the database created inside the instance"
  type        = string
  default     = "mlflow"
}

variable "docker_image" {
  description = "Docker image name of your mlflow server"
  type        = string
}

variable "project_id" {
  description = "GCP project"
  type        = string
}
variable "region" {
  description = "GCP region to deploy the Cloud Run service"
  type        = string
  default     = "us-central1"
}

variable "network_self_link" {
  type = string
}
variable "network_short_name" {}

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

variable "db_depends_on" {
  description = "Resources that database depends on for creation"
  type = any
  
}

variable "service_account_name" {
  description = "Name of service account to create"
  
}

variable "vpc_connector_name" {
  type = any
  description = "VPC connector for cloud SQL"
  
}