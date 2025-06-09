## Terraform GCP GKE

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

This Terraform code creates both standard and Autopilot GKE clusters on GCP based on input variables. It dynamically provisions resources like clusters, node pools, and service accounts depending on the autopilot flag. For standard clusters, it configures private nodes, node pools with asg, taints and labels, and sets up IAM roles. The configuration supports both creating a new service account or using an existing one, making it reusable and flexible.

## Architecture

<img width="600" length="800" alt="Terraform" src="https://github.com/user-attachments/assets/1294c003-6283-48e4-8ac6-735e135f9544">

## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_gcp"></a> [gcp](#provider\_gcp) | 5.0.0   |

## Usage

```hcl
module "gke" {
  source                = "./module"
  project_id            = var.project_id
  network               = var.network
  subnetwork            = var.subnetwork
  clusters              = var.clusters
  use_existing_sa       = var.use_existing_sa
  service_account_email = var.service_account_email
  service_account_id    = var.service_account_id
  service_account_roles = var.service_account_roles
}

# Variable values

project_id = "nw-opstree-dev-landing-zone"
region     = "us-central1"
network    = "default"
subnetwork = "default"
use_existing_sa       = false
service_account_id    = "gke-sa"
service_account_email = "" # Leave empty if creating a new SA
service_account_roles = [
  "roles/container.nodeServiceAccount",
  "roles/compute.instanceAdmin.v1",
  "roles/iam.serviceAccountUser"
]

clusters = {
  "dev-cluster" = {
    name                 = "dev-cluster"
    location             = "us-central1-a"
    initial_node_count   = 1
    min_node_count         = 1
    max_node_count         = 1
    autopilot            = false
    enable_private_nodes = false
    master_ipv4_cidr_block = "172.16.0.0/28" # Optional if private cluster

    node_config = {
      machine_type = "e2-medium"
      disk_size_gb = 50
      disk_type    = "pd-standard"
      spot         = false           # Optional, default false
      labels       = { env = "dev" } # Optional labels
      taints = [
        {
          key    = "dedicated"
          value  = "gpu"
          effect = "NO_SCHEDULE"
        },
        {
          key    = "team"
          value  = "data"
          effect = "PREFER_NO_SCHEDULE"
        }
      ] 
    }
  }

  "autopilot-cluster" = {
    name      = "autopilot-cluster"
    location  = "us-central1"
    autopilot = true
    # No node_config block needed for Autopilot
  }
}

```

## Inputs

| Name | Description | Type | Default | Required | 
|------|-------------|:----:|---------|:--------:|
|**project_id**| The ID of the project for which the gke is to be configured | string | { } | yes| 
|**region**| The Google Cloud region | string | "us-central1" | yes | 
|**clusters**| GKE cluster configurations | map(object) | { } | yes | 
|**network**| VPC network name | string | { } | yes| 
|**subnetwork**| Subnetwork name | string | { } | yes | 
|**use_existing_sa**| Use existing service account | bool | false | yes| 
|**service_account_email**| Email of existing SA | string | { } | yes | 
|**service_account_id**| Account ID for new SA | string | "gke-service-account" | yes| 
|**service_account_roles**| Roles for new SA | list(stringt) | [ ] | yes |

## Output
| Name | Description |
|------|-------------|
|**standard_cluster_names**| Names of all Standard GKE clusters created (non-Autopilot) | 
|**cluster_endpoints**| Map of standard cluster names to their respective endpoint IPs | 
|**autopilot_cluster_names**|Names of all Autopilot GKE clusters created | 
|**autopilot_endpoints**| Map of Autopilot cluster names to their respective endpoint IPs | 
                                                                                                                  
