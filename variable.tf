variable "clusters" {
  description = "Map of GKE cluster configurations"
  type = map(object({
    name                   = string
    location               = string
    initial_node_count     = optional(number)
    autopilot              = bool
    enable_private_nodes   = optional(bool, false)
    master_ipv4_cidr_block = optional(string)
    node_config = optional(object({
      machine_type = string
      disk_size_gb = number
      disk_type    = string
      spot         = optional(bool, false)
      labels       = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string # e.g. "NO_SCHEDULE", "PREFER_NO_SCHEDULE", "NO_EXECUTE"
      })), [])
    }))
  }))
}

variable "project_id" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "use_existing_sa" {
  description = "Use an existing service account"
  type        = bool
  default     = false
}

variable "service_account_email" {
  type    = string
  default = ""
}

variable "service_account_id" {
  type    = string
  default = "gke-service-account"
}

variable "service_account_roles" {
  type = list(string)
  default = [
    "roles/container.nodeServiceAccount",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser"
  ]
}