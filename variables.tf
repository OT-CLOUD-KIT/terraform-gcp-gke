variable "project_id" {
  description = "Google Cloud project ID in which GKE resources are created."
  type        = string

  validation {
    condition     = length(trimspace(var.project_id)) > 0
    error_message = "project_id must not be empty."
  }
}

variable "network" {
  description = "VPC network name, self-link, or ID used by all clusters."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork name, self-link, or ID used by all clusters."
  type        = string
}

variable "clusters" {
  description = "Map of Standard or Autopilot GKE cluster configurations."
  type = map(object({
    name                = string
    location            = string
    autopilot           = optional(bool, false)
    description         = optional(string)
    deletion_protection = optional(bool, true)
    resource_labels     = optional(map(string), {})
    release_channel     = optional(string, "REGULAR")

    enable_private_nodes    = optional(bool, true)
    enable_private_endpoint = optional(bool, false)
    master_ipv4_cidr_block  = optional(string)
    master_global_access    = optional(bool, false)
    master_authorized_networks = optional(list(object({
      cidr_block   = string
      display_name = optional(string)
    })), [])

    networking_mode               = optional(string, "VPC_NATIVE")
    cluster_secondary_range_name  = optional(string)
    services_secondary_range_name = optional(string)
    cluster_ipv4_cidr_block       = optional(string)
    services_ipv4_cidr_block      = optional(string)

    datapath_provider        = optional(string, "ADVANCED_DATAPATH")
    gateway_api_channel      = optional(string, "CHANNEL_STANDARD")
    enable_workload_identity = optional(bool, true)
    workload_pool            = optional(string)
    enable_shielded_nodes    = optional(bool, true)

    initial_node_count = optional(number)
    min_node_count     = optional(number)
    max_node_count     = optional(number)
    node_config = optional(object({
      machine_type = string
      disk_size_gb = number
      disk_type    = string
      spot         = optional(bool, false)
      labels       = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
    }))

    node_pools = optional(map(object({
      name            = optional(string)
      node_count      = optional(number, 1)
      min_node_count  = optional(number, 1)
      max_node_count  = optional(number, 3)
      location_policy = optional(string, "BALANCED")

      machine_type = optional(string, "e2-standard-4")
      disk_size_gb = optional(number, 100)
      disk_type    = optional(string, "pd-balanced")
      image_type   = optional(string, "COS_CONTAINERD")
      spot         = optional(bool, false)
      labels       = optional(map(string), {})
      tags         = optional(list(string), [])
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
      oauth_scopes          = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
      service_account_email = optional(string)

      enable_secure_boot          = optional(bool, true)
      enable_integrity_monitoring = optional(bool, true)
      auto_repair                 = optional(bool, true)
      auto_upgrade                = optional(bool, true)
      max_surge                   = optional(number, 1)
      max_unavailable             = optional(number, 0)
    })), {})
  }))

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) :
      cluster.autopilot || cluster.node_config != null || length(cluster.node_pools) > 0
    ])
    error_message = "Each Standard cluster must define legacy node_config or at least one node_pools entry."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) :
      !cluster.enable_private_nodes || cluster.master_ipv4_cidr_block != null
    ])
    error_message = "master_ipv4_cidr_block is required when enable_private_nodes is true."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) :
      !cluster.enable_private_endpoint || cluster.enable_private_nodes
    ])
    error_message = "enable_private_endpoint requires enable_private_nodes to be true."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) :
      contains(["RAPID", "REGULAR", "STABLE", "EXTENDED", "UNSPECIFIED"], cluster.release_channel)
    ])
    error_message = "release_channel must be RAPID, REGULAR, STABLE, EXTENDED, or UNSPECIFIED."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) : contains(["CHANNEL_DISABLED", "CHANNEL_STANDARD"], cluster.gateway_api_channel)
    ])
    error_message = "gateway_api_channel must be CHANNEL_DISABLED or CHANNEL_STANDARD."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) : contains(["LEGACY_DATAPATH", "ADVANCED_DATAPATH"], cluster.datapath_provider)
    ])
    error_message = "datapath_provider must be LEGACY_DATAPATH or ADVANCED_DATAPATH."
  }

  validation {
    condition = alltrue(flatten([
      for cluster in values(var.clusters) : [
        for pool in values(cluster.node_pools) : pool.min_node_count <= pool.max_node_count
      ]
    ]))
    error_message = "Every node pool min_node_count must be less than or equal to max_node_count."
  }

  validation {
    condition = alltrue(flatten([
      for cluster in values(var.clusters) : [
        for pool in values(cluster.node_pools) : contains(["BALANCED", "ANY"], pool.location_policy)
      ]
    ]))
    error_message = "Node pool location_policy must be BALANCED or ANY."
  }

  validation {
    condition = alltrue([
      for cluster in values(var.clusters) :
      cluster.autopilot ? (cluster.node_config == null && length(cluster.node_pools) == 0) : true
    ])
    error_message = "Autopilot clusters must not define Standard node_config or node_pools."
  }
}

variable "use_existing_sa" {
  description = "Use an existing node service account instead of creating one."
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Existing node service account email when use_existing_sa is true."
  type        = string
  default     = ""
}

variable "service_account_id" {
  description = "Account ID used when the module creates the node service account."
  type        = string
  default     = "gke-node-sa"
}

variable "service_account_roles" {
  description = "Project IAM roles granted to the module-created node service account."
  type        = set(string)
  default     = ["roles/container.defaultNodeServiceAccount"]
}
