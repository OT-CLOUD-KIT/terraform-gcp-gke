project_id            = "landing-zone"
region                = "us-central1"
network               = "default"
subnetwork            = "default"
use_existing_sa       = false
service_account_id    = "gke-sa"
service_account_email = "" # Leave empty if creating a new SA
service_account_roles = [
  "roles/container.nodeServiceAccount",
  "roles/compute.instanceAdmin.v1",
  "roles/iam.serviceAccountUser"
]
ssh_keys = "ssh-rsa"
clusters = {
  "dev-cluster" = {
    name                   = "dev-cluster"
    location               = "us-central1-a"
    autopilot              = false
    initial_node_count     = 1
    enable_private_nodes   = true
    master_ipv4_cidr_block = "172.16.0.0/28"

    node_pools = {
      "default-pool" = {
        machine_type   = "e2-medium"
        disk_size_gb   = 50
        disk_type      = "pd-standard"
        image_type     = "COS_CONTAINERD" 
        min_node_count = 1
        max_node_count = 2
        node_count     = 1 
        spot           = false
        labels         = { env = "dev" }
        taints         = []
      }

      "gpu-pool" = {
        machine_type   = "n1-standard-4"
        disk_size_gb   = 100
        disk_type      = "pd-ssd"
        image_type     = "UBUNTU_CONTAINERD" 
        min_node_count = 0
        max_node_count = 1
        node_count     = 1 
        spot           = true
        labels         = { env = "dev", type = "gpu" }
        taints = [
          {
            key    = "dedicated"
            value  = "gpu"
            effect = "NO_SCHEDULE"
          }
        ]
      }
    }
  }
}
