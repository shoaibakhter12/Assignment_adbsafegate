terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.7.0"
    }
  }
}

provider "kind" {}

resource "kind_cluster" "local_cluster" {
  name            = "ec2-k8s-cluster"
  node_image      = "kindest/node:v1.31.0"
  wait_for_ready  = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 30080
        host_port      = 8080
        listen_address = "0.0.0.0"
      }
    }
  }
}
