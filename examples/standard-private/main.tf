terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

module "gke" {
  source = "../../"

  project_id = var.project_id
  network    = var.network
  subnetwork = var.subnetwork

  clusters = {
    production = {
      name                          = var.cluster_name
      location                      = var.location
      release_channel               = "REGULAR"
      deletion_protection           = true
      enable_private_nodes          = true
      enable_private_endpoint       = false
      master_ipv4_cidr_block        = var.master_ipv4_cidr_block
      cluster_secondary_range_name  = var.pods_secondary_range_name
      services_secondary_range_name = var.services_secondary_range_name
      datapath_provider             = "ADVANCED_DATAPATH"
      gateway_api_channel           = "CHANNEL_STANDARD"
      enable_workload_identity      = true
      enable_shielded_nodes         = true

      node_pools = {
        general = {
          machine_type   = "e2-standard-4"
          min_node_count = 1
          max_node_count = 5
          labels         = { workload = "general" }
        }
      }
    }
  }
}
