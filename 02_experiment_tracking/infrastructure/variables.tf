variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "mlops-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "20.10.0.0/16"
}

variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "vpc_private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["20.10.1.0/24", "20.10.2.0/24"]
}

variable "vpc_database_subnets" {
  description = "Database subnets for VPC"
  type        = list(string)
  default     = ["20.10.21.0/24", "20.10.22.0/24"]
}


variable "vpc_public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["20.10.11.0/24", "20.10.12.0/24"]
}

variable "vpc_enable_nat_gateway" {
  description = "Enable NAT gateway for VPC"
  type        = bool
  default     = false
}

variable "vpc_tags" {
  description = "Tags to apply to resources created by VPC module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "prod"
  }
}

variable "sg_tags" {
  description = "Tags to apply to resources created by security group module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "prod"
  }
}

variable "rds_tags" {
  description = "Tags to apply to resources created by security group module"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "prod"
  }
}

variable "s3_tags" {
  description = "Tags to apply to S3 bucket"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "prod"
  }
}

variable "port" {
  description = "Port for PostgreSQL database"
  type        = string
  default     = "5432"
}