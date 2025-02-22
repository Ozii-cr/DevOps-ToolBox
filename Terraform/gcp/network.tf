
module "vpc_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0.0"

  project_id   = var.project_id
  network_name = var.vpc_name
  subnets = [
    {
      subnet_name           = "subnet-public"
      subnet_ip             = "10.0.10.0/24"
      subnet_region         = "${var.region}"
      subnet_private_access = false
    },
    {
      subnet_name           = "subnet-private"
      subnet_ip             = "10.0.11.0/24"
      subnet_region         = "${var.region}"
      subnet_private_access = true

    }
  ]
}


resource "google_compute_firewall" "allow_default_ports" {
  name    = "allow-default-ports"
  network = var.vpc_name


  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22", "7312"]
  }

  target_tags = ["allow-default-ports"]
}


resource "google_compute_firewall" "allow_monitoring_ports" {
  name    = "allow-monitoring-ports"
  network = var.vpc_name


  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["9090", "9115", "9100"]
  }

  target_tags = ["allow-monitoring-ports"]
}
