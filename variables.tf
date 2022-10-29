variable "gcp_project" {
  type    = string
}
variable "region" {
  type    = string
  default = "asia-south1"
}

variable "zone" {
  type    = string
  default = "asia-south1-a"
}

variable "network" {
  type        = string
  description = "vpc network name"
}

variable "subnetwork" {
  type        = string
  description = "vpc subnet name"
}

variable "service_account" {
  type        = string
  description = "service account name"
}


variable "gke_cluster_name" {
  type        = string
  description = "GKE cluster name"
}

variable "nodepool_machine_type" {
  type        = string
  description = "nodepool machine type"
  default     = "e2-small"
}

variable "disk_type" {
  type        = string
  description = "nodepool disk type"
  default     = "pd-standard"
}

variable "disk_size" {
  type        = number
  description = "nodepool disk size"
  default     = 10
}

variable "node_count" {
  type        = number
  description = "default node count of nodepools"
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "max node count of nodepools"
  default     = 2
}