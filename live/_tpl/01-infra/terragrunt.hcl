locals {
  allowed_prefixes = [
    # fillin your IPs
  ]
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../infra"
}

inputs = {
  name            = "myname"
  region_name     = "GRA7"
  image_name      = "My 20.04"
  zone            = {
    root      = "my.ovh.zone"
    subdomain = "asubdomain"
  }

  # Allow workstations
  allowed_ingress_prefixes = local.allowed_prefixes
  allowed_mgmt_prefixes    = local.allowed_prefixes

  masters_nb = 1
  workers_nb = 2
}
