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
    name                 = "dev-cluster"
    location             = "us-central1-a"
    initial_node_count   = 1
    min_node_count         = 1
    max_node_count         = 1
    autopilot            = false
    enable_private_nodes = false
    master_ipv4_cidr_block = "172.16.0.0/28" # Optional if private cluster

    node_config = {
      machine_type = "e2-medium"
      disk_size_gb = 50
      disk_type    = "pd-standard"
      spot         = false           # Optional, default false
      labels       = { env = "dev" } # Optional labels
      taints = [
        {
          key    = "dedicated"
          value  = "gpu"
          effect = "NO_SCHEDULE"
        },
        {
          key    = "team"
          value  = "data"
          effect = "PREFER_NO_SCHEDULE"
        }
      ] 
    }
  }

  "autopilot-cluster" = {
    name      = "autopilot-cluster"
    location  = "us-central1"
    autopilot = true
    # No node_config block needed for Autopilot
  }
}
