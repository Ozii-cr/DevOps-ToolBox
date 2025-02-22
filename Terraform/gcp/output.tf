output "monitoring_server_ip" {
  value       = google_compute_address.monitoring_server_ip.address
  description = "The external IP address of the monitoring server instance."
}