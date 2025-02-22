variable "project_id" {
  description = "GCP Project ID"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "GCP Region"
  default     = "us-central1"
}

variable "gcp_key" {
  description = "Path to the Google Cloud service account key file (optional)."
  default     = ""
  sensitive   = true
}

variable "vpc_name" {
  description = "name of the vpc"
  type        = string
}

variable "ssh_username" {
  description = "User to ssh to the instances (optional)."
  type        = string
  default     = "ubuntu"
  sensitive   = true

}

variable "ssh_public_key_devops" {
  description = "Public SSH key for DevOps"
  sensitive   = true
}