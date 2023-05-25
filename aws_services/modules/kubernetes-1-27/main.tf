################################################################################
# EKS Cluster
################################################################################
module "eks" {
  # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.15"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  create_kms_key                         = var.create_kms_key
  cluster_encryption_config              = var.cluster_encryption_config
  cluster_enabled_log_types              = var.cluster_enabled_log_types
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_endpoint_public_access          = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs    = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access         = var.cluster_endpoint_private_access
  cluster_additional_security_group_ids   = var.cluster_additional_security_group_ids
  cluster_security_group_additional_rules = merge(
    {
      ingress_vpc_cidr_block_all = {
        description = "CIDR of the VPC to cluster API all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks = var.vpc_cidr_block
      }
    },
    var.cluster_security_group_additional_rules
  )

  # Required for Karpenter role below
  enable_irsa = true

  node_security_group_enable_recommended_rules = var.node_security_group_enable_recommended_rules
  node_security_group_additional_rules         = merge(
    {
      ingress_vpc_cidr_block_all = {
        description = "CIDR of the VPC to node all ports/protocols"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        type        = "ingress"
        cidr_blocks = var.vpc_cidr_block
      }
      ### This rules are deprecated because of new variable 'node_security_group_enable_recommended_rules'
      # ingress_self_all = {
      #   description = "Node to node all ports/protocols"
      #   protocol    = "-1"
      #   from_port   = 0
      #   to_port     = 0
      #   type        = "ingress"
      #   self        = true
      # }
      # egress_all = {
      #   description      = "Node all egress"
      #   protocol         = "-1"
      #   from_port        = 0
      #   to_port          = 0
      #   type             = "egress"
      #   cidr_blocks      = ["0.0.0.0/0"]
      #   ipv6_cidr_blocks = ["::/0"]
      # }
    },
    var.node_security_group_additional_rules
  )

  ## Created aws-auth.tf to substitute this.
  ## Workaround to avoid intermittent and unpredictable errors which are hard to debug and diagnose with kubernetes, helm, kubectl providers.
  ## Known error see more in the WARNING block: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-manage
  # manage_aws_auth_configmap = true
  # aws_auth_roles            = var.aws_auth_roles
  # aws_auth_users            = var.aws_auth_users


  # Trying to implement case conditional statement native of other programing languages
  # See implementation of case_result variable in locals.tf file
  node_security_group_tags = merge(
    local.case_result == "KARPENTER" ? (
      {
        # NOTE - if creating multiple security groups with this module, only tag the
        # security group that Karpenter should utilize with the following tag
        # (i.e. - at most, only one security group should have this tag in your account)
        "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name
      }
    ) : {},
    var.node_security_group_tags
  )

  eks_managed_node_group_defaults = merge(
    {
      enable_monitoring  = false
      capacity_rebalance = true
      iam_role_additional_policies = {
        "AmazonSSMManagedInstanceCore" = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
      }
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }
    },
    var.eks_managed_node_group_defaults
  )

  fargate_profiles = var.coredns_fargate ? (
    {
      kube_system = {
        name = "kube-system"
        selectors = [
          {
            namespace = "kube-system"
            labels = {
              k8s-app = "coredns"
            }
          }
        ]
      }
    }
    ) : (
    {}
  )

  # Trying to implement case conditional statement native of other programing languages
  # See implementation of case_result variable in locals.tf file
  eks_managed_node_groups = merge(
    local.case_result == "KARPENTER" ? (
      {
        initial = {
          capacity_type     = "ON_DEMAND"
          ami_type          = var.mng_ami_type
          instance_types    = var.mng_ami_type == "AL2_ARM_64" || var.mng_ami_type == "BOTTLEROCKET_ARM_64" ? ["t4g.medium", "c7g.large"] : ["m6i.medium", "m6a.medium", "m5.medium", "m5a.medium"]
          enable_monitoring = false
          # Not required nor used - avoid tagging two security groups with same tag as well
          create_security_group = false

          # Only to create Karpenter nodes resources.
          min_size     = 2
          max_size     = 3
          desired_size = 3

          iam_role_attach_cni_policy   = true
          iam_role_additional_policies = {
            # Required by Karpenter
            "AmazonSSMManagedInstanceCore" = "arn:${local.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
            "CloudWatchAgentServerPolicy"  = "arn:${local.partition}:iam::aws:policy/CloudWatchAgentServerPolicy",
          }

          tags = {
            # This will tag the launch template created for use by Karpenter
            "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name,
            # NTH to monitoring Spot Instance Termination Notifications (ITN) in Karpenter Spot Nodes
            "aws-node-termination-handler/managed" = "true",
          }
        }
      }
    ) : {},

    local.case_result == "AWS_MANAGED_NODE" ? (
      var.eks_managed_node_groups
    ) : {},
  )


  # Trying to implement case conditional statement native of other programing languages
  # See implementation of case_result variable in locals.tf file
  self_managed_node_groups = merge(
    local.case_result == "SELF_MANAGED_NODE" ? (
      var.self_managed_node_groups
    ) : {},
  )

  # Trying to implement case conditional statement native of other programing languages
  # See implementation of case_result variable in locals.tf file
  self_managed_node_group_defaults = merge(
    local.case_result == "SELF_MANAGED_NODE" ? (
      merge(
        var.self_managed_node_group_defaults,
        {
          mixed_instances_policy = {
            instances_distribution = {
              spot_allocation_strategy = "price-capacity-optimized"
            }
          }
        }
      )
    ) : {},
  )

  tags = local.tags
}
