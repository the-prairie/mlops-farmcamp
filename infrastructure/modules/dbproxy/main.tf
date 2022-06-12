
data "google_compute_subnetwork" "regional_subnet" {
  name   = var.vpc_name
  region = var.region_name
}

resource "google_compute_instance" "db_proxy" {
  name                      = "db-proxy"
  description               = <<-EOT
    A public-facing instance that proxies traffic to the database. This allows
    the db to only have a private IP address, but still be reachable from
    outside the VPC.
  EOT
  machine_type              = "f1-micro"
  zone                      = var.zone
  desired_status            = "RUNNING"
  allow_stopping_for_update = true

  depends_on = [var.db_proxy_depends_on]
  
  

  # Our firewall looks for this tag when deciding whether to allow SSH traffic
  # to an instance.
  tags = ["ssh-enabled"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable" 
      size  = 10                
      type  = "pd-ssd"             
    }
  }
  metadata = {
    enable-oslogin = "TRUE"
  }
  metadata_startup_script = templatefile("${path.module}/run_cloud_sql_proxy.tpl", {
    "db_instance_name"    = var.db_instance_name,
    "service_account_key" = var.service_account_private_key,
  })

  network_interface {
    network    = var.vpc_name
    subnetwork = data.google_compute_subnetwork.regional_subnet.self_link 

    # The access_config block must be set for the instance to have a public IP,
    # even if it's empty.
    access_config {}
  }

  scheduling {
    # Migrate to another physical host during OS updates to avoid downtime.
    on_host_maintenance = "MIGRATE"
  }
  service_account {
    email = var.service_account_email
    # These are OAuth scopes for the various Google Cloud APIs. We're already
    # using IAM roles (specifically, Cloud SQL Editor) to control what this
    # instance can and cannot do. We don't need another layer of OAuth
    # permissions on top of IAM, so we grant cloud-platform scope to the
    # instance. This is the maximum possible scope. It gives the instance
    # access to all Google Cloud APIs through OAuth.
    scopes = ["cloud-platform"]
  }
}
