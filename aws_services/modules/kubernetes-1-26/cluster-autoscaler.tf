################################################################################
# cluster autoscaler
################################################################################
resource "time_sleep" "cluster_autoscaler" {
  count = local.case_result != "KARPENTER" ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.cluster_autoscaler_time_wait
}

# Reference: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler
resource "helm_release" "cluster_autoscaler" {
  count = local.case_result != "KARPENTER" ? 1 : 0

  depends_on = [
    time_sleep.cluster_autoscaler[0],
  ]

  namespace        = "kube-system"
  create_namespace = false

  name              = "cluster-autoscaler"
  repository        = "https://kubernetes.github.io/autoscaler"
  chart             = "cluster-autoscaler"
  version           = "9.29.0" # Installed latest version of cluster-autoscaler chart, but 'image.tag' was customized. See new changes on release notes of application: https://github.com/kubernetes/autoscaler/releases
  dependency_update = true

  values = [
    <<-YAML
    replicaCount: 2

    image:
      tag: v1.26.2

    priorityClassName: "system-cluster-critical"

    autoDiscovery:
      clusterName: ${var.cluster_name}
      tags:
        - "k8s.io/cluster-autoscaler/enabled"
        - "k8s.io/cluster-autoscaler/${var.cluster_name}"

    rbac:
      create: true
      serviceAccount:
        name: "aws-cluster-autoscaler"
        annotations:
          eks.amazonaws.com/role-arn: ${module.cluster_autoscaler_irsa_role[0].iam_role_arn}

    cloudProvider: aws

    awsRegion: ${var.region}

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: aws-cluster-autoscaler
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}
