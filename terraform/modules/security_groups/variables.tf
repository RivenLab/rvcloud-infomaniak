variable "intranet_cidr" {
  description = "CIDR block for the Intranet subnet"
  type        = string
}

variable "wg_subnet_cidr" {
  description = "Wireguard subnet CIDR (e.g. 10.8.0.0/24)"
  type        = string
}
