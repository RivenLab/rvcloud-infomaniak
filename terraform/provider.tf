# ---------------------------------------------------------------------------- #
#                              Terraform Settings                              #
# ---------------------------------------------------------------------------- #

terraform {
  required_version = ">= 1.10.0"

  # -------------------------------------------------------------------------- #
  #                             Remote State Backend                           #
  # -------------------------------------------------------------------------- #
  cloud {
    organization = "rvlab"
    workspaces {
      name = "rvcloud-infomaniak"
    }
  }

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4.0"
    }
  }
}
