output "standard_cluster_names" {
  description = "Map of Standard cluster keys to cluster names."
  value       = { for key, cluster in google_container_cluster.standard : key => cluster.name }
}

output "autopilot_cluster_names" {
  description = "Map of Autopilot cluster keys to cluster names."
  value       = { for key, cluster in google_container_cluster.autopilot : key => cluster.name }
}

output "cluster_ids" {
  description = "Map of all cluster keys to fully qualified cluster IDs."
  value = merge(
    { for key, cluster in google_container_cluster.standard : key => cluster.id },
    { for key, cluster in google_container_cluster.autopilot : key => cluster.id }
  )
}

output "cluster_endpoints" {
  description = "Map of all cluster keys to Kubernetes API endpoints."
  value = merge(
    { for key, cluster in google_container_cluster.standard : key => cluster.endpoint },
    { for key, cluster in google_container_cluster.autopilot : key => cluster.endpoint }
  )
  sensitive = true
}

output "cluster_ca_certificates" {
  description = "Map of all cluster keys to base64-encoded cluster CA certificates."
  value = merge(
    { for key, cluster in google_container_cluster.standard : key => try(cluster.master_auth[0].cluster_ca_certificate, null) },
    { for key, cluster in google_container_cluster.autopilot : key => try(cluster.master_auth[0].cluster_ca_certificate, null) }
  )
  sensitive = true
}

output "node_pool_names" {
  description = "Map of module node-pool keys to node-pool names."
  value       = { for key, pool in google_container_node_pool.standard : key => pool.name }
}

output "node_service_account_email" {
  description = "Service account used by Standard GKE nodes."
  value       = local.node_service_account_email
}

output "workload_identity_pools" {
  description = "Map of Standard cluster keys to Workload Identity pools."
  value = {
    for key, cluster in local.standard_clusters :
    key => cluster.enable_workload_identity ? coalesce(cluster.workload_pool, "${var.project_id}.svc.id.goog") : null
  }
}
