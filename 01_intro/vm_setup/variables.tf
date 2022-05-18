variable "project" { }

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Region for GCP resources."
}

variable "zone" {
  type        = string
  default     = "us-central1-c"
  description = "Zone for GCP resources."
}

variable "storage_class" {
  type        = string
  default     = "STANDARD"
  description = "Storage class type for bucket."
}


variable "COMPUTE_VM" {
  type        = string
  default     = "mlops-compute-vm"
  description = "Compute Engine for deploying resources."
}