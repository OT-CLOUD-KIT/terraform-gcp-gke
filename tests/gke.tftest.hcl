mock_provider "google" {}

run "secure_standard_cluster" {
  command = plan

  variables {
    project_id = "example-project"
    network    = "example-network"
    subnetwork = "example-subnetwork"

    clusters = {
      production = {
        name                          = "gke-production"
        location                      = "us-central1"
        master_ipv4_cidr_block        = "172.16.0.0/28"
        cluster_secondary_range_name  = "gke-pods"
        services_secondary_range_name = "gke-services"
        node_pools = {
          general = {
            min_node_count = 1
            max_node_count = 5
          }
        }
      }
    }
  }

  assert {
    condition     = google_container_cluster.standard["production"].datapath_provider == "ADVANCED_DATAPATH"
    error_message = "Secure default must enable GKE Dataplane V2."
  }

  assert {
    condition     = google_container_cluster.standard["production"].gateway_api_config[0].channel == "CHANNEL_STANDARD"
    error_message = "Secure default must enable the Gateway API Standard channel."
  }

  assert {
    condition     = google_container_cluster.standard["production"].enable_shielded_nodes
    error_message = "Secure default must enable Shielded GKE Nodes."
  }
}

run "legacy_single_node_pool" {
  command = plan

  variables {
    project_id = "example-project"
    network    = "example-network"
    subnetwork = "example-subnetwork"

    clusters = {
      legacy = {
        name                          = "legacy-cluster"
        location                      = "us-central1-a"
        master_ipv4_cidr_block        = "172.16.1.0/28"
        cluster_secondary_range_name  = "legacy-pods"
        services_secondary_range_name = "legacy-services"
        initial_node_count            = 1
        min_node_count                = 1
        max_node_count                = 3
        node_config = {
          machine_type = "e2-standard-2"
          disk_size_gb = 50
          disk_type    = "pd-balanced"
        }
      }
    }
  }

  assert {
    condition     = length(google_container_node_pool.standard) == 1
    error_message = "Legacy input must still create one managed node pool."
  }
}

run "reject_private_cluster_without_master_cidr" {
  command = plan

  variables {
    project_id = "example-project"
    network    = "example-network"
    subnetwork = "example-subnetwork"

    clusters = {
      invalid = {
        name     = "invalid-private-cluster"
        location = "us-central1"
        node_pools = {
          general = {}
        }
      }
    }
  }

  expect_failures = [var.clusters]
}

run "reject_invalid_node_pool_bounds" {
  command = plan

  variables {
    project_id = "example-project"
    network    = "example-network"
    subnetwork = "example-subnetwork"

    clusters = {
      invalid = {
        name                          = "invalid-autoscaling-cluster"
        location                      = "us-central1"
        master_ipv4_cidr_block        = "172.16.2.0/28"
        cluster_secondary_range_name  = "invalid-pods"
        services_secondary_range_name = "invalid-services"
        node_pools = {
          general = {
            min_node_count = 5
            max_node_count = 2
          }
        }
      }
    }
  }

  expect_failures = [var.clusters]
}
