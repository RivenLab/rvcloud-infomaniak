locals {
  ssh_ingress_cidrs = [var.intranet_cidr, var.wg_subnet_cidr]
}

resource "openstack_networking_secgroup_v2" "ssh_internal_sg" {
  name                 = "ssh-internal-sg"
  description          = "Allow SSH traffic from intranet and VPN"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "ssh_internal_rules" {
  for_each          = toset(local.ssh_ingress_cidrs)
  direction         = "ingress"
  description       = "Allow SSH access"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = each.value
  security_group_id = openstack_networking_secgroup_v2.ssh_internal_sg.id
}
