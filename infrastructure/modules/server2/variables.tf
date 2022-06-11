variable "region_name" {
  default = "us-east1"
}


variable "company" {
    type = string
}

variable "env" {
    type = string
}

variable "subnetwork2" {
    type = string
}
variable "server2_private_subnet" {
  type = string
}
variable "server2_public_subnet" {
  type = string
}

variable "network_self_link" {
   type = string 
  }  