# ---------------------------------------------------------------------------- #
#                              Terraform Settings                              #
# ---------------------------------------------------------------------------- #

terraform {
  required_version = ">= 1.14.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # -------------------------------------------------------------------------- #
  #                             Remote State Backend                           #
  # -------------------------------------------------------------------------- #
  # For Enterprise environments, keeping tfstate securely stored remotely
  # enables state locking and prevents concurrent execution overlaps.
  # Remove the comments and update the values to use an S3 compliant backend.
  #
  backend "s3" {
    bucket                      = "terraform-states-bucket"
    key                         = "infomaniak-openstack-automation/terraform.tfstate"
    region                      = "us-east-1"
    endpoints                   = { s3 = "https://s3.swiss-backup04.infomaniak.com" }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}
