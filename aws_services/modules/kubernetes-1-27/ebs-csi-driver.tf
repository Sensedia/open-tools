################################################################################
# EKS Addons
################################################################################

# Fixed issue about installation of addon during cluster creation
# References: https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1801
#             https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon
resource "time_sleep" "aws_ebs_csi_driver" {
  depends_on = [
    module.eks
  ]

  create_duration = var.aws_ebs_csi_driver_time_wait
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  depends_on = [
    time_sleep.aws_ebs_csi_driver
  ]

  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = module.aws_ebs_csi_driver_irsa.iam_role_arn
}
