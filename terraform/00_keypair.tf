resource "openstack_compute_keypair_v2" "default_key" {
  name       = "default_key"
  public_key = var.ssh_public_key
}
