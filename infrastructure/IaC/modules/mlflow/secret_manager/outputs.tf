output "secret_value" {
  description = "Value of the created secret"
  value       = google_secret_manager_secret_version.secret_version.secret_data
  sensitive   = true
}

output "secret_name" {
  description = "Name of the created secret"
  value       = google_secret_manager_secret.secret.name
}


output "secret_id" {
  description = "ID of the created secret"
  value       = google_secret_manager_secret.secret.secret_id
}