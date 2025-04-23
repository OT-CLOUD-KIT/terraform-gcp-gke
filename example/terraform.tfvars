project_id = "nw-opstree-dev-landing-zone"
region     = "us-central1"
network    = "default"
subnetwork = "default"
create_gke = true

# Set to true if using an existing service account
use_existing_sa       = false
service_account_email = "" # Required only if use_existing_sa = true
service_account_id    = "gke-custom-service-account"

# Optional override of default roles
service_account_roles = [
  "roles/container.nodeServiceAccount",
  "roles/compute.instanceAdmin.v1",
  "roles/iam.serviceAccountUser"
]

clusters = {
  gke-cluster-1 = {
    name               = "gke-cluster-1"
    location           = "us-central1"
    initial_node_count = 1
    node_config = {
      machine_type = "e2-medium"
      disk_size_gb = 20
    }
  }

  gke-cluster-2 = {
    name               = "gke-cluster-2"
    location           = "us-east1"
    initial_node_count = 1
    node_config = {
      machine_type = "e2-standard-2"
      disk_size_gb = 20
    }
  }
}