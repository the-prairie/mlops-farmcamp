terraform {
    required_version = ">= 0.15.3"
    backend "gcs" {
    bucket  = "tf-state-mlops"
    prefix  = "terraform/state"
    }
    required_providers {
      google = {
          source = "hashicorp/google"
      }
      tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
      }
    }
}

provider "google" {
    project = var.project
    region = var.region
    
}

// Retrieve email address for the currently authenticated user
// Use this to tell Google Cloud to add the public key to our IAM user
data "google_client_openid_userinfo" "me" {}

resource "google_os_login_ssh_public_key" "cache" {
  project = var.project
  user = data.google_client_openid_userinfo.me.email
  key  = file("~/.ssh/prtygrl.pub")
}


// Make sure that the IAM user is allowed to use OS Login
// If you are project owner or editor, this role is configured automatically
resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/compute.osAdminLogin"
  member  = "user:${data.google_client_openid_userinfo.me.email}"
}



resource "google_project_service" "cloud_resource_manager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = true
}

resource "google_project_service" "compute" {
  service            = "compute.googleapis.com"
  disable_on_destroy = true
}

# Create VPC

resource "google_compute_network" "vpc_network" {
  name = "mlops-farmcamp"
}


resource "google_compute_address" "static_ip" {
  name = "mlops-ubuntu-vm"
}

resource "google_compute_firewall" "allow_ssh" {
  name          = "allow-ssh"
  network       = google_compute_network.vpc_network.name
  target_tags   = ["allow-ssh"] // this targets our tagged VM
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}



# Compute Engine
resource "google_service_account" "default" {
  account_id   = "${var.COMPUTE_VM}-${var.project}"
  display_name = "Service Account"
}

resource "google_compute_instance" "ubuntu_vm" {
  name         = var.COMPUTE_VM
  machine_type = "e2-standard-4"
  zone         = var.zone

  tags = ["vm", "mlops-farmcamp", "allow-ssh"] // recieves firewall rule

  metadata = {
    enable-oslogin: "TRUE"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-pro-cloud/ubuntu-pro-2204-lts"
      size = 50 // GB
      type = "pd-balanced"
      
    }
  }

  allow_stopping_for_update = true


  network_interface {
    network = google_compute_network.vpc_network.name

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = "${file("./install.docker.sh")}"


}

output "public_ip" {
  value = google_compute_address.static_ip.address
}
