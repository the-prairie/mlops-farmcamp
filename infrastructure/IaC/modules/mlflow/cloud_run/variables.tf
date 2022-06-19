variable "name" {
  description = "Name of the Cloud Run service"
  type        = string
  default     = "mlflow"
}

variable "region" {
  description = "GCP region to deploy the Cloud Run service"
  type        = string
  default     = "us-central1"
}

variable "docker_image" {
  description = "URL of the docker image pushed to Google Cloud Registry"
  type        = string
}

variable "db_connection_secret" {
  description = "Connection string to the database. To be set as BACKEND_STORE_URI"
  type        = string
}


variable "db_connection_name" {
  description = "Name of the Cloud SQL database."
  type        = string
}


variable "oauth2_proxy_config_secret" {
  description = "Configuration for the OAuth2-Proxy"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the mlflow bucket created to store artifacts"
  type        = string
}

variable "service_account_name" {
  type = string
  description = "Name of service account"
  
}

variable "vpc_connector_name" {
  type = any
  description = "VPC connector for cloud SQL"
  
}

variable "cloudrun_cpu" {
  description = "Amt of cpu for the cloudrun - service "
  type        = string
  default     = "1000m" 
}

variable "cloudrun_memory" {
  description = "Amt of memory for the cloudrun - service"
  type        = string
  default     = "1Gi"
}

