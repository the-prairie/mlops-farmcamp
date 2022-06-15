output "url" {
    description = "The URL of the bucket in format gs://<bucket-name>"
    value = google_storage_bucket.bucket.url
}

output "name" {
  description = "gcs bucket name"
  value       = google_storage_bucket.bucket.name
}