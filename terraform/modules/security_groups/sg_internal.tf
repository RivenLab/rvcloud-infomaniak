resource "openstack_networking_secgroup_v2" "all_internal_sg" {
  name                 = "all-internal-sg"
  description          = "Allow all internal traffic in lan subnet"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "all_internal_sg_rules" {
  for_each          = toset(local.linux_ingress_cidrs)
  direction         = "ingress"
  description       = "Allow all internal traffic"
  ethertype         = "IPv4"
  protocol          = null
  port_range_min    = null
  port_range_max    = null
  remote_ip_prefix  = each.value
  security_group_id = openstack_networking_secgroup_v2.all_internal_sg.id
}
