# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

locals {
  region_vars   = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  az_name_list  = local.region_vars.locals.az_name_list
  customer_id   = local.customer_vars.locals.customer_id
  customer_tags = local.customer_vars.locals.customer_tags
  suffix        = local.customer_vars.locals.suffix1
  instance_name = "${local.customer_id}-apps"
}

# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  # Added double slash terragrunt: https://ftclausen.github.io/dev/infra/terraform-solving-the-double-slash-mystery/
  source = "tfr:///terraform-aws-modules/ec2-instance/aws//?version=4.3.0"
}

dependencies {
  paths = [
    "../../vpc/net-${local.suffix}/",
    "../../keypair/key-${local.suffix}",
  ]
}

dependency "vpc" {
  config_path = "../../vpc/net-${local.suffix}/"
}

dependency "keypair" {
  config_path = "../../keypair/key-${local.suffix}/"
}


# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  name          = local.instance_name
  create        = true
  ami           = "ami-0a695f0d95cefc163" # Ubuntu 22.04 64 bits HVM SSD. Reference: https://aws.amazon.com/marketplace/b/c3bc6a75-0c3a-46ce-8fdd-498b6fd88577
  instance_type = "t2.medium"             # Reference: https://aws.amazon.com/ec2/instance-types/

  availability_zone      = local.az_name_list[0]
  subnet_id              = dependency.vpc.outputs.public_subnets[0]
  vpc_security_group_ids = [
    dependency.vpc.outputs.default_security_group_id
  ]

  associate_public_ip_address = true
  monitoring                  = false
  disable_api_stop            = false
  key_name                    = dependency.keypair.outputs.key_pair_name
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies           = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  # only one of these can be enabled at a time
  hibernation = true
  # enclave_options_enabled = true

  user_data_base64            = base64encode(file("${get_terragrunt_dir()}/configurations/userdata.tpl"))
  user_data_replace_on_change = true

  enable_volume_tags = false
  root_block_device  = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "${local.instance_name}-root-ebs"
      }
    },
  ]

  tags = merge(
    local.customer_tags,
  )
}
