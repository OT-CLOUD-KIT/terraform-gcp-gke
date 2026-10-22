# Terraform Google Cloud GKE Module

Reusable Terraform module for secure Google Kubernetes Engine clusters. It supports Standard and Autopilot clusters while providing production-oriented defaults for private networking, VPC-native Pod and Service ranges, GKE Dataplane V2, Gateway API, Workload Identity Federation, autoscaling node pools, and Shielded GKE Nodes.

## Features

- Standard and Autopilot GKE clusters from one input map
- Regional or zonal cluster locations
- Private nodes and optional private control-plane endpoint
- Existing secondary IP ranges or explicit Pod and Service CIDRs
- GKE Dataplane V2 through `ADVANCED_DATAPATH`
- Gateway API Standard channel for Standard clusters
- Workload Identity Federation for GKE
- One or more independently autoscaled node pools per Standard cluster
- Shielded Nodes with Secure Boot and integrity monitoring
- Automatic node repair and upgrades
- Existing or module-created node service account
- Master Authorized Networks and global control-plane access
- Release-channel, deletion-protection, labels, taints, tags, and Spot VM controls
- Compatibility with the original single-node-pool input structure

## Requirements

| Name | Version |
|------|---------|
| Terraform | `>= 1.6.0` |
| Google provider | `~> 7.0` |

The project must have the Kubernetes Engine API enabled. The configured subnet must have Pod and Service secondary ranges when their names are supplied to this module.

## Usage

```hcl
module "gke" {
  source = "../../"

  project_id = "example-platform-prod"
  network    = "projects/example-host/global/networks/shared-vpc"
  subnetwork = "projects/example-host/regions/us-central1/subnetworks/gke-prod"

  clusters = {
    production = {
      name                     = "gke-production"
      location                 = "us-central1"
      release_channel          = "REGULAR"
      deletion_protection      = true
      enable_private_nodes     = true
      enable_private_endpoint  = false
      master_ipv4_cidr_block   = "172.16.0.0/28"
      master_global_access     = false
      cluster_secondary_range_name  = "gke-pods"
      services_secondary_range_name = "gke-services"
      datapath_provider        = "ADVANCED_DATAPATH"
      gateway_api_channel      = "CHANNEL_STANDARD"
      enable_workload_identity = true
      enable_shielded_nodes    = true

      master_authorized_networks = [
        {
          cidr_block   = "10.10.0.0/16"
          display_name = "corporate-network"
        }
      ]

      node_pools = {
        general = {
          machine_type   = "e2-standard-4"
          min_node_count = 1
          max_node_count = 5
          disk_type      = "pd-balanced"
          disk_size_gb   = 100
          labels         = { workload = "general" }
        }
      }
    }
  }
}
```

## Important behavior

- Gateway API is always available on Autopilot clusters. `gateway_api_channel` is applied to Standard clusters.
- Autopilot manages its own nodes, Workload Identity configuration, Dataplane V2, and Shielded Nodes. Node-pool settings apply only to Standard clusters.
- A VPC-native cluster must provide both secondary range names or both explicit Pod and Service CIDR blocks.
- Existing state using the original `initial_node_count`, `min_node_count`, `max_node_count`, and `node_config` fields remains supported. New implementations should use `node_pools`.
- `deletion_protection` defaults to `true`; disable it explicitly before intentionally destroying a cluster.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | Project in which GKE resources are created | `string` | n/a | yes |
| `network` | VPC network name, ID, or self-link | `string` | n/a | yes |
| `subnetwork` | Subnetwork name, ID, or self-link | `string` | n/a | yes |
| `clusters` | Standard or Autopilot cluster definitions | `map(object)` | n/a | yes |
| `use_existing_sa` | Use an existing node service account | `bool` | `false` | no |
| `service_account_email` | Existing node service account email | `string` | `""` | no |
| `service_account_id` | Account ID for the module-created node service account | `string` | `"gke-node-sa"` | no |
| `service_account_roles` | IAM roles for the module-created node service account | `set(string)` | `roles/container.defaultNodeServiceAccount` | no |

## Outputs

| Name | Description |
|------|-------------|
| `standard_cluster_names` | Standard cluster names keyed by input key |
| `autopilot_cluster_names` | Autopilot cluster names keyed by input key |
| `cluster_ids` | Fully qualified IDs for all clusters |
| `cluster_endpoints` | Sensitive Kubernetes API endpoints |
| `cluster_ca_certificates` | Sensitive cluster CA certificates |
| `node_pool_names` | Standard node-pool names |
| `node_service_account_email` | Standard node service account email |
| `workload_identity_pools` | Workload Identity pools for Standard clusters |

## Migration from the original module

1. Keep the same cluster map key and cluster name to preserve resource addressing.
2. Add Pod and Service secondary range names created by the VPC module.
3. Review private-cluster settings before planning because secure defaults are enabled.
4. Keep the legacy node fields for the first migration plan, or move to `node_pools` and use `terraform state mv` if the node-pool address changes.
5. Review the plan carefully before applying changes to an existing cluster. Enabling Dataplane V2 on an existing cluster can recreate nodes and disrupt workloads.

## License

Apache 2.0. See [LICENSE](LICENSE).
