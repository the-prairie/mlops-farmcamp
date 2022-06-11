output "out_vpc_self_link" {
  value       = google_compute_network.vpc.self_link
  description = "The URI of the VPC being created"
}

