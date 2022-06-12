output "connection_name" {
  description = "The connection string used by Cloud SQL Proxy, e.g. my-project:us-central1:my-db"
  value       = google_sql_database_instance.main.connection_name
}

output "postgres_db_password" {
 value = random_password.this.result
 sensitive = true
}