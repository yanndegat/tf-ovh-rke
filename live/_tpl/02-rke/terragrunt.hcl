include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../rke"
}

dependency "infra" {
  config_path = "../01-infra"
}

inputs = dependency.infra.outputs
