# ---------------------------------------------------------------------------- #
#                                SSH Key Pair                                  #
# ---------------------------------------------------------------------------- #

resource "openstack_compute_keypair_v2" "bastion_rsa_keypair" {
  name       = "bastion-keypair"
  public_key = var.ssh_public_key
}

# ---------------------------------------------------------------------------- #
#                           Bastion-Proxy Port                                 #
# ---------------------------------------------------------------------------- #

resource "openstack_networking_port_v2" "bastion_proxy_port" {
  name                  = "bastion-proxy-port"
  network_id            = openstack_networking_network_v2.intranet_net.id
  admin_state_up        = true
  port_security_enabled = true
  security_group_ids = [
    module.security_groups.ssh_internal_sg_id,
    module.security_groups.wireguard_sg_id,
    module.security_groups.proxy_sg_id,
    module.security_groups.allow_egress_sg_id,
    module.security_groups.icmp_sg_id
  ]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.intranet_subnet.id
  }
}

# ---------------------------------------------------------------------------- #
#                                 Floating IP                                  #
# ---------------------------------------------------------------------------- #

resource "openstack_networking_floatingip_v2" "bastion_floating" {
  pool = data.openstack_networking_network_v2.ext_floating.name

  depends_on = [
    openstack_networking_router_interface_v2.lan_router_interface
  ]
}

resource "openstack_networking_floatingip_associate_v2" "bastion_fip" {
  floating_ip = openstack_networking_floatingip_v2.bastion_floating.address
  port_id     = openstack_networking_port_v2.bastion_proxy_port.id

  depends_on = [
    openstack_networking_router_interface_v2.lan_router_interface
  ]
}

# ---------------------------------------------------------------------------- #
#                              Bastion-Proxy Instance                          #
# ---------------------------------------------------------------------------- #

data "openstack_images_image_v2" "bastion_image" {
  name_regex  = "^Ubuntu 24.04 LTS"
  most_recent = true
}

data "openstack_compute_flavor_v2" "bastion_flavor" {
  name = var.bastion_proxy_flavor
}

resource "openstack_compute_instance_v2" "bastion_proxy" {
  name      = "bastion-proxy"
  image_id  = data.openstack_images_image_v2.bastion_image.id
  flavor_id = data.openstack_compute_flavor_v2.bastion_flavor.id
  key_pair  = openstack_compute_keypair_v2.bastion_rsa_keypair.name
  user_data = base64encode(templatefile("${path.module}/data/cloud-init-bastion.yaml", {
    ssh_public_key        = var.ssh_public_key
    wg_server_address     = var.wg_server_address
    wg_server_private_key = var.wg_server_private_key
    wg_client_public_key  = var.wg_client_public_key
    wg_client_allowed_ips = var.wg_client_allowed_ips
    wg_preshared_key      = var.wg_preshared_key
  }))

  block_device {
    uuid                  = data.openstack_images_image_v2.bastion_image.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.bastion_volume_size
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.bastion_proxy_port.id
  }

  depends_on = [
    openstack_networking_subnet_v2.intranet_subnet,
    openstack_networking_router_interface_v2.lan_router_interface
  ]
}