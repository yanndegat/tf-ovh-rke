variable nb {
  description = "Number of nodes to be created"
}

variable name {
  description = "Prefix for the node resources"
}

variable flavor_name {
  description = "Flavor to be used for nodes"
  default     = "b2-7"
}

variable image_name {
  description = "Image to boot nodes from"
  default     = "Ubuntu 20.04"
}

variable ssh_user {
  description = "SSH user name"
}

variable ssh_keypair {
  description = "SSH keypair to inject in the instance (previosly created in OpenStack)"
}

variable secgroup_id {
  description = "id of the security group for nodes"
}

variable floating_ip_pool {
  description = "Name of the floating IP pool (don't leave it empty if assign_floating_ip is true)"
  default     = "Ext-Net"
}
