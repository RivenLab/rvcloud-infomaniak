module "consul" {
  source = "./modules/instance"

  instance_count    = 3
  instance_name     = "consul"
  instance_key_pair = openstack_compute_keypair_v2.default_key.name

  instance_security_groups = [
    module.security_groups.ssh_internal_sg_id,
    module.security_groups.consul_sg_id,
    module.security_groups.all_internal_sg_id,
    module.security_groups.allow_egress_sg_id,
    module.security_groups.icmp_sg_id
  ]

  instance_flavor           = var.instance_flavor
  instance_network_internal = module.network.network_id
  instance_subnet_internal  = module.network.subnet_id
  public_floating_ip        = false

  user_data = base64encode(templatefile("${path.root}/user_data/cloud-init.yaml", {
    ssh_public_key = var.ssh_public_key
  }))

  metadatas = {
    environment = "dev"
    app         = "consul"
  }
}
