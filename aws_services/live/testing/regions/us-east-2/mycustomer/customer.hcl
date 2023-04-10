
//# ---------------------------------------------------------------------------------------------------------------------
//# CUSTOMER PARAMETERS
//# Set common variables for the customer.
//# These variables apply to all configurations in this subfolder. These are automatically merged into the child
//# `terragrunt.hcl` config via the include block.
//# ---------------------------------------------------------------------------------------------------------------------

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  account_id       = local.environment_vars.locals.account_id
  default_tags     = local.environment_vars.locals.default_tags

  # To generate customer_id, execute:
  # cat /dev/urandom | tr -dc "a-z0-9" | fold -w  10 | head -n 1 | tr -d "\n"
  # Example: cdk17o7adl (mycustomer)
  customer_id   = "cdk17o7adl"
  customer_name = "mycustomer"

  customer_tags = merge(
    local.default_tags,
    {
      "customer_name" = local.customer_name,
      "customer_id"   = local.customer_id,
    }
  )

  #----------------------------
  # EKS Configurations
  #----------------------------
  suffix1             = "gyr4"
  cluster1_short_name = "cluster1"
  cluster1_name       = "${local.customer_id}-${local.cluster1_short_name}-${local.suffix1}"

  # IP Address that can access the Kubernetes cluster
  cluster_endpoint_public_access_cidrs = [
    "187.106.34.175/32",
  ]

  key_name           = "key-${local.suffix1}"
  public_key_content = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDi+Wel2qL9OR541sPZLXczj/wEzDjRblXgya/y40E1xYSQDGXkMikndWywKGB0uoV1P1oGXQqFGHKn0lewiwuNAKsg5vGqIJ8miVqfMQ+qpiAU2Byt0cAz14eb2adJmRAlo5hQpj+xTGvi4xnde8ud1v0FHLABNtNdTn7VpPpGmvpXff68kj6ebV9IrRQ1kVkD8hlZTEixYAGnVHQScjfsrId68H0uNFYghgzdKlWWbP21b4WKNWZNQZc4U7gQ405vRRHqXfM/YIcUuDskT+T1+r0aBYkrtvPbxQLy5CHV46YAeYOs0TushrjwaGl3PLNopFC3duBUMaHnaRN/5ikD"


  #----------------------------
  # VPC Configurations
  #----------------------------
  vpc_name = "net-${local.suffix1}"

  # http://jodies.de/ipcalc?host=172.31.240.0&mask1=20&mask2=22
  cidr = "172.31.240.0/20"

  public_subnets  = [
    "172.31.240.0/22",
    "172.31.244.0/22"
  ]

  private_subnets = [
    "172.31.248.0/22",
    "172.31.252.0/22"
  ]

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
  ]

  list_roles = [
    {
      rolearn  = "arn:aws:iam::${local.account_id}:role/Admins"
      username = "Admins"
      groups   = ["system:masters"]
    },
  ]

  list_users = [
    {
      userarn  = "arn:aws:iam::${local.account_id}:root"
      username = "root"
      groups   = ["system:masters"]
    },
  ]

  # Each resource can have a maximum of 50 user created tags.
  # Reference: https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html

  public_subnet_tags = {
    "type"                                         = "public",
    "kubernetes.io/role/elb"                       = "1",      # For use with ALB of type internet
    "kubernetes.io/cluster/${local.cluster1_name}" = "shared", # For use with node autoscaling
  }

  private_subnet_tags = {
    "type"                                          = "private",
    "kubernetes.io/role/internal-elb"               = "1",                 # For use with ALB of type internal
    "kubernetes.io/cluster/${local.cluster1_name}"  = "shared",            # For use with node autoscaling
    "karpenter.sh/discovery/${local.cluster1_name}" = local.cluster1_name, # For use with Karpenter
  }

}
