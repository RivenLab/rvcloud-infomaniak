# External network data source
data "openstack_networking_network_v2" "ext_floating" {
  name = var.external_network_name
}

# Networks
resource "openstack_networking_network_v2" "intranet_net" {
  name           = "Intranet"
  admin_state_up = true
}

# Subnets

resource "openstack_networking_subnet_v2" "intranet_subnet" {
  name            = "Intranet-subnet"
  network_id      = openstack_networking_network_v2.intranet_net.id
  cidr            = var.intranet_cidr
  enable_dhcp     = true
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

# Router
resource "openstack_networking_router_v2" "lan_router" {
  name                = "lan-router"
  external_network_id = data.openstack_networking_network_v2.ext_floating.id
}

resource "openstack_networking_router_interface_v2" "lan_router_interface" {
  router_id = openstack_networking_router_v2.lan_router.id
  subnet_id = openstack_networking_subnet_v2.intranet_subnet.id
}

# ---------------------------------------------------------------------------- #
#                                Security Groups                               #
# ---------------------------------------------------------------------------- #

module "security_groups" {
  source         = "./modules/security_groups"
  intranet_cidr  = var.intranet_cidr
  wg_subnet_cidr = var.wg_subnet_cidr
}
