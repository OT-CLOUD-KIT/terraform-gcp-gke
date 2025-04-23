resource "google_container_cluster" "gke_standard" {
  for_each = var.create_gke ? var.clusters : {}

  name                = each.value.name
  location            = each.value.location
  project             = var.project_id
  network             = var.network
  subnetwork          = var.subnetwork
  deletion_protection = false
  initial_node_count  = each.value.initial_node_count

  remove_default_node_pool = var.create_gke ? true : null

  node_config {
    machine_type    = each.value.node_config.machine_type
    disk_size_gb    = each.value.node_config.disk_size_gb
    service_account = var.use_existing_sa ? var.service_account_email : google_service_account.gke_sa[0].email
  }

  lifecycle {
    ignore_changes = [
      remove_default_node_pool,
    ]
  }
}

resource "google_service_account" "gke_sa" {
  count        = var.use_existing_sa ? 0 : 1
  account_id   = var.service_account_id
  display_name = "GKE Service Account"
}

resource "google_project_iam_member" "gke_sa_roles" {
  count   = var.use_existing_sa ? 0 : length(var.service_account_roles)
  project = var.project_id
  role    = var.service_account_roles[count.index]
  member  = "serviceAccount:${google_service_account.gke_sa[0].email}"
}

data "google_project" "current" {
  project_id = var.project_id
}

resource "google_service_account_iam_member" "allow_gke_control_plane" {
  count              = var.use_existing_sa ? 0 : 1
  service_account_id = google_service_account.gke_sa[0].name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${data.google_project.current.number}@cloudservices.gserviceaccount.com"
}

