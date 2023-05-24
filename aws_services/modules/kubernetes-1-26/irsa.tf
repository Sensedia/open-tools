################################################################################
# IRSA Roles
################################################################################
## For more examples how to use this module with listed roles below, see link https://github.com/terraform-aws-modules/terraform-aws-iam/tree/master/modules/iam-role-for-service-accounts-eks
## And for examples: https://github.com/terraform-aws-modules/terraform-aws-iam/blob/master/examples/iam-role-for-service-accounts-eks/main.tf
## module "cert_manager_irsa_role"
## module "ebs_csi_irsa_role"
## module "efs_csi_irsa_role"
## module "external_dns_irsa_role"
## module "external_secrets_irsa_role"
## module "fsx_lustre_csi_irsa_role"
## module "load_balancer_controller_targetgroup_binding_only_irsa_role"
## module "appmesh_controller_irsa_role"
## module "appmesh_envoy_proxy_irsa_role"
## module "amazon_managed_service_prometheus_irsa_role"
## module "node_termination_handler_irsa_role"
## module "velero_irsa_role"
## module "vpc_cni_ipv6_irsa_role"

module "fluentbit_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name = "fluentbit-${var.cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["amazon-cloudwatch:fluent-bit"]
    }
  }

  role_policy_arns = {
    fluentbit_eks_policy = aws_iam_policy.aws_for_fluentbit.arn
  }

  tags = local.tags
}

module "aws_ebs_csi_driver_irsa" {

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name             = "aws-ebs-csi-${var.cluster_name}"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}


module "aws_efs_csi_driver_irsa" {
  count = var.install_aws_efs_csi_driver ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name             = "aws-efs-csi-${var.cluster_name}"
  attach_efs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = local.tags
}


module "cluster_autoscaler_irsa_role" {
  count = local.case_result != "KARPENTER" ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                        = "cluster-autoscaler-${var.cluster_name}"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-cluster-autoscaler"]
    }
  }

  tags = local.tags
}

module "karpenter_irsa" {
  # See implementation of case_result variable in locals.tf file
  count = local.case_result == "KARPENTER" ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                          = "karpenter-controller-${var.cluster_name}"
  attach_karpenter_controller_policy = true

  karpenter_tag_key               = "karpenter.sh/discovery/${var.cluster_name}"
  karpenter_controller_cluster_id = module.eks.cluster_name
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["initial"].iam_role_arn,
  ]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }

  tags = local.tags
}

module "load_balancer_controller_irsa_role" {
  count = var.install_aws_loadbalancer_controller ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                              = "load-balancer-controller-${var.cluster_name}"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.tags
}

module "node_termination_handler_irsa_role" {
  # See implementation of case_result variable in locals.tf file
  count = local.case_result == "SELF_MANAGED_NODE" ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name                              = "node-termination-handler-${var.cluster_name}"
  attach_node_termination_handler_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node-termination-handler"]
    }
  }

  tags = local.tags
}

module "vpc_cni_ipv4_irsa_role" {
  count = var.install_aws_vpc_cni_without_vpn || var.install_aws_vpc_cni_with_vpn ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name             = "vpc-cni-ipv4-${var.cluster_name}"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "velero_irsa_role" {
  count = var.install_velero || var.velero_irsa ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.3"

  role_name = "velero-${var.cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["velero:velero"]
    }
  }

  role_policy_arns = { velero = module.velero_irsa_policy[0].arn }

  tags = local.tags
}
