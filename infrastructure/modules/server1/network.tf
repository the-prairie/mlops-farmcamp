resource "google_compute_subnetwork" "public_subnet" {
  name          =  "${format("%s","${var.company}-${var.env}-${var.region_name}-pub-net")}"
  ip_cidr_range = var.server1_public_subnet
  network       = var.network_self_link
  region        = var.region_name
}

resource "google_compute_subnetwork" "private_subnet" {
  name          =  "${format("%s","${var.company}-${var.env}-${var.region_name}-pri-net")}"
  ip_cidr_range = var.server1_private_subnet
  network      = var.network_self_link
  region        = var.region_name
}

resource "google_compute_global_address" "private_ip_block" {
  name         = "private-ip-block"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}