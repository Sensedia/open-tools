################################################################################
# Used in other *.tf files
################################################################################

locals {
  #--------------------------------------------
  # set kubeconfig variable
  #--------------------------------------------
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = "terraform"
    clusters = [{
      name = module.eks.cluster_name
      cluster = {
        certificate-authority-data = module.eks.cluster_certificate_authority_data
        server                     = module.eks.cluster_endpoint
      }
    }]
    contexts = [{
      name = "terraform"
      context = {
        cluster = module.eks.cluster_name
        user    = "terraform"
      }
    }]
    users = [{
      name = "terraform"
      user = {
        token = data.aws_eks_cluster_auth.this.token
      }
    }]
  })

  #--------------------------------------------
  # set partition variable
  #--------------------------------------------
  # Used to determine correct partition (i.e. - `aws`, `aws-gov`, `aws-cn`, etc.)
  partition = data.aws_partition.current.partition

  #--------------------------------------------
  # set tags variable
  #--------------------------------------------
  tags = merge(
    var.tags,
  )

  #--------------------------------------------
  # set case_result variable
  #--------------------------------------------
  # Trying to implement case conditional statement native of other programing languages
  # This code will test match with each value and will return just one result
  condition1  = var.type_worker_node_group == "KARPENTER" ? "KARPENTER" : ""
  condition2  = var.type_worker_node_group == "AWS_MANAGED_NODE" ? "AWS_MANAGED_NODE" : ""
  condition3  = var.type_worker_node_group == "SELF_MANAGED_NODE" ? "SELF_MANAGED_NODE" : ""
  case_result = coalesce(local.condition1, local.condition2, local.condition3)

  #--------------------------------------------
  # set node_iam_role_arns_non_windows variable
  #--------------------------------------------
  node_iam_role_arns_non_windows = distinct(
    compact(
      concat(
        [for group in module.eks.eks_managed_node_groups : group.iam_role_arn],
        [for group in module.eks.self_managed_node_groups : group.iam_role_arn if group.platform != "windows"],
        var.aws_auth_node_iam_role_arns_non_windows,
      )
    )
  )

  #--------------------------------------------
  # set fargate_profile_pod_execution_role_arns variable
  #--------------------------------------------
  fargate_profile_pod_execution_role_arns = distinct(
    compact(
      concat(
        [for group in module.eks.fargate_profiles : group.fargate_profile_pod_execution_role_arn],
        var.aws_auth_fargate_profile_pod_execution_role_arns,
      )
    )
  )

  #--------------------------------------------
  # set aws_auth_configmap_data variable
  #--------------------------------------------
  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      [for role_arn in local.node_iam_role_arns_non_windows : {
        rolearn  = role_arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
        }
      ],
      # Fargate profile
      [for role_arn in local.fargate_profile_pod_execution_role_arns : {
        rolearn  = role_arn
        username = "system:node:{{SessionName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
          "system:node-proxier",
        ]
        }
      ],
      var.aws_auth_roles
    ))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }

  #--------------------------------------------
  # set default_namespaces variable
  #--------------------------------------------
  namespace1         = local.case_result == "KARPENTER" ? ["karpenter"] : []
  namespace2         = var.install_traefik == true ? ["traefik"] : []
  default_namespaces = concat(["kube-system", "default", "kube-node-lease", "kube-public", "amazon-cloudwatch"], local.namespace1, local.namespace2, )
}
