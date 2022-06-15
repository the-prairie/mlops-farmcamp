resource "random_id" "db_name_suffix" {
  byte_length = 5
}

resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_database_instance" "main" {
  name             = "${var.instance_prefix}-${random_id.db_name_suffix.hex}"
  database_version = var.database_version
  region           = var.region_name
  depends_on       = [var.db_depends_on]

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = var.instance_type
    ip_configuration {
      ipv4_enabled    = false         # don't give the db a public IPv4
      private_network = var.vpc_link  # the VPC where the db will be assigned a private IP
      }
  }

}

resource "google_sql_user" "db_user" {
  name     = var.user
  instance = google_sql_database_instance.main.name
  password = var.password
}

