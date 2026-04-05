module "bastion" {
  source = "./modules/instance"

  instance_count    = 1
  instance_name     = "bastion"
  instance_key_pair = openstack_compute_keypair_v2.default_key.name

  instance_security_groups = [
    module.security_groups.ssh_internal_sg_id,
    module.security_groups.wireguard_sg_id,
    module.security_groups.proxy_sg_id,
    module.security_groups.allow_egress_sg_id,
    module.security_groups.icmp_sg_id
  ]

  instance_network_internal      = module.network.network_id
  instance_subnet_internal       = module.network.subnet_id
  instance_network_external_name = module.network.ext_floating_network_name
  public_floating_ip             = true

  instance_flavor = var.bastion_proxy_flavor

  user_data = base64encode(templatefile("${path.root}/user_data/cloud-init-bastion.yaml", {
    ssh_public_key        = var.ssh_public_key
    wg_server_address     = var.wg_server_address
    wg_server_private_key = var.wg_server_private_key
    wg_client_public_key  = var.wg_client_public_key
    wg_client_allowed_ips = var.wg_client_allowed_ips
    wg_preshared_key      = var.wg_preshared_key
  }))

  metadatas = {
    environment = "dev"
    app         = "proxy"
  }
}
