module "artifacts" {
  source            = "./artifacts"
  bucket_name       = var.artifacts_bucket_name
  bucket_location   = var.artifacts_bucket_location
  number_of_version = var.artifacts_number_of_version
  storage_class     = var.artifacts_storage_class
}

module "db_secret" {
  source       = "./secret_manager"
  secret_id    = "db_password_secret"
  secret_data  = module.database.database_password
}

module "db_connection_secret" {
  source       = "./secret_manager"
  secret_id    = "db_connection_secret"
  secret_data   = "postgresql://${var.db_username}:${module.db_secret.secret_value}@${module.database.private_ip}:5432/${var.db_name}"
}

module "service_account" {
  source     = "./service_account"
  project_id = var.project_id
  name = var.service_account_name
  roles = [
    "roles/secretmanager.secretAccessor",
    "roles/cloudsql.client",
    "roles/cloudsql.instanceUser"
  ]
}


module "database" {
  source            = "./database"
  instance_prefix   = var.db_instance_prefix
  database_version  = var.db_version
  region            = var.db_region
  size              = var.db_size
  availability_type = var.db_availability_type
  database_name     = var.db_name
  username          = var.db_username
  network_self_link = var.network_self_link
  db_depends_on     = [var.db_depends_on]

}


module "cloud_run" {
  
  source                       = "./cloud_run"
  name                         = "mlflow-cloud-run"
  region                       = var.region
  docker_image                 = var.docker_image
  db_connection_secret         = module.db_connection_secret.secret_id
  db_connection_name           = module.database.connection_name
  oauth2_proxy_config_secret   = var.oauth2_proxy_config_secret
  artifacts_bucket_name        = module.artifacts.name
  service_account_name         = module.service_account.service_account_email
  vpc_connector_name           = var.vpc_connector_name
  
}