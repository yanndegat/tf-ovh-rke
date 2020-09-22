locals {
  secgroups = setunion(var.allowed_sg_ids, [openstack_networking_secgroup_v2.secgroup.id])

  tcp_pairs = [
    for pair in setproduct(
      var.allowed_ingress_tcp,
      var.allowed_ingress_prefixes) : {
      ports    = pair[0]
      port_min = split("-", pair[0])[0]
      port_max = length(split("-", pair[0])) == 2 ? split("-", pair[0])[1] : split("-", pair[0])[0]
      prefix   = pair[1]
    }
  ]
  udp_pairs = [
    for pair in setproduct(
      var.allowed_ingress_udp,
      var.allowed_ingress_prefixes) : {
      ports    = pair[0]
      port_min = split("-", pair[0])[0]
      port_max = length(split("-", pair[0])) == 2 ? split("-", pair[0])[1] : split("-", pair[0])[0]
      prefix   = pair[1]
    }
  ]
}

resource openstack_networking_secgroup_v2 secgroup {
  name        = "${var.name}-secgroup"
  description = "Security gropup for RKE"
}

resource openstack_networking_secgroup_rule_v2 internal_ssh {
  count = length(var.allowed_ssh_sg_ids)

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_group_id   = tolist(var.allowed_ssh_sg_ids)[count.index]
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource openstack_networking_secgroup_rule_v2 internal {
  count = length(local.secgroups)

  direction         = "ingress"
  ethertype         = "IPv4"
  remote_group_id   = tolist(local.secgroups)[count.index]
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource openstack_networking_secgroup_rule_v2 ingress_udp_v2 {
  for_each = {
    for pair in local.udp_pairs : "${pair.ports}.${pair.prefix}" => pair
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = each.value.port_min
  port_range_max    = each.value.port_max
  remote_ip_prefix  = each.value.prefix
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource openstack_networking_secgroup_rule_v2 ingress_tcp_v2 {
  for_each = {
    for pair in local.tcp_pairs : "${pair.ports}.${pair.prefix}" => pair
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port_min
  port_range_max    = each.value.port_max
  remote_ip_prefix  = each.value.prefix
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
