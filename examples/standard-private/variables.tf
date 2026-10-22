variable "project_id" {
  type = string
}

variable "network" {
  type = string
}

variable "subnetwork" {
  type = string
}

variable "cluster_name" {
  type    = string
  default = "gke-production"
}

variable "location" {
  type    = string
  default = "us-central1"
}

variable "master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "pods_secondary_range_name" {
  type    = string
  default = "gke-pods"
}

variable "services_secondary_range_name" {
  type    = string
  default = "gke-services"
}
