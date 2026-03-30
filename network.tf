# External network data source
data "openstack_networking_network_v2" "ext_floating" {
  name = var.external_network_name
}

# Networks
resource "openstack_networking_network_v2" "internet_net" {
  name           = "Internet"
  admin_state_up = true
}

resource "openstack_networking_network_v2" "intranet_net" {
  name           = "Intranet"
  admin_state_up = true
}

# Subnets
resource "openstack_networking_subnet_v2" "internet_subnet" {
  name            = "Internet-subnet"
  network_id      = openstack_networking_network_v2.internet_net.id
  cidr            = var.internet_cidr
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
}

resource "openstack_networking_subnet_v2" "intranet_subnet" {
  name            = "Intranet-subnet"
  network_id      = openstack_networking_network_v2.intranet_net.id
  cidr            = var.intranet_cidr
  ip_version      = 4
  dns_nameservers = ["1.1.1.1", "8.8.8.8"]
  gateway_ip      = var.opnsense_intranet_ip
}

# Router
resource "openstack_networking_router_v2" "lan_router" {
  name                = "lan-router"
  external_network_id = data.openstack_networking_network_v2.ext_floating.id
}

resource "openstack_networking_router_interface_v2" "lan_router_interface" {
  router_id = openstack_networking_router_v2.lan_router.id
  subnet_id = openstack_networking_subnet_v2.internet_subnet.id
}

# ---------------------------------------------------------------------------- #
#                                Security Groups                               #
# ---------------------------------------------------------------------------- #

# OPNsense Edge Gateway Security Group
resource "openstack_networking_secgroup_v2" "opnsense_sg" {
  name                 = "opnsense-sg"
  description          = "Security group for Edge Gateway OPNsense"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "opnsense_sg_rules" {
  for_each = {
    "tcp"  = { protocol = "tcp", remote_ip_prefix = "0.0.0.0/0", direction = "ingress" }
    "udp"  = { protocol = "udp", remote_ip_prefix = "0.0.0.0/0", direction = "ingress" }
    "icmp" = { protocol = "icmp", remote_ip_prefix = "0.0.0.0/0", direction = "ingress" }
    "esp"  = { protocol = "51", remote_ip_prefix = "0.0.0.0/0", direction = "ingress" }
    "ah"   = { protocol = "50", remote_ip_prefix = "0.0.0.0/0", direction = "ingress" }
    "out4" = { protocol = null, remote_ip_prefix = "0.0.0.0/0", direction = "egress", ethertype = "IPv4" }
    "out6" = { protocol = null, remote_ip_prefix = "::/0", direction = "egress", ethertype = "IPv6" }
  }

  description       = "Allow all traffic in and out"
  direction         = each.value.direction
  ethertype         = lookup(each.value, "ethertype", "IPv4")
  protocol          = each.value.protocol
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.opnsense_sg.id
}

# Linux Backend Servers Security Group
resource "openstack_networking_secgroup_v2" "linux_sg" {
  name                 = "linux-sg"
  description          = "Least Privilege Security group for backend Linux VMs"
  delete_default_rules = true
}

# Allow inbound SSH
resource "openstack_networking_secgroup_rule_v2" "linux_sg_ingress_ssh" {
  direction         = "ingress"
  description       = "Allow SSH access"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0" # Consider restricting to intranet CIDR ideally
  security_group_id = openstack_networking_secgroup_v2.linux_sg.id
}

# Allow inbound http
resource "openstack_networking_secgroup_rule_v2" "linux_sg_ingress_http" {
  direction         = "ingress"
  description       = "Allow HTTP access"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.linux_sg.id
}

# Allow inbound https
resource "openstack_networking_secgroup_rule_v2" "linux_sg_ingress_https" {
  direction         = "ingress"
  description       = "Allow HTTPS access"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.linux_sg.id
}

# Allow ICMP (Ping) locally
resource "openstack_networking_secgroup_rule_v2" "linux_sg_ingress_icmp" {
  direction         = "ingress"
  description       = "Allow ICMP"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.linux_sg.id
}

# Allow all outbound traffic from Linux VMs
resource "openstack_networking_secgroup_rule_v2" "linux_sg_egress_ipv4" {
  direction         = "egress"
  description       = "Allow all outbound traffic"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.linux_sg.id
}
