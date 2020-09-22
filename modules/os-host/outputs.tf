output "hosts" {
  description = "List of hosts"
  value = [
    for node in openstack_compute_instance_v2.node :
    {
      name        = node.name
      public_ipv4 = node.access_ip_v4
      ssh_user    = var.ssh_user
    }
  ]
}

output "fip_list" {
  description = "List of floating IP addresses"
  value = [
    for ips in openstack_networking_port_v2.fip[*].all_fixed_ips :
    [
      for ip in ips :
      ip
      if length(replace(ip, "/[[:alnum:]]+:[^,]+/", "")) > 0
    ][0]
  ]
}
