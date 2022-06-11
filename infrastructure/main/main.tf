provider "google" {
  project = var.project
}

data "google_client_openid_userinfo" "me" {}

resource "google_os_login_ssh_public_key" "cache" {
  project = var.project
  user = data.google_client_openid_userinfo.me.email
  key  = file("~/.ssh/prtygrl.pub")
}

resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/compute.osAdminLogin"
  member  = "user:${data.google_client_openid_userinfo.me.email}"
}

module "vpc" {
  source                 = "../modules/global"
  env                    = var.env
  company                = var.company
  server1_public_subnet  = var.server1_public_subnet
  server1_private_subnet = var.server1_private_subnet
  server2_public_subnet  = var.server2_public_subnet
  server2_private_subnet = var.server2_private_subnet
}

module "server1" {
  source                 = "../modules/server1"
  network_self_link      = module.vpc.out_vpc_self_link
  subnetwork1            = module.server1.server1_out_public_subnet_name
  env                    = var.env
  company                = var.company
  server1_public_subnet  = var.server1_public_subnet
  server1_private_subnet = var.server1_private_subnet
}
module "server2" {
  source                 = "../modules/server2"
  network_self_link      = module.vpc.out_vpc_self_link
  subnetwork2            = module.server2.server2_out_public_subnet_name
  env                    = var.env
  company                = var.company
  server2_public_subnet  = var.server2_public_subnet
  server2_private_subnet = var.server2_private_subnet
}
######################################################################
# Display Output Public Instance
######################################################################

output "vpc_self_link" { value = module.vpc.out_vpc_self_link }
output "static_ip" { value = module.server1.static_ip }