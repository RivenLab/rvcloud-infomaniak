variable "ssh_public_key" {
  description = "Standard SSH public key for instances"
  type        = string
  sensitive   = true
}

variable "password_rsa_key" {
  description = "Password retrieval key for instances"
  type        = string
  sensitive   = true
}

variable "linux_password_hash" {
  description = "Hashed password for Linux user"
  type        = string
  sensitive   = true
}

# Network Configuration
variable "external_network_name" {
  description = "The name of the external network for floating IPs"
  type        = string
}

variable "intranet_cidr" {
  description = "CIDR block for the Intranet subnet"
  type        = string
}

# Bastion Proxy Configuration
variable "bastion_proxy_flavor" {
  description = "Flavor to use for the Bastion Proxy VPN gateway"
  type        = string
}

# Standard Linux VMs Configuration
variable "linux_vms" {
  description = "Map of standard Linux VMs to provision"
  type = map(object({
    flavor            = string
    availability_zone = string
    static_ip         = optional(string) # Set to null to use DHCP for dynamic orchestration
  }))
}

variable "linux_image_regex" {
  description = "Regex to match the Linux image name"
  type        = string
}

variable "linux_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}

variable "bastion_volume_size" {
  description = "Size of the root volume in GB"
  type        = number
}

# WireGuard Configuration
variable "wg_server_address" {
  description = "Wireguard server address (e.g. 10.8.0.1/24)"
  type        = string
}

variable "wg_subnet_cidr" {
  description = "Wireguard subnet CIDR (e.g. 10.8.0.0/24)"
  type        = string
}

variable "wg_server_private_key" {
  description = "Wireguard server private key"
  type        = string
  sensitive   = true
}

variable "wg_server_public_key" {
  description = "Wireguard server public key"
  type        = string
}

variable "wg_client_public_key" {
  description = "Wireguard client public key"
  type        = string
}

variable "wg_client_allowed_ips" {
  description = "Wireguard client allowed IPs (e.g. 10.8.0.2/32)"
  type        = string
}

variable "wg_preshared_key" {
  description = "Wireguard preshared key"
  type        = string
  sensitive   = true
}
