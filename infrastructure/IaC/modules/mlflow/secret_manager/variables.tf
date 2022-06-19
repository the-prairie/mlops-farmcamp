variable "secret_id" {
  type        = string
  description = "Name of the secret you want to create"
}
variable "module_depends_on" {
  type    = any
  default = null
}

variable "secret_data" {
  type = any
  description = "Value of the secret being stored."
  
}