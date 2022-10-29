output "cluster_endpoint" {
  value = google_container_cluster.default.endpoint
  sensitive = false
}