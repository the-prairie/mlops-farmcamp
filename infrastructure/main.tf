data "google_client_openid_userinfo" "me" {}

resource "google_os_login_ssh_public_key" "cache" {
  project = var.gcp_project_name
  user    = data.google_client_openid_userinfo.me.email
  key     = file("~/.ssh/prtygrl.pub")
}

resource "google_project_iam_member" "project" {
  project = var.gcp_project_name
  role    = "roles/compute.osAdminLogin"
  member  = "user:${data.google_client_openid_userinfo.me.email}"
}

module "service_account" {
  source = "./modules/service_account"
  role   = "roles/cloudsql.editor"
  name   = "cloud-sql-proxy"
}


module "vpc" {
  source       = "./modules/vpc"
  project_name = var.gcp_project_name
  name         = "${var.project}-vpc"
  region_name  = var.gcp_region_name
}

module "db" {
  source = "./modules/db"

  project_name  = var.gcp_project_name
  region_name   = var.gcp_region_name
  instance_type = "db-n1-standard-1"
  password      = module.db.postgres_db_password # This is a variable because it's a secret.
  user          = var.db_username
  vpc_name      = module.vpc.name
  vpc_link      = module.vpc.link

  # There's a dependency relationship between the db and the VPC that
  # terraform can't figure out. The db instance depends on the VPC because it
  # uses a private IP from a block of IPs defined in the VPC. If we just giving
  # the db a public IP, there wouldn't be a dependency. The dependency exists
  # because we've configured private services access. We need to explicitly
  # specify the dependency here. For details, see the note in the docs here:
  #   https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#private-ip-instance
  db_depends_on = module.vpc.private_vpc_connection
}

module "dbproxy" {
  source = "./modules/dbproxy"

  db_instance_name            = module.db.connection_name # e.g. my-project:us-central1:my-db
  project_name                = var.gcp_project_name
  region_name                 = var.gcp_region_name
  zone                        = "${var.gcp_region_name}-a"
  service_account_email       = module.service_account.email
  service_account_private_key = module.service_account.private_key
  db_proxy_depends_on         = module.service_account

  # By passing the VPC name as the output of the VPC module we ensure the VPC
  # will be created before the proxy.
  vpc_name = module.vpc.name
}

module "ubuntu-vm" {
  source             = "./modules/vm"
  machine_type       = "e2-small"
  project            = var.project
  region_name        = var.gcp_region_name
  image_type         = "ubuntu-2204-lts"
  public_subnet_name = module.vpc.public_subnet_name

}