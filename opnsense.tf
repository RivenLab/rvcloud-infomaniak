# SSH Key Pair
resource "openstack_compute_keypair_v2" "opnsense_rsa_keypair" {
  name       = "opnsense-keypair"
  public_key = var.password_rsa_key
}

# ---------------------------------------------------------------------------- #
#                                OPNsense Ports                                #
# ---------------------------------------------------------------------------- #

resource "openstack_networking_port_v2" "opnsense_internet_port" {
  name                  = "opnsense-internet-port"
  network_id            = openstack_networking_network_v2.internet_net.id
  admin_state_up        = true
  security_group_ids    = [openstack_networking_secgroup_v2.opnsense_sg.id]
  port_security_enabled = true

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.internet_subnet.id
    ip_address = var.opnsense_internet_ip
  }
}

resource "openstack_networking_port_v2" "opnsense_intranet_port" {
  name                  = "opnsense-intranet-port"
  network_id            = openstack_networking_network_v2.intranet_net.id
  admin_state_up        = true
  security_group_ids    = []
  no_security_groups    = true
  port_security_enabled = false

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.intranet_subnet.id
    ip_address = var.opnsense_intranet_ip
  }
}

# ---------------------------------------------------------------------------- #
#                                 Floating IP                                  #
# ---------------------------------------------------------------------------- #

resource "openstack_networking_floatingip_v2" "opnsense_floating" {
  pool = data.openstack_networking_network_v2.ext_floating.name

  depends_on = [
    openstack_networking_router_interface_v2.lan_router_interface
  ]
}

resource "openstack_networking_floatingip_associate_v2" "opnsense_fip" {
  floating_ip = openstack_networking_floatingip_v2.opnsense_floating.address
  port_id     = openstack_networking_port_v2.opnsense_internet_port.id

  depends_on = [
    openstack_networking_router_interface_v2.lan_router_interface
  ]
}

# ---------------------------------------------------------------------------- #
#                              OPNsense Instance                               #
# ---------------------------------------------------------------------------- #

data "openstack_images_image_v2" "opnsense" {
  name_regex  = "^OPNsense"
  most_recent = true
}

data "openstack_compute_flavor_v2" "opnsense_flavor" {
  name = var.opnsense_flavor
}

resource "openstack_compute_instance_v2" "opnsense" {
  name      = "opnsense"
  image_id  = data.openstack_images_image_v2.opnsense.id
  flavor_id = data.openstack_compute_flavor_v2.opnsense_flavor.id
  key_pair  = openstack_compute_keypair_v2.opnsense_rsa_keypair.name

  # LAN Interface (Connected to router)
  network {
    port = openstack_networking_port_v2.opnsense_internet_port.id
  }

  # Inside Interface (Isolated network)
  network {
    port = openstack_networking_port_v2.opnsense_intranet_port.id
  }

  depends_on = [
    openstack_networking_subnet_v2.internet_subnet,
    openstack_networking_subnet_v2.intranet_subnet,
    openstack_networking_router_interface_v2.lan_router_interface
  ]
}

# ---------------------------------------------------------------------------- #
#                                    Outputs                                   #
# ---------------------------------------------------------------------------- #

output "opnsense_public_ip" {
  value       = openstack_networking_floatingip_v2.opnsense_floating.address
  description = "The Floating public IP of the OPNsense gateway"
}

output "opnsense_internet_subnet_ip" {
  value       = openstack_networking_port_v2.opnsense_internet_port.all_fixed_ips[0]
  description = "The internet-facing attached IP"
}

output "opnsense_intranet_subnet_ip" {
  value       = openstack_networking_port_v2.opnsense_intranet_port.all_fixed_ips[0]
  description = "The intranet-facing attached IP"
}

output "ssh_access_command" {
  value = "ssh -i ~/.ssh/your_private_key root@${openstack_networking_floatingip_v2.opnsense_floating.address}"
}

output "configuration_notes" {
  value = <<EOT
OPNsense Configuration Notes:
1. Login to web interface: https://${openstack_networking_floatingip_v2.opnsense_floating.address}
2. Configure interfaces:
   - WAN (should auto-detect as ${openstack_networking_port_v2.opnsense_internet_port.all_fixed_ips[0]})
   - LAN (assign to ${openstack_networking_port_v2.opnsense_intranet_port.all_fixed_ips[0]})
3. Enable DHCP server on Inside network (${var.intranet_cidr}) if needed
4. Configure firewall rules between networks
EOT
}
