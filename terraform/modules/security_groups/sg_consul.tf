resource "openstack_networking_secgroup_v2" "consul_sg" {
  name                 = "consul-sg"
  description          = "Allow HashiCorp Consul internal traffic"
  delete_default_rules = true
}

locals {
  consul_ports = {
    "server-rpc" = { protocol = "tcp", port = 8300 }
    "serf-lan-t" = { protocol = "tcp", port = 8301 }
    "serf-lan-u" = { protocol = "udp", port = 8301 }
    "serf-wan-t" = { protocol = "tcp", port = 8302 }
    "serf-wan-u" = { protocol = "udp", port = 8302 }
    "client-rpc" = { protocol = "tcp", port = 8400 }
    "http-api"   = { protocol = "tcp", port = 8500 }
    "dns-api-t"  = { protocol = "tcp", port = 8600 }
    "dns-api-u"  = { protocol = "udp", port = 8600 }
  }
}

resource "openstack_networking_secgroup_rule_v2" "consul_rules" {
  for_each          = local.consul_ports
  direction         = "ingress"
  description       = "Allow Consul Port"
  ethertype         = "IPv4"
  protocol          = each.value.protocol
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = var.intranet_cidr
  security_group_id = openstack_networking_secgroup_v2.consul_sg.id
}
