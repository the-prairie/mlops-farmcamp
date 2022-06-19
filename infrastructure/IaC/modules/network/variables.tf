variable "network_name" {
  description = "Name of the VPC to create"
  type = string
}

variable "region" {
  description = "GCP region"
  type = string
  default = "us-central1"
  
}

variable "project_id" {
  description = "GCP project to create VPC in"
  type = string
}

variable "private_subnet" {
    default = "10.26.1.0/24"
}

variable "public_subnet" {
    default = "10.26.2.0/24"
}
