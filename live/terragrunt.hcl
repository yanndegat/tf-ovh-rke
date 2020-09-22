remote_state {
  backend = "swift"
  config = {
    cloud       = "tfstate"
    region_name = "GRA"
    container   = "trainingk8s"
    archive_container = "archive-trainingk8s"
    state_name        = "${path_relative_to_include()}/tfstate.tf"
  }
}

terragrunt_version_constraint = ">= 0.23"
terraform_version_constraint  = ">= 0.13"
terraform_binary = "/usr/local/bin/terraform013"
