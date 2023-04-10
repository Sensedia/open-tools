################################################################################
# AWS Load Balancer Controller
################################################################################

resource "time_sleep" "aws_load_balancer_controller" {
  count = var.install_aws_loadbalancer_controller ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.aws_loadbalancer_controller_time_wait
}

# Reference: https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
resource "helm_release" "aws_load_balancer_controller" {
  count = var.install_aws_loadbalancer_controller ? 1 : 0

  depends_on = [
    kubectl_manifest.karpenter_provisioner[0],
    time_sleep.aws_load_balancer_controller[0]
  ]

  namespace        = "kube-system"
  create_namespace = true

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.8" # Install version v2.4.7 of aws-load-balancer-controller. See new changes on release notes of application: https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases

  values = [
    <<-YAML
    clusterName: ${var.cluster_name}
    region: ${var.region}
    vpcId: ${var.vpc_id}
    
    serviceAccount:
      name: aws-load-balancer-controller
      annotations:
        eks.amazonaws.com/role-arn: ${module.load_balancer_controller_irsa_role[0].iam_role_arn}

    ingressClass: alb
    ingressClassParams:
      name: alb

    resources:
      limits:
        cpu: 100m
        memory: 128Mi
      requests:
        cpu: 100m
        memory: 128Mi

    affinity:
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchLabels:
              app.kubernetes.io/name: aws-load-balancer-controller
          namespaces:
          - kube-system
          topologyKey: kubernetes.io/hostname
    YAML
  ]
}
