# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  environment_name = local.environment_vars.locals.environment_name
  customer_name    = local.customer_vars.locals.customer_name
  customer_tags    = local.customer_vars.locals.customer_tags
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # Added double slash terragrunt: https://ftclausen.github.io/dev/infra/terraform-solving-the-double-slash-mystery/
  source = "tfr:///terraform-aws-modules/kms/aws//?version=1.5.0"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  description = "General ${local.customer_name}-${local.environment_name} encryption key"
  aliases = ["alias/${local.customer_name}-${local.environment_name}"]

  tags = merge(
    local.customer_tags,
 )
}
