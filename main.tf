resource "google_service_account" "gke_sa" {
  count = !var.use_existing_sa && length(local.standard_clusters) > 0 ? 1 : 0

  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "GKE node service account"
  description  = "Node service account managed by the terraform-gcp-gke module."
}

resource "google_project_iam_member" "gke_sa_roles" {
  for_each = var.use_existing_sa || length(local.standard_clusters) == 0 ? toset([]) : var.service_account_roles

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa[0].email}"
}

resource "google_container_cluster" "standard" {
  for_each = local.standard_clusters

  project     = var.project_id
  name        = each.value.name
  description = each.value.description
  location    = each.value.location
  network     = var.network
  subnetwork  = var.subnetwork

  initial_node_count       = 1
  remove_default_node_pool = true
  deletion_protection      = each.value.deletion_protection
  resource_labels          = each.value.resource_labels
  networking_mode          = each.value.networking_mode
  datapath_provider        = each.value.datapath_provider
  enable_shielded_nodes    = each.value.enable_shielded_nodes

  release_channel {
    channel = each.value.release_channel
  }

  gateway_api_config {
    channel = each.value.gateway_api_channel
  }

  dynamic "workload_identity_config" {
    for_each = each.value.enable_workload_identity ? [1] : []
    content {
      workload_pool = coalesce(each.value.workload_pool, "${var.project_id}.svc.id.goog")
    }
  }

  dynamic "ip_allocation_policy" {
    for_each = each.value.networking_mode == "VPC_NATIVE" ? [1] : []
    content {
      cluster_secondary_range_name  = each.value.cluster_secondary_range_name
      services_secondary_range_name = each.value.services_secondary_range_name
      cluster_ipv4_cidr_block       = each.value.cluster_ipv4_cidr_block
      services_ipv4_cidr_block      = each.value.services_ipv4_cidr_block
    }
  }

  dynamic "private_cluster_config" {
    for_each = each.value.enable_private_nodes || each.value.enable_private_endpoint ? [1] : []
    content {
      enable_private_nodes    = each.value.enable_private_nodes
      enable_private_endpoint = each.value.enable_private_endpoint
      master_ipv4_cidr_block  = each.value.master_ipv4_cidr_block

      master_global_access_config {
        enabled = each.value.master_global_access
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(each.value.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = each.value.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition = (
        each.value.networking_mode != "VPC_NATIVE" ||
        (each.value.cluster_secondary_range_name != null && each.value.services_secondary_range_name != null) ||
        (each.value.cluster_ipv4_cidr_block != null && each.value.services_ipv4_cidr_block != null)
      )
      error_message = "VPC_NATIVE clusters must provide both secondary range names or both Pod and Service CIDR blocks."
    }
  }
}

resource "google_container_node_pool" "standard" {
  for_each = local.node_pools

  project    = var.project_id
  name       = each.value.name
  location   = local.standard_clusters[each.value.cluster_key].location
  cluster    = google_container_cluster.standard[each.value.cluster_key].name
  node_count = each.value.node_count

  autoscaling {
    min_node_count  = each.value.min_node_count
    max_node_count  = each.value.max_node_count
    location_policy = each.value.location_policy
  }

  node_config {
    machine_type    = each.value.machine_type
    disk_size_gb    = each.value.disk_size_gb
    disk_type       = each.value.disk_type
    image_type      = each.value.image_type
    spot            = each.value.spot
    labels          = each.value.labels
    tags            = each.value.tags
    oauth_scopes    = each.value.oauth_scopes
    service_account = coalesce(each.value.service_account_email, local.node_service_account_email)

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      mode = each.value.workload_metadata_mode
    }

    shielded_instance_config {
      enable_secure_boot          = each.value.enable_secure_boot
      enable_integrity_monitoring = each.value.enable_integrity_monitoring
    }

    dynamic "taint" {
      for_each = each.value.taints
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }

  management {
    auto_repair  = each.value.auto_repair
    auto_upgrade = each.value.auto_upgrade
  }

  upgrade_settings {
    max_surge       = each.value.max_surge
    max_unavailable = each.value.max_unavailable
  }

  depends_on = [google_project_iam_member.gke_sa_roles]

  lifecycle {
    precondition {
      condition     = !var.use_existing_sa || length(trimspace(var.service_account_email)) > 0
      error_message = "service_account_email must be provided when use_existing_sa is true."
    }
  }
}

resource "google_container_cluster" "autopilot" {
  for_each = local.autopilot_clusters

  project             = var.project_id
  name                = each.value.name
  description         = each.value.description
  location            = each.value.location
  network             = var.network
  subnetwork          = var.subnetwork
  enable_autopilot    = true
  deletion_protection = each.value.deletion_protection
  resource_labels     = each.value.resource_labels
  networking_mode     = each.value.networking_mode

  release_channel {
    channel = each.value.release_channel
  }

  dynamic "ip_allocation_policy" {
    for_each = each.value.networking_mode == "VPC_NATIVE" ? [1] : []
    content {
      cluster_secondary_range_name  = each.value.cluster_secondary_range_name
      services_secondary_range_name = each.value.services_secondary_range_name
      cluster_ipv4_cidr_block       = each.value.cluster_ipv4_cidr_block
      services_ipv4_cidr_block      = each.value.services_ipv4_cidr_block
    }
  }

  dynamic "private_cluster_config" {
    for_each = each.value.enable_private_nodes || each.value.enable_private_endpoint ? [1] : []
    content {
      enable_private_nodes    = each.value.enable_private_nodes
      enable_private_endpoint = each.value.enable_private_endpoint
      master_ipv4_cidr_block  = each.value.master_ipv4_cidr_block

      master_global_access_config {
        enabled = each.value.master_global_access
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(each.value.master_authorized_networks) > 0 ? [1] : []
    content {
      dynamic "cidr_blocks" {
        for_each = each.value.master_authorized_networks
        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition = (
        each.value.networking_mode != "VPC_NATIVE" ||
        (each.value.cluster_secondary_range_name != null && each.value.services_secondary_range_name != null) ||
        (each.value.cluster_ipv4_cidr_block != null && each.value.services_ipv4_cidr_block != null)
      )
      error_message = "VPC_NATIVE clusters must provide both secondary range names or both Pod and Service CIDR blocks."
    }
  }
}
