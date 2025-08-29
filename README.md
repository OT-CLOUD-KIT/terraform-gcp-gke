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
  auto_repair           = var.auto_repair
  auto_upgrade          = var.auto_upgrade
  ssh_keys              = var.ssh_keys
  release_channel       = var.release_channel
  clusters              = var.clusters
  use_existing_sa       = var.use_existing_sa
  service_account_email = var.service_account_email
  service_account_id    = var.service_account_id
  service_account_roles = var.service_account_roles
}

# Variable values

project_id            = "project-id"
region                = "us-central1"
network               = "default"
subnetwork            = "default"
auto_repair           = true
auto_upgrade          = true
ssh_keys              = "ssh-rsa"
release_channel       = "REGULAR"
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
    name                   = "dev-cluster"
    location               = "us-central1-a"
    autopilot              = false
    initial_node_count     = 1
    enable_private_nodes   = true
    master_ipv4_cidr_block = "172.16.0.0/28"

    node_pools = {
      "default-pool" = {
        machine_type   = "e2-medium"
        disk_size_gb   = 50
        disk_type      = "pd-standard"
        image_type     = "COS_CONTAINERD"
        min_node_count = 1
        max_node_count = 2
        node_count     = 1 
        spot           = false
        labels         = { env = "dev" }
        taints         = []
      }

      "gpu-pool" = {
        machine_type   = "n1-standard-4"
        disk_size_gb   = 100
        disk_type      = "pd-ssd"
        image_type     = "UBUNTU_CONTAINERD" 
        min_node_count = 0
        max_node_count = 1
        node_count     = 1 
        spot           = true
        labels         = { env = "dev", type = "gpu" }
        taints = [
          {
            key    = "dedicated"
            value  = "gpu"
            effect = "NO_SCHEDULE"
          }
        ]
      }
    }
  }
}


```

## Inputs

| Name | Description | Type | Default | Required | 
|------|-------------|:----:|---------|:--------:|
|**project_id**| The ID of the project for which the gke is to be configured | string | { } | yes| 
|**region**| The Google Cloud region | string | "us-central1" | yes | 
|**clusters**| GKE cluster configurations | map(object) | { } | yes |
|**ssh_keys**| Public SSH keys to add to nodes for access | string | { } | yes| 
|**release_channel**| GKE release channel: RAPID, REGULAR, or STABLE | string | { } | yes| 
|**auto_repair**| Whether node auto-repair is enabled for node pools | bool | { } | yes| 
|**auto_upgrade**| Whether node auto-upgrade is enabled for node pools | bool | { } | yes| 
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
                                                                                                                  
