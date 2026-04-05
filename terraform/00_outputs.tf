output "bastion_public_ips" {
  value       = module.bastion.floating_ips
  description = "The Floating public IPs of Bastion"
}

output "bastion_internal_ips" {
  value       = module.bastion.internal_ips
  description = "The intranet-facing attached IPs"
}

output "bastion_ssh_access" {
  value = [
    for idx, ip in module.bastion.internal_ips :
    "ssh -i ~/.ssh/id_rsa root@${ip}"
  ]
}

output "consul_internal_ips" {
  value = module.consul.internal_ips
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
Endpoint = ${try(module.bastion.floating_ips[0], "YOUR_BASTION_PUBLIC_IP")}:51820
AllowedIPs = ${var.wg_subnet_cidr}, ${var.intranet_cidr}
PersistentKeepalive = 25
EOT
}
