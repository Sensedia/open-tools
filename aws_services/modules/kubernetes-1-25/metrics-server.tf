################################################################################
# metrics-server
################################################################################
resource "time_sleep" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.metrics_server_time_wait
}

# Reference: https://artifacthub.io/packages/helm/metrics-server/metrics-server
resource "helm_release" "metrics_server" {
  count = var.install_metrics_server ? 1 : 0

  depends_on = [
    kubectl_manifest.karpenter_provisioner[0],
    time_sleep.metrics_server[0],
  ]

  namespace        = "kube-system"
  create_namespace = true

  name              = "metrics-server"
  repository        = "https://kubernetes-sigs.github.io/metrics-server"
  chart             = "metrics-server"
  version           = "3.9.0" # Install version 0.6.3 of metrics-server. See new changes on release notes of application: https://github.com/kubernetes-sigs/metrics-server/releases
  dependency_update = true

  values = [
    <<-YAML
    replicas: 2

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: 1

    podDisruptionBudget:
      enabled: true
      minAvailable: 1

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: metrics-server
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}
