output "allow_egress_sg_id" {
  value = openstack_networking_secgroup_v2.allow_egress_sg.id
}

output "ssh_internal_sg_id" {
  value = openstack_networking_secgroup_v2.ssh_internal_sg.id
}

output "wireguard_sg_id" {
  value = openstack_networking_secgroup_v2.wireguard_sg.id
}

output "proxy_sg_id" {
  value = openstack_networking_secgroup_v2.proxy_sg.id
}

output "consul_sg_id" {
  value = openstack_networking_secgroup_v2.consul_sg.id
}

output "icmp_sg_id" {
  value = openstack_networking_secgroup_v2.icmp_sg.id
}

output "all_internal_sg_id" {
  value = openstack_networking_secgroup_v2.all_internal_sg.id
}
