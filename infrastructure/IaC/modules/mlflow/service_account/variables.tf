variable "project_id" {
  description = "GCP project"
  type        = string
}

variable "name" {
  type        = string
  description = "The full name of the service"
  default     = "mlops"
}

variable "roles" {
  description = "List of roles you want service account to be assigned"
  type        = list(string)
}