

resource "google_compute_address" "static_ip" {
  name = "ubuntu-vm-prefect"
  region =  var.region_name
}


resource "google_compute_instance" "default" {
  name         = "${format("%s","${var.company}-${var.env}-${var.region_name}-instance1")}"
  machine_type  = "e2-small"
  zone          =   "${format("%s","${var.region_name}-b")}"
  tags          = ["ssh","http"]
  
  boot_disk {
    initialize_params {
      image     =  "ubuntu-2204-lts"     
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
    subnetwork = google_compute_subnetwork.public_subnet.name
    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }
}