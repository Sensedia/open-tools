################################################################################
# RBAC - Role-based access control
################################################################################
resource "time_sleep" "rbac" {
  count = var.enable_guest_permissions_core_resources ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.rbac_time_wait
}

#-----------------------------
# RBAC for view resources
#-----------------------------
data "kubectl_path_documents" "view_rbac" {
  pattern = "${path.module}/templates/view_rbac.yaml"
}

resource "kubectl_manifest" "view_rbac" {
  for_each = data.kubectl_path_documents.view_rbac.manifests

  depends_on = [
    time_sleep.rbac[0]
  ]

  yaml_body = each.value
}

#-----------------------------
# RBAC for core resources
#-----------------------------
data "kubectl_path_documents" "guest_core_rbac" {
  count = var.enable_guest_permissions_core_resources ? 1 : 0

  pattern = "${path.module}/templates/guest_core_rbac.yaml"
}

resource "kubectl_manifest" "guest_core_rbac" {
  for_each = var.enable_guest_permissions_core_resources == true ? data.kubectl_path_documents.guest_core_rbac[0].manifests : {}

  depends_on = [
    time_sleep.rbac[0]
  ]

  yaml_body = each.value
}
