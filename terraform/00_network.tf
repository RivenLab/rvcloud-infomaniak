# ---------------------------------------------------------------------------- #
#                                 Network Module                               #
# ---------------------------------------------------------------------------- #

module "network" {
  source                = "./modules/network"
  external_network_name = var.external_network_name
  intranet_cidr         = var.intranet_cidr
}

# ---------------------------------------------------------------------------- #
#                                Security Groups                               #
# ---------------------------------------------------------------------------- #

module "security_groups" {
  source         = "./modules/security_groups"
  intranet_cidr  = var.intranet_cidr
  wg_subnet_cidr = var.wg_subnet_cidr
}
