variable "project" {
        default = "mlops-00"
    }
variable "env" {
        default = "dev"
    }
variable "company" { 
        default = "farmcamp"
    }
variable "server1_private_subnet" {
        default = "10.26.1.0/24"
    }
variable "server1_public_subnet" {
        default = "10.26.2.0/24"
    }
variable "server2_private_subnet" {
        default = "10.26.3.0/24"
    }
variable "server2_public_subnet" {
        default = "10.26.4.0/24"
    }