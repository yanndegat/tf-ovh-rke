output bastion_sg_id {
  description = "Id of the bastion sec group"
  value       = openstack_networking_secgroup_v2.bastion_sg.id
}

output bastion_ipv4 {
  description = "IPV4 of the bastion host"
  value       = openstack_compute_instance_v2.bastion.access_ip_v4
}
