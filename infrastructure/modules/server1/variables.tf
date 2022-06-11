variable "region_name" {
  default = "us-central1"
}

variable "db_username" {
  default = "mlops"
  
}

variable "company" {
    type = string
}

variable "env" {
    type = string
}

variable "subnetwork1" {
    type = string
}

variable "server1_private_subnet" {
  type = string
}
variable "server1_public_subnet" {
  type = string
}

variable "network_self_link" {
   type = string 
  }  