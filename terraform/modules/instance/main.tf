data "openstack_images_image_v2" "image" {
  name_regex  = "^Ubuntu 24.04 LTS"
  most_recent = true
  visibility  = "public"
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.instance_flavor
}

resource "openstack_networking_port_v2" "port" {
  count                 = var.instance_count
  name                  = "${var.instance_name}-${count.index + 1}-port"
  network_id            = var.instance_network_internal
  admin_state_up        = true
  port_security_enabled = true
  security_group_ids    = var.instance_security_groups

  fixed_ip {
    subnet_id = var.instance_subnet_internal
  }
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = var.public_floating_ip ? var.instance_count : 0
  pool  = var.instance_network_external_name
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  count       = var.public_floating_ip ? var.instance_count : 0
  floating_ip = openstack_networking_floatingip_v2.fip[count.index].address
  port_id     = openstack_networking_port_v2.port[count.index].id
}

resource "openstack_compute_instance_v2" "instance" {
  count     = var.instance_count
  name      = "${var.instance_name}-${count.index + 1}"
  # image_id must NOT be set when using block_device with destination_type = "volume".
  # OpenStack reports it as "Attempt to boot from volume - no image supplied" on the
  # instance, which causes Terraform to detect drift on every subsequent plan.
  # The image reference lives exclusively inside the block_device block below.
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.instance_key_pair

  user_data = var.user_data != "" ? var.user_data : null
  metadata  = var.metadatas

  network {
    port = openstack_networking_port_v2.port[count.index].id
  }

  block_device {
    uuid                  = data.openstack_images_image_v2.image.id
    source_type           = "image"
    destination_type      = "volume"
    volume_size           = var.volume_size
    boot_index            = 0
    delete_on_termination = true
  }
}
