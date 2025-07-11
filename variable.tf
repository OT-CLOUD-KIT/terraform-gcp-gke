variable "clusters" {
  description = "Map of GKE cluster configurations"
  type = map(object({
    name                   = string
    location               = string
    autopilot              = bool
    enable_private_nodes   = optional(bool, false)
    master_ipv4_cidr_block = optional(string)
    initial_node_count     = optional(number, 1) 
    node_pools = optional(map(object({
      min_node_count = number
      max_node_count = number
      node_count     = optional(number) 
      machine_type   = string
      disk_size_gb   = number
      disk_type      = string
      image_type     = optional(string) 
      spot           = optional(bool, false)
      labels         = optional(map(string), {})
      taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })), [])
    })), {})
  }))
}

variable "project_id" {
  description = "The GCP project ID where resources will be created"
  type = string
}

variable "network" {
  description = "The name of the VPC network to deploy the GKE cluster in"
  type = string
}

variable "subnetwork" {
  description = "The name of the subnetwork to deploy the GKE cluster in"
  type = string
}

variable "use_existing_sa" {
  description = "Use an existing service account"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Email of the existing service account to use (required if use_existing_sa is true)"
  type    = string
  default = ""
}

variable "service_account_id" {
  description = "ID to assign to the service account if creating a new one (default: gke-service-account)"
  type    = string
  default = "gke-service-account"
}

variable "service_account_roles" {
  description = "List of IAM roles to assign to the GKE service account"
  type = list(string)
  default = [
    "roles/container.nodeServiceAccount",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser"
  ]
}
