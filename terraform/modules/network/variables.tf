variable "external_network_name" {
  description = "The name of the external network for floating IPs"
  type        = string
}

variable "intranet_cidr" {
  description = "CIDR block for the Intranet subnet"
  type        = string
}
