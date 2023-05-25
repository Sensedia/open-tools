################################################################################
# EFS CSI Driver
################################################################################
resource "time_sleep" "aws_efs_csi_driver" {
  count = var.install_aws_efs_csi_driver ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.aws_efs_csi_driver_time_wait
}

# References: https://github.com/kubernetes-sigs/aws-efs-csi-driver
#             https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
resource "helm_release" "aws_efs_csi_driver" {
  count = var.install_aws_efs_csi_driver ? 1 : 0

  depends_on = [
    kubectl_manifest.karpenter_provisioner[0],
    time_sleep.aws_efs_csi_driver[0],
  ]

  namespace        = "kube-system"
  create_namespace = true

  name              = "aws-efs-csi-driver"
  repository        = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart             = "aws-efs-csi-driver"
  version           = "2.4.3" # Install version 1.5.5 of aws efs-csi-driver. See new changes on release notes of application: https://github.com/kubernetes-sigs/aws-efs-csi-driver/releases
  dependency_update = true

  values = [
    <<-YAML
    controller:
      serviceAccount:
        create: true
        name: efs-csi-controller-sa
        annotations:
          eks.amazonaws.com/role-arn: ${module.aws_efs_csi_driver_irsa[0].iam_role_arn}

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: aws-efs-csi-driver
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}
