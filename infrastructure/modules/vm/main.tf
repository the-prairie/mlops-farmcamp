
resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "default" {
  name         = "${var.project}-vm"
  machine_type  = var.machine_type
  zone          = "${var.region_name}-b"
  tags          = ["ssh-enabled","http-enabled"]
  boot_disk {
    initialize_params {
      image     =  var.image_type  
    }
  }
  
  metadata = {
    enable-oslogin: "TRUE"
  }
  
  metadata_startup_script = <<SCRIPT
        sudo apt-get -y update
        sudo apt update 
        sudo apt install -y python3-pip
        pip3 install virtualenv mlflow boto3 psycopg2-binary prefect==2.0b5
        
        SCRIPT
  
  network_interface {
    subnetwork = var.public_subnet_name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
}

