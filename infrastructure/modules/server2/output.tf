output "server2_out_public_subnet_name" {
  value       = google_compute_subnetwork.public_subnet.self_link
  description = "The URI of the VPC network-02"
}


output "server2_out_private_subnet_name" {
  value       = google_compute_subnetwork.private_subnet.self_link
  description = "The URI of the VPC network-02"
}