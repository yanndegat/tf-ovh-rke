#
# Mandatory inputs
#
variable name {
  description = "Prefix for the network name"
  type        = string
}

variable ssh_keypair {
  description = "ssh keypair allowed to connect to the ssh bastion host"
  type        = string
}

#
# Optional inputs
#
variable bastion_image_name {
  description = "image name used for the ssh bastion host"
  type        = string
  default     = "Ubuntu 20.04"
}

variable bastion_flavor_name {
  description = "flavor name used for the ssh bastion host"
  type        = string
  default     = "s1-2"
}

variable dns_nameservers {
  type        = set(string)
  description = "DNS nameservers"
  default     = ["213.186.33.99"]
}

variable remote_ssh_prefixes {
  description = "ipv4 prefixes allowed to connect to the ssh bastion host"
  type        = set(string)
  default     = []
}
