################################################################################
# aws-vpc-cni (daemonset aws-node)
################################################################################
resource "time_sleep" "aws_vpc_cni" {
  count = var.install_aws_vpc_cni_without_vpn || var.install_aws_vpc_cni_with_vpn ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.aws_vpc_cni_time_wait
}

resource "null_resource" "modify_vpc_cni" {
  count = var.install_aws_vpc_cni_without_vpn || var.install_aws_vpc_cni_with_vpn ? 1 : 0

  depends_on = [
    helm_release.coredns,
    module.vpc_cni_ipv4_irsa_role[0],
    time_sleep.aws_vpc_cni[0]
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    # We are maintaing the existing aws-node resources and annotating it for Helm to assume control
    command = <<-EOT
      #!/usr/bin/env bash

      set -euo pipefail

      # don't import the crd. Helm can't manage the lifecycle of it anyway.
      for kind in daemonSet clusterRole clusterRoleBinding serviceAccount; do
        echo "[INFO] Setting annotations and labels on $kind/aws-node"
        kubectl -n kube-system annotate --overwrite $kind aws-node meta.helm.sh/release-name=aws-vpc-cni      --kubeconfig <(echo $KUBECONFIG | base64 --decode)
        kubectl -n kube-system annotate --overwrite $kind aws-node meta.helm.sh/release-namespace=kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
        kubectl -n kube-system label    --overwrite $kind aws-node app.kubernetes.io/managed-by=Helm          --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      done
    EOT
  }
}

# Reference: https://artifacthub.io/packages/helm/aws/aws-vpc-cni
resource "helm_release" "aws_vpc_cni_without_vpn" {
  count = var.install_aws_vpc_cni_without_vpn ? 1 : 0

  depends_on = [
    null_resource.modify_vpc_cni[0]
  ]

  namespace        = "kube-system"
  create_namespace = false

  name       = "aws-vpc-cni"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-vpc-cni"
  version    = "1.2.8" # Install version 1.12.6 of amazon-vpc-cni-k8s. See new changes on release notes of application: https://github.com/aws/amazon-vpc-cni-k8s/releases

  values = [
    <<-YAML
    originalMatchLabels: true
    crd:
      create: false

    # Reference: https://github.com/aws/amazon-vpc-cni-k8s#cni-configuration-variables
    env:
      MINIMUM_IP_TARGET: "${var.aws_vpc_cni_minimum_ip}"
      WARM_IP_TARGET: "${var.aws_vpc_cni_warm_ip}"
      AWS_VPC_K8S_CNI_EXTERNALSNAT: "false"
      AWS_VPC_ENI_MTU: "9001"
      ENABLE_IPv4: "true"

    serviceAccount:
      name: aws-node
      annotations:
        eks.amazonaws.com/role-arn: ${module.vpc_cni_ipv4_irsa_role[0].iam_role_arn}

    YAML
  ]
}


# Reference: https://artifacthub.io/packages/helm/aws/aws-vpc-cni
resource "helm_release" "aws_vpc_cni_with_vpn" {
  count = var.install_aws_vpc_cni_with_vpn ? 1 : 0

  depends_on = [
    null_resource.modify_vpc_cni[0]
  ]

  namespace        = "kube-system"
  create_namespace = false

  name       = "aws-vpc-cni"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-vpc-cni"
  version    = "1.2.8" # Install version 1.12.6 of amazon-vpc-cni-k8s. See new changes on release notes of application: https://github.com/aws/amazon-vpc-cni-k8s/releases

  values = [
    <<-YAML
    originalMatchLabels: true
    crd:
      create: false

    # Reference: https://github.com/aws/amazon-vpc-cni-k8s#cni-configuration-variables
    env:
      MINIMUM_IP_TARGET: "10"
      WARM_IP_TARGET: "2"
      AWS_VPC_K8S_CNI_EXTERNALSNAT: "true"
      AWS_VPC_ENI_MTU: "1498"
      ENABLE_IPv4: "true"

    serviceAccount:
      name: aws-node
      annotations:
        eks.amazonaws.com/role-arn: ${module.vpc_cni_ipv4_irsa_role[0].iam_role_arn}

    YAML
  ]
}
