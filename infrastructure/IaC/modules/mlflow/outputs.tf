
output "artifacts_bucket_name" {
  value = module.artifacts.name
}

output "cloud_run_status" {
  value = module.cloud_run.cloud_run_status
}