variable "db_depends_on" {
  description = "A single resource that the database instance depends on"
  type        = any
}

variable "instance_type" {
  description = "The instance type of the VM that will run the db (e.g. db-f1-micro, db-custom-8-32768)"
  type        = string
}

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

variable "region_name" {
  type        = string
  description = "Region of the database instance"
  default = "us-central1"
}

variable "password" {
  description = "The db password used to connect to the Postgers db"
  type        = string
  sensitive   = true
}

variable "user" {
  description = "The username of the db user"
  type        = string
}

variable "vpc_link" {
  description = "A link to the VPC where the db will live (i.e. google_compute_network.some_vpc.self_link)"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC where the db will live"
  type        = string
}
