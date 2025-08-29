module "gke" {
  source                = "./module"
  project_id            = var.project_id
  network               = var.network
  subnetwork            = var.subnetwork
  auto_repair           = var.auto_repair
  auto_upgrade          = var.auto_upgrade
  ssh_keys              = var.ssh_keys
  release_channel       = var.release_channel
  clusters              = var.clusters
  use_existing_sa       = var.use_existing_sa
  service_account_email = var.service_account_email
  service_account_id    = var.service_account_id
  service_account_roles = var.service_account_roles
}