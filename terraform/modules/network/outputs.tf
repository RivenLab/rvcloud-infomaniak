output "network_id" {
  description = "ID of the intranet network"
  value       = openstack_networking_network_v2.intranet_net.id
}

output "subnet_id" {
  description = "ID of the intranet subnet"
  value       = openstack_networking_subnet_v2.intranet_subnet.id
}

output "router_interface_id" {
  description = "ID of the LAN router interface, for dependency chaining"
  value       = openstack_networking_router_interface_v2.lan_router_interface.id
}

output "ext_floating_network_name" {
  description = "Name of the external floating network"
  value       = data.openstack_networking_network_v2.ext_floating.name
}
