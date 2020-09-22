output hosts {
  description = "Map of hosts"
  value = {
    "bastion" = [
      {
        name        = "bastion"
        public_ipv4 = module.network.bastion_ipv4
        ssh_user    = "ubuntu"
      }
    ]
    "masters" = module.masters.hosts
    "workers" = module.workers.hosts
  }
}

output kubernetes_advertise_ipv4 {
  description = "Kubernetes api adverise IP address"
  value       = module.masters.fip_list[0]
}

output allowed_ingress_prefixes {
  description = "IPv4 prefixes allowed for ingress"
  value       = var.allowed_ingress_prefixes
}

output ssh_config {
  description = "SSH config snippet to add to your ~/.ssh/config for easy access to the nodes"
  value       = <<EOF
Host ${var.name}-bastion
  Hostname ${ovh_domain_zone_record.bastion_registration.subdomain}.${var.zone.root}
  User ubuntu
  StrictHostKeyChecking no
%{for node in ovh_domain_zone_record.nodes_registration}
Host ${trimsuffix(node.subdomain, ".${var.name}")}
  Hostname ${node.subdomain}.${var.zone.root}
  User ubuntu
  ProxyJump ubuntu@${ovh_domain_zone_record.bastion_registration.subdomain}.${var.zone.root}
  StrictHostKeyChecking no
%{endfor}
EOF
}

output zone {
  value = "${var.zone.subdomain}.${var.zone.root}"
}

output ssh_private_key {
  sensitive = true
  value     = tls_private_key.ssh_key.private_key_pem
}

output name {
  value = var.name
}
