resource "google_container_cluster" "default" {
  name       = var.gke_cluster_name
  location   = var.region
  network    = var.network
  subnetwork = var.subnetwork
  networking_mode = "VPC_NATIVE"
  default_max_pods_per_node = 110
  remove_default_node_pool  = true
  release_channel {
    channel = "STABLE"
  }
  ip_allocation_policy {} 
  addons_config {
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
  }

  node_pool {
    name = "default-pool"
    node_config {
      machine_type = var.nodepool_machine_type
      disk_type    = var.disk_type
      preemptible  = true
    }
  }

}

resource "google_container_node_pool" "nodepool-1" {
  name              = "${var.gke_cluster_name}-nodepool-1"
  location          = var.region
  cluster           = google_container_cluster.default.name
  node_count        = var.node_count
  max_pods_per_node = 110

  autoscaling {
    min_node_count = var.node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_repair = true
    auto_upgrade = true
  }
  node_config {
    machine_type    = var.nodepool_machine_type
    disk_type       = var.disk_type
    disk_size_gb = var.disk_size
    image_type      = "COS_CONTAINERD"
    spot            = true
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    tags = ["${var.gke_cluster_name}-nodepool"]
    metadata = {
      disable-legacy-endpoints = true
    }
  }
  depends_on = [
    google_service_account.default,
    google_container_cluster.default
  ]

}