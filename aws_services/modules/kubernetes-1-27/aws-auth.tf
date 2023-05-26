################################################################################
# aws-auth configmap
################################################################################

## Extracted from https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.30.2/main.tf
## Workaround to avoid intermittent and unpredictable errors which are hard to debug and diagnose with kubernetes, helm, kubectl providers.
## Known error see more in the WARNING block: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources

resource "time_sleep" "aws_auth" {
  depends_on = [
    module.eks
  ]

  create_duration = var.aws_auth_time_wait
}

# See implementation of case_result variable in locals.tf file
resource "kubernetes_config_map" "aws_auth" {
  # ATTENTION!!!
  # In error case with node join to cluster in SELF_MANAGED_NODE,
  # verify if this resource for aws_auth is being executed or 
  # is happening a race condition blocking this resource.

  count = local.case_result == "SELF_MANAGED_NODE" ? 1 : 0

  depends_on = [
    module.eks,
    time_sleep.aws_auth,
  ]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data

  lifecycle {
    # We are ignoring the data here since we will manage it with the resource below
    # This is only intended to be used in scenarios where the configmap does not exist
    ignore_changes = [data]
  }
}

# See implementation of case_result variable in locals.tf file
resource "kubernetes_config_map_v1_data" "aws_auth" {
  count = local.case_result != "SELF_MANAGED_NODE" ? 1 : 0

  depends_on = [
    # Required for instances where the configmap does not exist yet to avoid race condition
    kubernetes_config_map.aws_auth[0],
    module.eks,
    time_sleep.aws_auth,
  ]

  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data
}
