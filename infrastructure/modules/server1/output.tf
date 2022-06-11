output "server1_out_public_subnet_name" {
  value       = google_compute_subnetwork.public_subnet.self_link
  description = "The URI of the VPC network-01"
}


output "server1_out_private_subnet_name" {
  value       = google_compute_subnetwork.private_subnet.self_link
  description = "The URI of the VPC network-01"
}

output "static_ip" {
  value = google_compute_address.static_ip.address
}

output "postgres_db_password" {
 value = random_password.this.result
 sensitive = true
}
