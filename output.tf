output "standard_cluster_names" {
  description = "Names of all Standard GKE clusters created (non-Autopilot)."
  value       = [for c in google_container_cluster.standard : c.name]
}
output "autopilot_cluster_names" {
  description = "Names of all Autopilot GKE clusters created."
  value       = [for c in google_container_cluster.autopilot : c.name]
}
output "cluster_endpoints" {
  description = "Map of standard cluster names to their respective endpoint IPs."
  value       = {
    for k, c in google_container_cluster.standard : k => c.endpoint
  }
}
output "autopilot_endpoints" {
  description = "Map of Autopilot cluster names to their respective endpoint IPs."
  value       = {
    for k, c in google_container_cluster.autopilot : k => c.endpoint
  }
}
