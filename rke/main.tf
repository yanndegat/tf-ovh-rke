terraform {
  backend "swift" {}
}

provider rke {
  debug    = var.debug
  log_file = var.debug_log_file
}

locals {
  k8s_ext_addr = "kubernetes.${var.zone}"

  nodes = concat(
    [
      for m in var.hosts.masters : {
        address           = m.public_ipv4
        hostname_override = m.name
        ip                = m.public_ipv4
        node_name         = m.name
        role              = ["controlplane", "etcd"]
        user              = m.ssh_user
        labels = {
          "wescale-master" = "enabled"
        }
        taints = []
      }
    ],
    [
      for m in var.hosts.workers : {
        address           = m.public_ipv4
        hostname_override = m.name
        ip                = m.public_ipv4
        node_name         = m.name
        role              = ["worker"]
        user              = m.ssh_user

        labels = {
          "wescale-worker" = "enabled"
        }
        taints = []
      }
    ]
  )
}

module "rke" {
  source = "github.com/yanndegat/tf-ovh-rke//modules/rke"

  extra_binds        = ["${var.local_volume_hostpath}:${var.local_volume_hostpath}:rshared"]
  kubeapi_sans_list  = concat([for m in var.hosts["masters"] : m.public_ipv4], [local.k8s_ext_addr])
  kubernetes_version = var.rke_k8s_version
  name               = var.name
  node_port_range    = var.node_port_range
  nodes              = local.nodes
  ssh_bastion_host   = var.hosts.bastion[0].public_ipv4
  ssh_bastion_user   = var.hosts.bastion[0].ssh_user
  ssh_private_key    = var.ssh_private_key
}

