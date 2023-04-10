# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  dns_zone_id      = local.environment_vars.locals.dns_zone_id
  dns_domain_name  = local.environment_vars.locals.dns_domain_name
  customer_tags    = local.customer_vars.locals.customer_tags
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # Added double slash terragrunt: https://ftclausen.github.io/dev/infra/terraform-solving-the-double-slash-mystery/
  source = "tfr:///terraform-aws-modules/acm/aws//?version=4.3.2"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  # General
  create_certificate        = true
  create_route53_records    = false
  dns_ttl                   = 60
  validate_certificate      = false
  validation_method         = "DNS"
  domain_name               = local.dns_domain_name
  zone_id                   = local.dns_zone_id
  subject_alternative_names = [
    "*.${local.dns_domain_name}"
  ]

  wait_for_validation = false

  tags = merge(
    local.customer_tags,
  )
}
