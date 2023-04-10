# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  customer_vars      = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  key_name           = local.customer_vars.locals.key_name
  public_key_content = local.customer_vars.locals.public_key_content
  customer_tags      = local.customer_vars.locals.customer_tags
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # Added double slash terragrunt: https://ftclausen.github.io/dev/infra/terraform-solving-the-double-slash-mystery/
  source = "tfr:///terraform-aws-modules/key-pair/aws//?version=2.0.2"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  create_key_pair = true
  key_name        = local.key_name
  public_key      = local.public_key_content

  tags = merge(
    local.customer_tags,
  )
}
