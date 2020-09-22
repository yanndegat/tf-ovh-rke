data openstack_images_image_v2 rke {
  name        = var.image_name
  most_recent = true
}

data openstack_networking_network_v2 ext_net {
  name      = var.floating_ip_pool
  tenant_id = ""
}

resource openstack_networking_port_v2 fip {
  count          = var.nb
  name           = "${var.name}_fip"
  network_id     = data.openstack_networking_network_v2.ext_net.id
  admin_state_up = "true"

  security_group_ids = [
    var.secgroup_id
  ]
}

# Create instance
resource openstack_compute_instance_v2 node {
  count       = var.nb
  name        = "${var.name}-${format("%03d", count.index)}"
  image_id    = data.openstack_images_image_v2.rke.id
  flavor_name = var.flavor_name
  key_pair    = var.ssh_keypair

  network {
    port           = openstack_networking_port_v2.fip[count.index].id
    access_network = true
  }

  lifecycle {
    ignore_changes = [user_data, image_id, key_pair]
  }
}
