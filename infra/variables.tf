#
# Mandatory inputs
#

variable name {
  description = "The name prefix of the cluster"
}

variable region_name {
  description = "Name of the region to be used by the openstack provider (refers to OS_REGION_NAME)"
}

variable ovh_secret_path {
  description = "Path to the JSON file containing the OVH API credentials to use"
}

variable zone {
  description = "The domain zone where the ingress traffic will be registered"
  type = object({
    root      = string
    subdomain = string
  })

}

#
# Optional inputs
#

variable ovh_endpoint {
  description = "OVH API endpoint to use"
  default     = "ovh-eu"
}

variable allowed_ingress_prefixes {
  description = "Allowed ingress prefixes, separated by comma"
  type        = set(string)
  default     = []
}

// NOTE: keep variables in uppercase when they come from CDS env
variable allowed_mgmt_prefixes {
  description = "Allowed ingress prefixes for ssh & k8s, separated by comma"
  type        = set(string)
  default     = []
}

variable masters_flavor_name {
  description = "Master node flavor name"
  default     = "b2-7"
}

variable masters_nb {
  description = "Number of masters to deploy (should be an odd number)"
  default     = 3
}

variable workers_flavor_name {
  description = "Worker node flavor name"
  default     = "b2-7"
}

variable workers_nb {
  description = "Number of worker nodes to deploy for stateless"
  default     = 2
}

variable image_name {
  description = "Name of an image to boot the nodes from (OS should be Ubuntu 20.04)"
  default     = "Ubuntu 20.04"
}

variable ssh_user {
  description = "Name of the user used in image_name"
  default     = "ubuntu"
}
