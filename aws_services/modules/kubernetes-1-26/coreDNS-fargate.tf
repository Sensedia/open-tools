################################################################################
# Modify EKS CoreDNS Deployment
################################################################################
resource "time_sleep" "coredns" {
  count = var.coredns_fargate ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.coredns_time_wait
}

# Separate resource so that this is only ever executed once
resource "null_resource" "remove_default_coredns_deployment" {
  count = var.coredns_fargate ? 1 : 0

  depends_on = [
    module.eks,
    time_sleep.coredns[0]
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    # We are removing the deployment provided by the EKS service and replacing it through the self-managed CoreDNS Helm addon
    # However, we are maintaing the existing kube-dns service and annotating it for Helm to assume control
    command = <<-EOT
      kubectl --namespace kube-system delete deployment coredns --wait=true --timeout=300s --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }
}

resource "null_resource" "modify_kube_dns" {
  count = var.coredns_fargate ? 1 : 0

  depends_on = [
    null_resource.remove_default_coredns_deployment
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    # We are maintaing the existing kube-dns service and annotating it for Helm to assume control
    command = <<-EOT
      echo "[INFO] Setting implicit dependency on ${module.eks.fargate_profiles["kube_system"].fargate_profile_pod_execution_role_arn}"
      kubectl --namespace kube-system annotate --overwrite service kube-dns meta.helm.sh/release-name=coredns          --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl --namespace kube-system annotate --overwrite service kube-dns meta.helm.sh/release-namespace=kube-system --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      kubectl --namespace kube-system label    --overwrite service kube-dns app.kubernetes.io/managed-by=Helm          --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }
}

data "aws_eks_addon_version" "this" {
  for_each = toset(["coredns"])

  addon_name         = each.value
  kubernetes_version = module.eks.cluster_version
  most_recent        = true
}

# References: https://artifacthub.io/packages/helm/coredns/coredns
#             https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html#updating-coredns-add-on
# ATTENTION!!! Pay attention with CoreDNS installed with this helm chart.
# There isn't helm chart developed by AWS for install custom CoreDNS.
# We use a helm chart developed by community mixed with custom CoreDNS by AWS.
# A version of helm chart maybe not compatible with custom CoreDNS container image.
# See compatible list versions of custom CoreDNS container image using the command:
#
# K8S_VERSION='1.26'
# aws eks describe-addon-versions --addon-name coredns --kubernetes-version $K8S_VERSION --query "addons[].addonVersions[].[addonVersion, compatibilities[].defaultVersion]" --output text
#
resource "helm_release" "coredns" {
  count = var.coredns_fargate ? 1 : 0

  depends_on = [
    # Need to ensure the CoreDNS updates are peformed before provisioning
    null_resource.modify_kube_dns[0]
  ]

  name             = "coredns"
  namespace        = "kube-system"
  create_namespace = false
  description      = "CoreDNS is a DNS server that chains plugins and provides Kubernetes DNS Services"
  chart            = "coredns"
  version          = "1.23.0"
  repository       = "https://coredns.github.io/helm"

  # For EKS image repositories https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html
  values = [
    <<-YAML
      image:
        repository: %{if var.region == "sa-east-1"}602401143452.dkr.ecr.sa-east-1.amazonaws.com/eks/coredns%{else}602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/coredns%{endif}
        tag: ${data.aws_eks_addon_version.this["coredns"].version}

      deployment:
        name: coredns
        annotations:
          eks.amazonaws.com/compute-type: fargate

      service:
        name: kube-dns
        annotations:
          eks.amazonaws.com/compute-type: fargate

      podAnnotations:
        eks.amazonaws.com/compute-type: fargate
      YAML
  ]
}
