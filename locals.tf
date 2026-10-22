locals {
  standard_clusters = {
    for key, cluster in var.clusters : key => cluster if !cluster.autopilot
  }

  autopilot_clusters = {
    for key, cluster in var.clusters : key => cluster if cluster.autopilot
  }

  node_service_account_email = length(local.standard_clusters) == 0 ? null : (var.use_existing_sa ? var.service_account_email : google_service_account.gke_sa[0].email)

  legacy_node_pools = {
    for cluster_key, cluster in local.standard_clusters : "${cluster_key}/default" => {
      cluster_key                 = cluster_key
      name                        = "${cluster.name}-node-pool"
      node_count                  = coalesce(cluster.initial_node_count, 1)
      min_node_count              = coalesce(cluster.min_node_count, 1)
      max_node_count              = coalesce(cluster.max_node_count, 3)
      location_policy             = "BALANCED"
      machine_type                = try(cluster.node_config.machine_type, "e2-standard-4")
      disk_size_gb                = try(cluster.node_config.disk_size_gb, 100)
      disk_type                   = try(cluster.node_config.disk_type, "pd-balanced")
      image_type                  = "COS_CONTAINERD"
      spot                        = try(cluster.node_config.spot, false)
      labels                      = try(cluster.node_config.labels, {})
      tags                        = []
      taints                      = try(cluster.node_config.taints, [])
      oauth_scopes                = ["https://www.googleapis.com/auth/cloud-platform"]
      service_account_email       = null
      workload_metadata_mode      = cluster.enable_workload_identity ? "GKE_METADATA" : "GCE_METADATA"
      enable_secure_boot          = true
      enable_integrity_monitoring = true
      auto_repair                 = true
      auto_upgrade                = true
      max_surge                   = 1
      max_unavailable             = 0
    } if length(cluster.node_pools) == 0
  }

  configured_node_pools = merge({}, [
    for cluster_key, cluster in local.standard_clusters : {
      for pool_key, pool in cluster.node_pools : "${cluster_key}/${pool_key}" => {
        cluster_key                 = cluster_key
        name                        = coalesce(pool.name, "${cluster.name}-${pool_key}")
        node_count                  = pool.node_count
        min_node_count              = pool.min_node_count
        max_node_count              = pool.max_node_count
        location_policy             = pool.location_policy
        machine_type                = pool.machine_type
        disk_size_gb                = pool.disk_size_gb
        disk_type                   = pool.disk_type
        image_type                  = pool.image_type
        spot                        = pool.spot
        labels                      = pool.labels
        tags                        = pool.tags
        taints                      = pool.taints
        oauth_scopes                = pool.oauth_scopes
        service_account_email       = pool.service_account_email
        workload_metadata_mode      = cluster.enable_workload_identity ? "GKE_METADATA" : "GCE_METADATA"
        enable_secure_boot          = pool.enable_secure_boot
        enable_integrity_monitoring = pool.enable_integrity_monitoring
        auto_repair                 = pool.auto_repair
        auto_upgrade                = pool.auto_upgrade
        max_surge                   = pool.max_surge
        max_unavailable             = pool.max_unavailable
      }
    }
  ]...)

  node_pools = merge(local.legacy_node_pools, local.configured_node_pools)
}
