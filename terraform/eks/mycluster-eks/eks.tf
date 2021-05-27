# EKS cluster
# https://github.com/terraform-aws-modules/terraform-aws-eks
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/faq.md

module "eks-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "v14.0.0"

  cluster_name                          = var.cluster_name
  cluster_version                       = var.cluster_version
  cluster_enabled_log_types             = var.cluster_enabled_log_types
  cluster_log_retention_in_days         = var.cluster_log_retention_in_days
  subnets                               = var.subnets
  vpc_id                                = var.vpc_id
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_endpoint_private_access_cidrs = var.cluster_endpoint_private_access_cidrs
  write_kubeconfig                      = false
  workers_additional_policies           = var.workers_additional_policies
  worker_additional_security_group_ids  = var.worker_additional_security_group_ids
  map_roles                             = var.map_roles
  map_users                             = var.map_users

  worker_groups_launch_template = [
    {
      name                                     = var.lt_name
      override_instance_types                  = var.override_instance_types
      on_demand_percentage_above_base_capacity = var.on_demand_percentage_above_base_capacity
      asg_min_size                             = var.asg_min_size
      asg_max_size                             = var.asg_max_size
      asg_desired_capacity                     = var.asg_desired_capacity
      autoscaling_enabled                      = var.autoscaling_enabled
      kubelet_extra_args                       = var.kubelet_extra_args
      public_ip                                = var.public_ip
      suspended_processes                      = var.suspended_processes
      root_volume_size                         = var.root_volume_size
      key_name                                 = var.aws_key_name
    },
  ]

  kubeconfig_aws_authenticator_command         = "aws"
  kubeconfig_aws_authenticator_command_args    = ["eks", "update-kubeconfig"]
  kubeconfig_aws_authenticator_additional_args = ["--name", var.cluster_name, "--alias", var.cluster_name]
  kubeconfig_aws_authenticator_env_variables   = {
    AWS_PROFILE        = var.profile
    AWS_DEFAULT_REGION = var.region
  }

  tags = merge(
    {
      Terraform = "true"
    },
    var.tags,
  )
}
