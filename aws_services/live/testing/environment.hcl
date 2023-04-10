//# ---------------------------------------------------------------------------------------------------------------------
//# ENVIRONMENT PARAMETERS
//# These variables apply to all configurations in this subfolder. These are automatically merged into the child
//# `terragrunt.hcl` config via the include block.
//# ---------------------------------------------------------------------------------------------------------------------

locals {
  environment_name        = "testing"
  short_environment_name  = "tst"
  account_id              = "255686512659"
  bucket_remote_tfstate   = "terragrunt-remote-state-${local.account_id}"
  dynamodb_remote_tfstate = "terragrunt-state-lock-dynamo-${local.account_id}"
  aws_profile             = "my-account"
  region_bucket           = "us-east-2"
  dns_zone_id             = "CHANGE_HERE"
  dns_domain_name         = "CHANGE_HERE"

  default_tags = {
    environment = local.environment_name,
    terraform   = "true",
    scost       = "my-product",
    monitoring  = "true",
  }
}
