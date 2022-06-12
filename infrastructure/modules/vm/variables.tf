variable "machine_type" {
    type = string
    default = "e2-small"
    description = "Type of machine for VM. For example e2-small, e2-micro, n2-standard"
  
}

variable "project" {
    type = string 
}

variable "region_name" {
    type = string
}

variable "image_type" {
    description = "Image type for vm"
    type = string
    default = "ubuntu-2204-lts"  
  
}

variable "public_subnet_name" {
    description = "URI for public subnet of VPC."
    type = string
  
}