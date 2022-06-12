resource "google_sql_database" "main" {
  name     = "${var.project_name}-main"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database_instance" "main" {
  name             = "${var.project_name}-main-instance"
  database_version = "POSTGRES_14"
  region           = var.region_name
  depends_on       = [var.db_depends_on]

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = var.instance_type
    availability_type = "REGIONAL"
    disk_size         = 20
    
    ip_configuration {
      ipv4_enabled    = false         # don't give the db a public IPv4
      private_network = var.vpc_link  # the VPC where the db will be assigned a private IP
      }
  }

}

resource "random_password" "this" {
 length    = 24
 special   = false
 min_upper = 5
 min_lower = 5
}


resource "google_sql_user" "db_user" {
  name     = var.user
  instance = google_sql_database_instance.main.name
  password = random_password.this.result
}

