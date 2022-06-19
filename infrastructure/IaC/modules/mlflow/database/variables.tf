variable "instance_prefix" {
  type        = string
  description = "Name of the database instance you want to deploy"
  default     = "mlflow"
}

variable "database_version" {
  type        = string
  description = "Version of the database instance you use"
  default     = "POSTGRES_14"
}
variable "size" {
  type        = string
  description = "Size of the database instance"
  default     = "db-f1-micro"
}

variable "availability_type" {
  type        = string
  description = "Availability of your instance"
  default     = "ZONAL"
}

variable "database_name" {
  type        = string
  description = "Name of the database created"
  default     = "mlflow"
}

variable "region" {
  type        = string
  description = "Region of the database instance"
  default = "us-central1"
}

variable "username" {
  description = "The username of the db user"
  type        = string
}

variable "network_self_link" {
  description = "A link to the VPC where the db will live (i.e. google_compute_network.some_vpc.self_link)"
  type        = string
}

variable "db_depends_on" {
  description = "Resources that database depends on for creation"
  type        = any
}
