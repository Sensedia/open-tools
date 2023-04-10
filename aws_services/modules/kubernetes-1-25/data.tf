## Required for kubernetes, helm and kubectl providers where EKS cluster does not exist yet to avoid race condition.
## Known error see more in the WARNING block: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources

data "aws_eks_cluster" "this" {
  depends_on = [
    module.eks.eks_managed_node_groups,
  ]

  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  depends_on = [
    module.eks.eks_managed_node_groups,
  ]

  name = module.eks.cluster_name
}


################################################################################
# General
################################################################################
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
