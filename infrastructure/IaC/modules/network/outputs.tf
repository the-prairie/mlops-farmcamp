output "network_self_link" {
  description = "A link to the VPC resource, useful for creating resources inside the VPC"
  value       = google_compute_network.vpc.self_link
}

output "network_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "private_vpc_connection" {
  description = "The private VPC connection"
  value       = google_service_networking_connection.private_vpc_connection
}

output "public_subnet_name" {
  value       = google_compute_subnetwork.public_subnet.self_link
  description = "The URI of the VPC public subnet"
}


output "private_subnet_name" {
  value       = google_compute_subnetwork.private_subnet.self_link
  description = "The URI of the VPC private subnet"
}

output "vpc_connector_name" {
  value = google_vpc_access_connector.connector.name
  description = "VPC Connector name"
}
