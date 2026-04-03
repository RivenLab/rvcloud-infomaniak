resource "openstack_networking_secgroup_v2" "wireguard_sg" {
  name                 = "wireguard-sg"
  description          = "Allow Wireguard traffic from internet"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "wireguard_rules" {
  direction         = "ingress"
  description       = "Allow Wireguard access"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 51820
  port_range_max    = 51820
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.wireguard_sg.id
}
