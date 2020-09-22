variable name {
  type        = string
  description = "Cluster name"
}

variable nodes {
  type = list(object({
    address           = string
    hostname_override = string
    ip                = string
    node_name         = string
    role              = set(string)
    user              = string

    labels = map(string)
    taints = set(object({
      key    = string
      effect = string
      value  = string
    }))
  }))

  description = "Node mappings for RKE provisioning"
}

variable ssh_bastion_host {
  description = "Bastion SSH host"
  type        = string
}

variable ssh_bastion_user {
  description = "Bastion SSH user"
  type        = string
}

variable ssh_private_key {
  description = "ssh private key"
  type        = string
}

variable kubeapi_sans_list {
  type        = set(string)
  description = "SANS for the Kubernetes server API"
}

variable ignore_docker_version {
  description = "If true RKE won't check Docker version on images"
  default     = true
}

variable extra_binds {
  description = "Extra binds for kubelet"
  default     = []
}

variable kubernetes_version {
  description = "kubernetes version supported by rke"
  default     = "v1.18.8-rancher1-1"
}

variable node_port_range {
  description = "kubernetes API allowed range for NodePort resources"
  default     = null
}

variable kubernetes_pod_range {
  type        = string
  description = "Kubernetes ipv4 pod range"
  default     = "172.30.0.0/16"
}

variable kubernetes_service_range {
  type        = string
  description = "Kubernetes ipv4 service range"
  default     = "172.29.0.0/16"
}
