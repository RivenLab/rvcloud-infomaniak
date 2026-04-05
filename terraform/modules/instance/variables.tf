variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_name" {
  type = string
}

variable "instance_flavor" {
  type    = string
  default = "a1-ram2-disk0"
}

variable "instance_key_pair" {
  type = string
}

variable "instance_security_groups" {
  type = list(string)
}

variable "instance_network_internal" {
  type = string
}

variable "instance_subnet_internal" {
  type = string
}

variable "public_floating_ip" {
  type    = bool
  default = false
}

variable "instance_network_external_name" {
  type    = string
  default = ""
}

variable "metadatas" {
  type    = map(string)
  default = {}
}

variable "user_data" {
  type    = string
  default = ""
}

variable "volume_size" {
  type    = number
  default = 20
}
