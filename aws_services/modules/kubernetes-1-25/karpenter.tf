################################################################################
# karpenter
# More info: https://karpenter.sh/v0.27.1/
################################################################################

# See implementation of case_result variable in locals.tf file
resource "time_sleep" "karpenter" {
  count = local.case_result == "KARPENTER" ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.karpenter_time_wait
}

# See implementation of case_result variable in locals.tf file
resource "aws_iam_instance_profile" "karpenter_instance_profile" {
  count = local.case_result == "KARPENTER" ? 1 : 0

  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.eks.eks_managed_node_groups["initial"].iam_role_name

  tags = local.tags
}

# Reference: https://gallery.ecr.aws/karpenter/karpenter

# See implementation of case_result variable in locals.tf file
resource "helm_release" "karpenter" {
  count = local.case_result == "KARPENTER" ? 1 : 0

  depends_on = [
    helm_release.coredns,
    time_sleep.karpenter[0]
  ]

  namespace        = "karpenter"
  create_namespace = true

  name              = "karpenter"
  repository        = "oci://public.ecr.aws/karpenter"
  chart             = "karpenter"
  version           = "v0.27.1" # Install version 0.27.1 of karpenter. See new changes on release notes of application: https://github.com/aws/karpenter/releases
  dependency_update = true

  values = [
    <<-YAML
    settings:
      aws:
        clusterName: ${var.cluster_name}
        clusterEndpoint: ${module.eks.cluster_endpoint}
        defaultInstanceProfile: ${aws_iam_instance_profile.karpenter_instance_profile[0].name}

    serviceAccount:
      name: karpenter
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter_irsa[0].iam_role_arn}
    YAML
  ]
}

# See implementation of case_result variable in locals.tf file
resource "kubectl_manifest" "karpenter_provisioner" {
  count = local.case_result == "KARPENTER" ? 1 : 0

  depends_on = [
    helm_release.karpenter[0]
  ]

  yaml_body = <<-YAML
  apiVersion: karpenter.sh/v1alpha5
  kind: Provisioner
  metadata:
    name: default  
  spec:
    # Enables consolidation which attempts to reduce cluster cost by both removing un-needed nodes and down-sizing those
    # that can't be removed.  Mutually exclusive with the ttlSecondsAfterEmpty parameter.
    consolidation:
      enabled: true
    # ttlSecondsUntilExpired: 86400
    # ttlSecondsAfterEmpty: 600
    labels:
      karpenter: "true"
    requirements:
      - key: karpenter.sh/capacity-type
        operator: In
        values:
          - spot
      # - key: karpenter.k8s.aws/instance-size
      #   operator: In
      #   values:
      #     - nano
      #     - micro
      #     - small
      #     - medium
      #     - large
      - key: kubernetes.io/arch
        operator: In
        values:
          - amd64

    limits:
      resources:
        cpu: ${var.karpenter_cpu_limit}
        memory: ${var.karpenter_memory_limit}
    provider:
      amiFamily: ${var.karpenter_amifamily}
      subnetSelector:
        karpenter.sh/discovery/${var.cluster_name}: ${var.cluster_name}
      securityGroupSelector:
        karpenter.sh/discovery/${var.cluster_name}: ${var.cluster_name}
      tags:
        karpenter.sh/discovery/${var.cluster_name}: ${var.cluster_name}
  YAML
}
