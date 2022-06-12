// dbproxy module
variable "db_instance_name" {
  description = "The name of the Cloud SQL db, e.g. my-project:us-centra1:my-sql-db"
  type        = string
}

variable "service_account_email" {
    description = "Service account for cloud-sql-proxy"
    type = string
}
variable "service_account_private_key" {
    description = "Private key for cloud-sql-proxy service account"
    type = string
    sensitive   = true
   
}

variable "db_proxy_depends_on" {
  description = "A single resource that the cloud proxy instance depends on"
  type        = any
}

variable "project_name" {
  description = "Name of project resources belong to"
  type        = string
}

variable "region_name" {
  default     = "us-central1"
  type        = string
}

variable "zone" {
   type  = string
}


variable "vpc_name" {
  description = "The name of the VPC that the proxy instance will run in"
  type        = string
}
