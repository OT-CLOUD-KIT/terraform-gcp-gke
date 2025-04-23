variable "create_gke" {
  description = "Conditionally create GKE clusters"
  type        = bool
  default     = true
}

variable "clusters" {
  description = "Map of clusters with configs"
  type = map(object({
    name               = string
    location           = string
    initial_node_count = number
    node_config = object({
      machine_type = string
      disk_size_gb = number
    })
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
  description = "Whether to use an existing service account"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Email of existing service account (required if use_existing_sa=true)"
  type        = string
  default     = ""
}

variable "service_account_id" {
  description = "Account ID to create GKE SA (used if use_existing_sa=false)"
  type        = string
  default     = "gke-service-account"
}

variable "service_account_roles" {
  description = "List of roles to assign to the created GKE service account"
  type        = list(string)
  default = [
    "roles/container.nodeServiceAccount",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser"
  ]
}
