resource "google_sql_database" "main" {
  name     = "main"
  instance = google_sql_database_instance.main_primary.name
}

resource "google_sql_database_instance" "main" {
  name             = "main-instance"
  database_version = "POSTGRES_14"
  region           = var.region_name
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_size         = 10
  }

  ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc.self_link
  }
  

}

resource "random_password" "this" {
 length    = 24
 special   = false
 min_upper = 5
 min_lower = 5
}


resource "google_sql_user" "db_user" {
  name     = var.db_username
  instance = google_sql_database_instance.main_primary.name
  password = random_password.this.result
}

