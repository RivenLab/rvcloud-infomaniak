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

variable "ubuntu_password_hash" {
  description = "Hashed password for Ubuntu user"
  type        = string
  sensitive   = true
}

# Network Configuration
variable "external_network_name" {
  description = "The name of the external network for floating IPs"
  type        = string
}

variable "internet_cidr" {
  description = "CIDR block for the Internet subnet"
  type        = string
}

variable "intranet_cidr" {
  description = "CIDR block for the Intranet subnet"
  type        = string
}

# OPNsense Configuration
variable "opnsense_internet_ip" {
  description = "Static IP on the Internet network for OPNsense WAN"
  type        = string
}

variable "opnsense_intranet_ip" {
  description = "Static IP on the Intranet network for OPNsense LAN"
  type        = string
}

variable "opnsense_flavor" {
  description = "Flavor to use for the OPNsense VPN gateway"
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
