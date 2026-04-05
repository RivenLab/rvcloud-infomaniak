output "internal_ips" {
  description = "Assigned IPS of the instances"
  value = {
    for idx, port in openstack_networking_port_v2.port :
    "${var.instance_name}-${idx + 1}" => port.all_fixed_ips[0]
  }
}

output "floating_ips" {
  description = "Floating IPs assigned if any"
  value       = var.public_floating_ip ? [for fip in openstack_networking_floatingip_v2.fip : fip.address] : []
}
