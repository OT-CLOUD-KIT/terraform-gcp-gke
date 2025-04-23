output "gke_standard_cluster_names" {
  description = "List of Standard cluster names"
  value       = [for cluster in google_container_cluster.gke_standard : cluster.name]
}

output "gke_standard_cluster_endpoints" {
  description = "List of Standard cluster API endpoints"
  value       = [for cluster in google_container_cluster.gke_standard : cluster.endpoint]
}

output "created_service_account_email" {
  description = "Email of the created service account (if applicable)"
  value       = var.use_existing_sa ? null : google_service_account.gke_sa[0].email
}

output "created_service_account_id" {
  description = "Account ID of the created service account"
  value       = var.use_existing_sa ? null : google_service_account.gke_sa[0].account_id
}

