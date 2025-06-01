## Terraform GCP GKE

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

This Terraform configuration provisions multiple Google Kubernetes Engine (GKE) clusters, supporting both Standard and Autopilot modes based on input variables. For Standard clusters, it creates dedicated node pools with customizable machine types, disk sizes, and service accounts. The configuration allows either reusing an existing service account or creating a new one, and assigns all necessary IAM roles such as container.nodeServiceAccount, compute.instanceAdmin.v1, and iam.serviceAccountUser. It also grants GKE control plane permissions to the service account, ensuring proper authentication and operational access.

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
    name               = "dev-cluster"
    location           = "us-central1-a"
    initial_node_count = 1
    autopilot          = false
    node_config = {
      machine_type = "e2-medium"
      disk_size_gb = 50
      disk_type    = "pd-standard"
    }
  }

  "autopilot-cluster" = {
    name      = "autopilot-cluster"
    location  = "us-central1"
    autopilot = true
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
                                                                                                                  
