provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = var.gcp_key != "" ? var.gcp_key : null

  default_labels = {
    managed-by  = "terraform"
    environment = "production"
    team        = "devops"

  }
}