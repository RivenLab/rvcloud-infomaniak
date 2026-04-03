# ---------------------------------------------------------------------------- #
#                                Bastion Proxy                                 #
# ---------------------------------------------------------------------------- #

output "bastion_proxy_public_ip" {
  value       = openstack_networking_floatingip_v2.bastion_floating.address
  description = "The Floating public IP of the Bastion Proxy"
}

output "bastion_proxy_internal_ip" {
  value       = openstack_networking_port_v2.bastion_proxy_port.all_fixed_ips[0]
  description = "The intranet-facing attached IP"
}

output "bastion_proxy_ssh_access" {
  value = "ssh -i ~/.ssh/id_rsa root@$${openstack_networking_port_v2.bastion_proxy_port.all_fixed_ips[0]}"
}

output "wireguard_client_config" {
  description = "WireGuard Client Configuration Template"
  value       = <<EOT
[Interface]
PrivateKey = <YOUR_CLIENT_PRIVATE_KEY>
Address = ${var.wg_client_allowed_ips}

[Peer]
PublicKey = ${var.wg_server_public_key}
PresharedKey =
Endpoint = ${openstack_networking_floatingip_v2.bastion_floating.address}:51820
AllowedIPs = ${var.wg_subnet_cidr}, ${var.intranet_cidr}
PersistentKeepalive = 25
EOT
}

# ---------------------------------------------------------------------------- #
#                              Linux Backend VMs                               #
# ---------------------------------------------------------------------------- #

output "linux_vms_internal_ips" {
  description = "Assigned IPS of the backend Linux VMs"
  value = {
    for name, port in openstack_networking_port_v2.linux_ports :
    name => port.all_fixed_ips[0]
  }
}
