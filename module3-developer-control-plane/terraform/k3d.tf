terraform {
  required_providers {
    k3d = {
      source  = "sneakybugs/k3d"
      version = "1.0.1"
    }
  }
}

resource "k3d_cluster" "example_cluster" {
  name = "example"
  # See https://k3d.io/v5.4.6/usage/configfile/#config-options
  k3d_config = <<EOF
apiVersion: k3d.io/v1alpha5
kind: Simple

registries:
  create:
    name: dev
    hostPort: "5000"

options:
  k3d: # k3d runtime settings
    wait: true
    
EOF
}

provider "kubernetes" {
  host                   = resource.k3d_cluster.example_cluster.host
  client_certificate     = base64decode(resource.k3d_cluster.example_cluster.client_certificate)
  client_key             = base64decode(resource.k3d_cluster.example_cluster.client_key)
  cluster_ca_certificate = base64decode(resource.k3d_cluster.example_cluster.cluster_ca_certificate)
}
