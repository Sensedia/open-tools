# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  region_vars         = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars       = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  az_id_list          = local.region_vars.locals.az_id_list
  customer_tags       = local.customer_vars.locals.customer_tags
  cidr                = local.customer_vars.locals.cidr
  public_subnets      = local.customer_vars.locals.public_subnets
  private_subnets     = local.customer_vars.locals.private_subnets
  public_subnet_tags  = local.customer_vars.locals.public_subnet_tags
  private_subnet_tags = local.customer_vars.locals.private_subnet_tags
  vpc_name            = local.customer_vars.locals.vpc_name
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # Added double slash terragrunt: https://ftclausen.github.io/dev/infra/terraform-solving-the-double-slash-mystery/
  source = "tfr:///terraform-aws-modules/vpc/aws//?version=4.0.1"
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  name            = local.vpc_name
  create_vpc      = true
  cidr            = local.cidr
  azs             = local.az_id_list
  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_vpn_gateway   = false
  enable_ipv6          = false

  enable_s3_endpoint        = true
  enable_public_s3_endpoint = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  public_subnet_tags     = local.public_subnet_tags
  private_subnet_tags    = local.private_subnet_tags

  vpc_tags = local.customer_tags

  vpc_endpoint_tags = merge(
    local.customer_tags,
    {
      Name = local.vpc_name
    }
  )

  tags = merge(
    local.customer_tags,
  )
}
