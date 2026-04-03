resource "openstack_networking_secgroup_v2" "allow_egress_sg" {
  name                 = "allow-egress-sg"
  description          = "Allow all egress traffic"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "allow_egress_rules" {
  for_each = {
    "out4" = { remote_ip_prefix = "0.0.0.0/0", ethertype = "IPv4" }
    "out6" = { remote_ip_prefix = "::/0", ethertype = "IPv6" }
  }

  description       = "Allow all egress traffic"
  direction         = "egress"
  ethertype         = lookup(each.value, "ethertype", "IPv4")
  remote_ip_prefix  = each.value.remote_ip_prefix
  security_group_id = openstack_networking_secgroup_v2.allow_egress_sg.id
}
