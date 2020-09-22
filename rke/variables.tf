#
# Mandatory inputs
#

variable name {
  type        = string
  description = "Cluster name"
}

variable zone {
  type        = string
  description = "dns zone"
}


variable hosts {
  type = map(list(object({
    name        = string
    public_ipv4 = string
    ssh_user    = string
  })))

  description = "infra hosts"
}


#
# Optional inputs
#
variable local_volume_hostpath {
  description = "Path on hosts where to store local volumes"
  type        = string
  default     = "/mnt/volumes"
}

variable node_port_range {
  description = "Expose a different port range for NodePort services"
  type        = string
  default     = "30000-32767"
}

variable rke_k8s_version {
  description = "Kubernetes version supported by rke"
  default     = "v1.18.8-rancher1-1"
}


variable debug {
  description = "Enable RKE debug logs."
  default     = false
}

variable debug_log_file {
  description = "RKE debug logs."
  default     = ""
}

variable ssh_private_key {
  description = "ssh private key"
  type        = string
}
