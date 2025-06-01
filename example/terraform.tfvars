project_id = "nw-opstree-dev-landing-zone"
region     = "us-central1"
network    = "default"
subnetwork = "default"
use_existing_sa       = false
service_account_id    = "gke-sa"
service_account_email = "" # Leave empty if creating a new SA
service_account_roles = [
  "roles/container.nodeServiceAccount",
  "roles/compute.instanceAdmin.v1",
  "roles/iam.serviceAccountUser"
]
clusters = {
  "dev-cluster" = {
    name               = "dev-cluster"
    location           = "us-central1-a"
    initial_node_count = 1
    autopilot          = false
    node_config = {
      machine_type = "e2-medium"
      disk_size_gb = 50
      disk_type    = "pd-standard"
    }
  }
  "autopilot-cluster" = {
    name      = "autopilot-cluster"
    location  = "us-central1"
    autopilot = true
  }
}