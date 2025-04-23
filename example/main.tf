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
