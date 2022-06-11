resource "google_compute_instance" "default" {
  name         = "${format("%s","${var.company}-${var.env}-${var.region_name}-instance2")}"
  machine_type  = "e2-small"
  zone          =   "${format("%s","${var.region_name}-b")}"
  tags          = ["ssh","http"]
  boot_disk {
    initialize_params {
      image     =  "ubuntu-2204-lts"    
    }
  }
  
  metadata_startup_script = <<SCRIPT
        apt-get -y update
        apt-get -y install nginx
        export HOSTNAME=$(hostname | tr -d '\n')
        export PRIVATE_IP=$(curl -sf -H 'Metadata-Flavor:Google' http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip | tr -d '\n')
        echo "Welcome to $HOSTNAME - $PRIVATE_IP" > /usr/share/nginx/www/index.html
        service nginx start
        SCRIPT
  
  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.name
    access_config {
      // Ephemeral IP
    }
  }
}