
resource "google_compute_network" "vpc" {
  name                    = var.name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}


resource "google_compute_subnetwork" "public_subnet" {
  name          = "${var.project_name}-public-subnet"
  ip_cidr_range = var.public_subnet
  network       = google_compute_network.vpc.self_link
  region        = var.region_name
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "${var.project_name}-private-subnet"
  ip_cidr_range = var.private_subnet
  network       = google_compute_network.vpc.self_link
  region        = var.region_name
}


# We need to allocate an IP block for private IPs. We want everything in the VPC
# to have a private IP. This improves security and latency, since requests to
# private IPs are routed through Google's network, not the Internet.
resource "google_compute_global_address" "private_ip_block" {
  name         = "private-ip-block"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  prefix_length = 20 # ~4,000 IPs
  network       = google_compute_network.vpc.self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_block.name]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "${var.project_name}-fw-allow-internal"
  network = google_compute_network.vpc.name
  direction = "INGRESS"
  
  allow {
    protocol = "icmp"
    }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = [google_compute_subnetwork.private_subnet.ip_cidr_range]

  
}


resource "google_compute_firewall" "allow-http" {
  name    = "${var.project_name}-fw-allow-http"
  network = google_compute_network.vpc.name
  direction = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["80", "4200", "4040", "5000"]
    }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http-enabled"] 
  
}

resource "google_compute_firewall" "allow-bastion" {
  name    = "${var.project_name}-fw-allow-bastion"
  network = google_compute_network.vpc.name
  direction   = "INGRESS"
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ssh-enabled"]
}