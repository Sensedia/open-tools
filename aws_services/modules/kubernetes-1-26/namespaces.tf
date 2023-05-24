################################################################################
# Namespace customizations
################################################################################
resource "time_sleep" "namespace_customization" {
  count = var.enable_namespace_customization ? 1 : 0

  depends_on = [
    module.eks
  ]

  create_duration = var.namespace_time_wait
}

# Add customization in namespaces
# References:
#             https://yellowdesert.consulting/2021/05/31/terraform-map-and-object-patterns/
#             https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace
#             https://developer.hashicorp.com/terraform/tutorials/kubernetes/kubernetes-crd-faas
#             https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
#             https://www.middlewareinventory.com/blog/terraform-for-each-examples/
#             https://stackoverflow.com/questions/71319940/terraform-local-exec-command-with-complex-variables
resource "null_resource" "namespace_customization" {
  for_each = var.enable_namespace_customization == true ? var.namespace_customization : {}

  depends_on = [
    time_sleep.namespace_customization[0],
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ANNOTATIONS = join(" ", each.value.annotations)
      KUBECONFIG  = base64encode(local.kubeconfig)
      LABELS      = join(" ", each.value.labels)
      NAMESPACE   = each.value.namespace
    }

    command = <<-EOT
      #!/usr/bin/env bash
      echo "[INFO] Creating namespace: $NAMESPACE"
      kubectl create ns $NAMESPACE --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      echo "[INFO] Setting annotations and labels on namespace: $NAMESPACE"
      for annotation in $ANNOTATIONS; do
        kubectl annotate ns $NAMESPACE --overwrite $annotation --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      done
      for label in $LABELS; do
        kubectl label ns $NAMESPACE --overwrite $label --kubeconfig <(echo $KUBECONFIG | base64 --decode)
      done
    EOT
  }
}

# Add customization in core namespaces
resource "null_resource" "core_namespace_customization" {
  depends_on = [
    time_sleep.namespace_customization[0],
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      ANNOTATIONS = join(" ", var.default_annotations_namespaces)
      KUBECONFIG  = base64encode(local.kubeconfig)
      LABELS      = join(" ", var.default_labels_namespaces)
      # See implementation of default_namespaces variable in locals.tf file
      NAMESPACES = join(" ", local.default_namespaces)
    }

    command = <<-EOT
      #!/usr/bin/env bash
      for namespace in $NAMESPACES; do
        echo "[INFO] Creating namespace: $namespace"
        kubectl create ns $namespace --kubeconfig <(echo $KUBECONFIG | base64 --decode)
        echo "[INFO] Setting annotations and labels on namespace: $namespace"
        for annotation in $ANNOTATIONS; do
          kubectl annotate ns $namespace --overwrite $annotation --kubeconfig <(echo $KUBECONFIG | base64 --decode)
        done
        for label in $LABELS; do
          kubectl label ns $namespace --overwrite $label --kubeconfig <(echo $KUBECONFIG | base64 --decode)
        done
      done
    EOT
  }
}
