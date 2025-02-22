resource "google_compute_address" "monitoring_server_ip" {
  name   = "monitoring-server-ip"
  region = var.region
}

data "google_compute_image" "default_image" {
  family  = "ubuntu-pro-2404-lts-amd64"
  project = "ubuntu-os-pro-cloud"
}

resource "google_service_account" "instance_service_account" {
  account_id   = "instance-service-account"
  display_name = "Instance Service Account"
}

resource "google_project_iam_binding" "instance_service_account_binding" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin"
  members = [
    "serviceAccount:${google_service_account.instance_service_account.email}"
  ]
}

resource "google_compute_resource_policy" "server_schedule" {
  name   = "server-schedule"
  region = var.region

  instance_schedule_policy {
    time_zone = "Africa/Lagos" # WAT timezone

    vm_start_schedule {
      schedule = "0 9 * * 1-5" # Cron: 9:00 AM Monday to Friday
    }

    vm_stop_schedule {
      schedule = "0 17 * * 1-5" # Cron: 5:00 PM Monday to Friday
    }
  }
}

resource "google_compute_instance" "monitoring_server" {
  name         = "monitoring-server"
  machine_type = "e2-small"
  zone         = "${var.region}-a"


  network_interface {
    subnetwork = module.vpc_network.subnets["us-central1/subnet-public"].self_link
    access_config {
      nat_ip = google_compute_address.monitoring_server_ip.address
    }
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.default_image.self_link
      size  = 30
    }
  }

  service_account {
    email  = google_service_account.instance_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  allow_stopping_for_update = true

  tags = ["allow-default-ports", "allow-monitoring-ports"]

  metadata_startup_script = "#!/bin/bash\napt-get update -y && apt-get upgrade -y"

  metadata = {
    "ssh-keys" = "${var.ssh_username}:${var.ssh_public_key_devops}"
  }

  lifecycle {
    prevent_destroy = true
  }
}