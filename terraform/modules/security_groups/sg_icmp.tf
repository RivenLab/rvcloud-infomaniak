resource "openstack_networking_secgroup_v2" "icmp_sg" {
  name                 = "icmp-sg"
  description          = "Allow ICMP Ping"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "icmp_rules" {
  direction         = "ingress"
  description       = "Allow ICMP"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.icmp_sg.id
}
