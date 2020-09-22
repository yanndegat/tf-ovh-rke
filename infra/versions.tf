terraform {
  required_version = ">= 0.13"
  required_providers {
    openstack = {
      source  = "terraform-providers/openstack"
      version = "1.29.0"
    }
    ovh = {
      source  = "ovh/ovh"
      version = "~> 0.9"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "2.2.0"
    }
  }
}
