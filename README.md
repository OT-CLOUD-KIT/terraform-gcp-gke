## Terraform GCP GKE

[![Opstree Solutions][opstree_avatar]][opstree_homepage]<br/>[Opstree Solutions][opstree_homepage] 

  [opstree_homepage]: https://opstree.github.io/
  [opstree_avatar]: https://img.cloudposse.com/150x150/https://github.com/opstree.png

This Terraform configuration creates a Google Kubernetes Engine (GKE) cluster, optionally using an existing or new service account. It dynamically handles multiple clusters with custom node configurations, including machine type and disk size. The GKE service account is assigned necessary roles such as container.nodeServiceAccount and compute.instanceAdmin.v1. Additionally, the GKE service account is granted permissions to the control plane, allowing the cluster to function properly with required IAM roles.

## Architecture

<img width="6000" length="8000" alt="Terraform" src="https://github.com/user-attachments/assets/26c523f3-290d-4be9-bc8b-39fbca89478b">



## Providers

| Name                                              | Version  |
|---------------------------------------------------|----------|
| <a name="provider_gcp"></a> [gcp](#provider\_gcp) | 5.0.0   |

## Usage

```hcl
module "gke_standard_cluster" {
  source                = "./module"
  create_gke            = var.create_gke
  clusters              = var.clusters
  project_id            = var.project_id
  network               = var.network
  subnetwork            = var.subnetwork
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
create_gke = true

# Set to true if using an existing service account
use_existing_sa       = false
service_account_email = "" # Required only if use_existing_sa = true
service_account_id    = "gke-custom-service-account"

# Optional override of default roles
service_account_roles = [
  "roles/container.nodeServiceAccount",
  "roles/compute.instanceAdmin.v1",
  "roles/iam.serviceAccountUser"
]

clusters = {
  gke-cluster-1 = {
    name               = "gke-cluster-1"
    location           = "us-central1"
    initial_node_count = 1
    node_config = {
      machine_type = "e2-medium"
      disk_size_gb = 20
    }
  }

  gke-cluster-2 = {
    name               = "gke-cluster-2"
    location           = "us-east1"
    initial_node_count = 1
    node_config = {
      machine_type = "e2-standard-2"
      disk_size_gb = 20
    }
  }
}

```

## Inputs

| Name | Description | Type | Default | Required | 
|------|-------------|:----:|---------|:--------:|
|**project_id**| The ID of the project for which the gke is to be configured | string | { } | yes| 
|**region**| The Google Cloud region | string | "us-central1" | yes | 
|**create_gke**| Whether to create GKE clusters | bool | false | yes| 
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
|**gke_standard_cluster_names**| Standard GKE cluster names | 
|**gke_standard_cluster_endpoints**| Standard GKE cluster API endpoints | 
|**created_service_account_email**|Email of the created service account (if applicable) | 
|**created_service_account_id**| Account ID of the created service account | 
                                                                                                                  