# Linux Image
data "openstack_images_image_v2" "linux_image" {
  name_regex  = var.linux_image_regex
  most_recent = true
  visibility  = "public"
}

# SSH Key Pair
resource "openstack_compute_keypair_v2" "linux_rsa_keypair" {
  name       = "linux-keypair"
  public_key = var.ssh_public_key
}

# Fetch flavors for the VMs mapped directly from the variables map
data "openstack_compute_flavor_v2" "linux_flavors" {
  for_each = var.linux_vms
  name     = each.value.flavor
}

# ---------------------------------------------------------------------------- #
#                      Dynamic Network Ports for Linux VMs                     #
# ---------------------------------------------------------------------------- #

resource "openstack_networking_port_v2" "linux_ports" {
  for_each              = var.linux_vms
  name                  = "${each.key}-intranet-port"
  network_id            = openstack_networking_network_v2.intranet_net.id
  admin_state_up        = true
  port_security_enabled = true
  security_group_ids    = [openstack_networking_secgroup_v2.linux_sg.id]

  # Dynamic Block to handle static IPs if specified, else OpenStack defaults to DHCP.
  dynamic "fixed_ip" {
    for_each = each.value.static_ip != null ? [each.value.static_ip] : []
    content {
      subnet_id  = openstack_networking_subnet_v2.intranet_subnet.id
      ip_address = fixed_ip.value
    }
  }

  # Fallback for DHCP when static_ip is null
  dynamic "fixed_ip" {
    for_each = each.value.static_ip == null ? [1] : []
    content {
      subnet_id = openstack_networking_subnet_v2.intranet_subnet.id
    }
  }
}

# ---------------------------------------------------------------------------- #
#                              Linux VMs Instances                             #
# ---------------------------------------------------------------------------- #

resource "openstack_compute_instance_v2" "linux_vms" {
  for_each          = var.linux_vms
  name              = each.key
  flavor_id         = data.openstack_compute_flavor_v2.linux_flavors[each.key].id
  availability_zone = each.value.availability_zone
  key_pair          = openstack_compute_keypair_v2.linux_rsa_keypair.name

  block_device {
    uuid                  = data.openstack_images_image_v2.linux_image.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.linux_volume_size
    boot_index            = 0
    delete_on_termination = true
  }

  network {
    port = openstack_networking_port_v2.linux_ports[each.key].id
  }
}

# ---------------------------------------------------------------------------- #
#                                    Outputs                                   #
# ---------------------------------------------------------------------------- #

output "linux_vms_internal_ips" {
  description = "Assigned IPS of the backend Linux VMs"
  value = {
    for name, port in openstack_networking_port_v2.linux_ports :
    name => port.all_fixed_ips[0]
  }
}
