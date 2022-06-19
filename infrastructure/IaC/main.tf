terraform {
  backend "gcs" {
    bucket = "mlflow-backend-b"
    prefix = "state"
  }
  required_version = "> 0.13.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.24.0"
    }
  }
}


provider "google" {
  project = var.project_id
}

resource "random_id" "artifacts_bucket_name_suffix" {
  byte_length = 5
}

module "network" {
  source       = "./modules/network"
  network_name = var.network_name
  project_id   = var.project_id
  region       = var.region

}

module "mlflow" {
  source                     = "./modules/mlflow"
  artifacts_bucket_name      = "${var.artifacts_bucket}-${random_id.artifacts_bucket_name_suffix.hex}"
  docker_image               = var.mlflow_docker_image
  project_id                 = var.project_id
  region                     = var.region
  network_self_link          = module.network.network_self_link
  network_short_name         = module.network.network_name
  oauth_client_id            = var.oauth_client_id
  oauth_client_secret        = var.oauth_client_secret
  oauth2_proxy_config_secret = var.oauth2_proxy_config_secret
  db_depends_on              = module.network.private_vpc_connection
  service_account_name       = var.service_account_name
  vpc_connector_name         = module.network.vpc_connector_name

}

