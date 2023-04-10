
//# ---------------------------------------------------------------------------------------------------------------------
//# REGION PARAMETERS
//# Set common variables for the region.
//# These variables apply to all configurations in this subfolder. These are automatically merged into the child
//# `terragrunt.hcl` config via the include block.
//# ---------------------------------------------------------------------------------------------------------------------

locals {
  region = "us-east-2"

  #----------------------------
  # VPC Configurations
  #----------------------------

  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
  # https://aws.amazon.com/premiumsupport/knowledge-center/vpc-map-cross-account-availability-zones/
  # AZ-IDs are assigned automatically by AWS when creating an account
  # and to find them you can use the command below.
  #
  # Command:
  # aws ec2 describe-availability-zones --region REGION --profile PROFILE
  #
  # In case of a new account without resources provisioned in the VPC, you can open a ticket in AWS 
  # to change the AZ-ID mapping and have different accounts with the same mapping.
  # In the future this facilitates the use of private-link cross accounts.
  az_id_list = [
    "use2-az1",
    "use2-az2"
  ]

  az_name_list = [
    "${local.region}a",
    "${local.region}b"
  ]

}
