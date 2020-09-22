terraform {
  backend "swift" {}
}

locals {
  ovh_creds = jsondecode(file(var.ovh_secret_path))

  nodes_dns_entries = zipmap(
    concat(
      module.masters.hosts[*].name,
      module.workers.hosts[*].name,
    ),
    concat(
      module.masters.hosts[*].public_ipv4,
      module.workers.hosts[*].public_ipv4,
  ))
}

provider ovh {
  endpoint           = var.ovh_endpoint
  application_key    = local.ovh_creds["application_key"]
  application_secret = local.ovh_creds["application_secret"]
  consumer_key       = local.ovh_creds["consumer_key"]
}

provider openstack {
  cloud  = var.name
  region = var.region_name
}

resource tls_private_key ssh_key {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource openstack_compute_keypair_v2 keypair {
  name       = var.name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

#
# Network objects
#
data openstack_networking_network_v2 ext_net {
  name      = "Ext-Net"
  tenant_id = ""
}

module network {
  source = "github.com/yanndegat/tf-ovh-rke//modules/os-network"

  name                = var.name
  remote_ssh_prefixes = var.allowed_mgmt_prefixes
  ssh_keypair         = openstack_compute_keypair_v2.keypair.name
}

#
# Security groups
#
module masters-sg {
  source = "github.com/yanndegat/tf-ovh-rke//modules/os-secgroup"

  name = "${var.name}-masters"

  allowed_ingress_prefixes = var.allowed_mgmt_prefixes
  allowed_ingress_tcp      = [6443]

  allowed_ssh_sg_ids = [module.network.bastion_sg_id]

  allowed_sg_ids = [
    module.workers-sg.id,
    module.network.bastion_sg_id, # Rke tunnels k8s calls on port 6443 through bastion host
  ]
}

module workers-sg {
  source = "github.com/yanndegat/tf-ovh-rke//modules/os-secgroup"

  name = "${var.name}-workers"

  allowed_ingress_prefixes = var.allowed_ingress_prefixes

  allowed_ingress_tcp = ["30000-32767"]

  allowed_ssh_sg_ids = [module.network.bastion_sg_id]

  allowed_sg_ids = [
    module.masters-sg.id,
  ]

}

#
# Kubernetes cluster nodes
#
module masters {
  source = "github.com/yanndegat/tf-ovh-rke//modules/os-host"

  flavor_name = var.masters_flavor_name
  image_name  = var.image_name
  name        = "${var.name}-masters"
  nb          = var.masters_nb
  ssh_keypair = openstack_compute_keypair_v2.keypair.name
  secgroup_id = module.masters-sg.id
  ssh_user    = var.ssh_user
}

module workers {
  source = "github.com/yanndegat/tf-ovh-rke//modules/os-host"

  flavor_name = var.workers_flavor_name
  image_name  = var.image_name
  name        = "${var.name}-workers"
  nb          = var.workers_nb
  ssh_keypair = openstack_compute_keypair_v2.keypair.name
  secgroup_id = module.workers-sg.id
  ssh_user    = var.ssh_user
}

data ovh_domain_zone zone {
  name = var.zone.root
}


# Domain name registration

# register only master 0
# NOTE: WARNING! kubernetes is thus not HA:
#       if you lose node 0, you have to manually
#       switch dns records to next master
resource ovh_domain_zone_record kubernetes_registration {
  zone      = data.ovh_domain_zone.zone.name
  subdomain = "kubernetes.${var.zone.subdomain}"
  fieldtype = "A"
  target    = module.masters.fip_list[0]
}


# Register bastion node to get easy access
resource ovh_domain_zone_record bastion_registration {
  zone      = data.ovh_domain_zone.zone.name
  subdomain = "bastion.${var.zone.subdomain}"
  fieldtype = "A"
  target    = module.network.bastion_ipv4
}

# Register all nodes to get easy access
resource ovh_domain_zone_record nodes_registration {
  for_each = local.nodes_dns_entries

  zone      = data.ovh_domain_zone.zone.name
  subdomain = "${each.key}.${var.zone.subdomain}"
  fieldtype = "A"
  target    = each.value
}

# a wildcard dns record is useful for temporary deployments for integration tests
resource ovh_domain_zone_record wildcard_registration {
  count = var.workers_nb

  zone      = data.ovh_domain_zone.zone.name
  subdomain = "*.${var.zone.subdomain}"
  fieldtype = "A"
  target    = module.workers.fip_list[count.index]
}
