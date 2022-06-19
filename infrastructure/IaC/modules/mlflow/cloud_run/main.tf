data "google_project" "project" {
}

resource "google_cloud_run_service" "default" {
    name     = var.name
    location = var.region
    template {
        spec {
            containers {
                image = var.docker_image
                ports {
                      container_port = 4180
                }
                resources {
                  limits = {
                      cpu    = var.cloudrun_cpu
                      memory = var.cloudrun_memory
                  }
                }
                env {
                    name = "BACKEND_STORE_URI"
                    value_from {
                      secret_key_ref {
                        name = var.db_connection_secret
                        key  = "latest"
                      }
                    }
                }
                env {
                    name  = "DEFAULT_ARTIFACT_ROOT"
                    value = var.artifacts_bucket_name
                }
                env {
                    name  = "OAUTH_PROXY_CONFIG"
                    value = "/oauth2-cfg/oauth2_proxy_config"
                }
                volume_mounts {
                    name = "OAUTH_PROXY_CONFIG"
                    mount_path = "/oauth2-cfg"
                }
            }
            volumes {
                name = "OAUTH_PROXY_CONFIG"
                secret {
                    secret_name = var.oauth2_proxy_config_secret
                }
            }

            service_account_name = var.service_account_name
        }
        metadata {
            annotations = {
              "autoscaling.knative.dev/minScale"      = "1" 
              # Limit scale up to prevent any cost blow outs!   
              "autoscaling.knative.dev/maxScale"      = "100"
              "run.googleapis.com/cloudsql-instances" = var.db_connection_name
              "run.googleapis.com/ingress"            = "all"
              "run.googleapis.com/vpc-access-connector" = var.vpc_connector_name
              # all egress from the service should go through the VPC Connector
              "run.googleapis.com/vpc-access-egress" = "all-traffic"
            }
        }
    }

    traffic {
        percent         = 100
        latest_revision = true
    }


    autogenerate_revision_name = true
}


data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.default.location
  project     = google_cloud_run_service.default.project
  service     = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}