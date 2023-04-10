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
  source = "tfr:///terraform-aws-modules/route53/aws//modules/records//?version=2.10.2"
}

dependency "certificate" {
  config_path = "../wildcard-mydomain-com/"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  create              = true
  zone_id             = local.dns_zone_id
  zone_name           = local.dns_domain_name
  records_jsonencoded = jsonencode([
    {
      name    = dependency.certificate.outputs.validation_domains.0.resource_record_name
      type    = "CNAME"
      ttl     = 60
      records = [
        dependency.certificate.outputs.validation_domains.0.resource_record_value
      ]
    }
  ])
}
