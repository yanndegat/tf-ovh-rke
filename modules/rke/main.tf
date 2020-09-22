# Provision RKE
resource rke_cluster "cluster" {
  cluster_name       = var.name
  kubernetes_version = var.kubernetes_version

  addon_job_timeout = 180

  dynamic nodes {
    for_each = var.nodes
    content {
      address           = nodes.value.address
      hostname_override = nodes.value.hostname_override
      labels            = nodes.value.labels
      node_name         = nodes.value.node_name
      role              = nodes.value.role
      ssh_key           = var.ssh_private_key
      user              = nodes.value.user

      dynamic taints {
        for_each = nodes.value.taints
        content {
          key    = taints.value.key
          effect = taints.value.effect
          value  = taints.value.value
        }
      }
    }
  }

  bastion_host {
    address = var.ssh_bastion_host
    ssh_key = var.ssh_private_key
    user    = var.ssh_bastion_user
    port    = 22
  }

  authentication {
    strategy = "x509"
    sans     = var.kubeapi_sans_list
  }

  authorization {
    mode = "rbac"
  }

  network {
    plugin = "calico"
  }

  # we have to disable the default nginx provider to further install traefik instead
  ingress {
    provider = "none"
  }

  dns {
    provider             = "coredns"
    upstream_nameservers = ["213.186.33.99"]

    nodelocal {
      ip_address = "169.254.20.10"
    }
  }

  services {
    kubelet {
      cluster_dns_server = cidrhost(var.kubernetes_service_range, 10)

      extra_binds = concat([
        "/usr/libexec/kubernetes/kubelet-plugins:/usr/libexec/kubernetes/kubelet-plugins",
      ], var.extra_binds)
    }

    kube_api {
      service_cluster_ip_range = var.kubernetes_service_range
      service_node_port_range  = var.node_port_range
      pod_security_policy      = false
    }

    kube_controller {
      service_cluster_ip_range = var.kubernetes_service_range
      cluster_cidr             = var.kubernetes_pod_range
    }

    kubeproxy {
      extra_args = {
        proxy-mode = "ipvs"
      }
    }
  }

  ignore_docker_version = var.ignore_docker_version
}
