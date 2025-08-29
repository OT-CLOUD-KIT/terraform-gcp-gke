variable "region" {
  description = "The Google Cloud region"
  type        = string
  default = "us-central-1"
}

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

variable "ssh_keys" {
  description = "Public SSH keys to add to nodes for access."
  type        = string
  default     = <<EOKEY
  ssh-rsa 
EOKEY
}

variable "release_channel" {
  description = "GKE release channel: RAPID, REGULAR, or STABLE"
  type        = string
  default     = "REGULAR"
}

variable "project_id" {
  description = "The GCP project ID where GKE clusters will be deployed."
  type        = string
}

variable "network" {
  description = "VPC network to be used for GKE clusters."
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork to be used for GKE clusters."
  type        = string
}

variable "auto_repair" {
  description = "Whether node auto-repair is enabled for node pools."
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Whether node auto-upgrade is enabled for node pools."
  type        = bool
  default     = true
}

variable "use_existing_sa" {
  description = "Use an existing service account"
  type        = bool
  default     = false
}

variable "service_account_email" {
  description = "Email of an existing service account to be used if use_existing_sa is true."
  type        = string
  default     = ""
}

variable "service_account_id" {
  description = "Account ID for the new GKE service account to create if use_existing_sa is false."
  type        = string
  default     = "gke-service-account"
}

variable "service_account_roles" {
  description = "List of IAM roles to assign to the GKE service account if it is being created."
  type        = list(string)
  default = [
    "roles/container.nodeServiceAccount",
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser"
  ]
}