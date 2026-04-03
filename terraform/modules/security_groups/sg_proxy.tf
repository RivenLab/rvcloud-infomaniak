resource "openstack_networking_secgroup_v2" "proxy_sg" {
  name                 = "proxy-sg"
  description          = "Allow HTTP and HTTPS traffic from internet"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "proxy_rules" {
  for_each = {
    "http"  = { protocol = "tcp", port = 80 }
    "https" = { protocol = "tcp", port = 443 }
  }

  direction         = "ingress"
  description       = "Allow Web access"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.proxy_sg.id
}
