################################################################################
# storage class GP3
################################################################################
# Chance gp2 storageclass default to "false"
resource "null_resource" "storage_class_gp3" {
  count = var.install_storage_class_gp3 ? 1 : 0

  depends_on = [
    aws_eks_addon.aws_ebs_csi_driver
  ]

  triggers = {}

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }

    command = <<-EOT
      #!/usr/bin/env bash
      echo "[INFO] Annotate default storageclass to false"
      kubectl annotate sc gp2 storageclass.kubernetes.io/is-default-class="false" --overwrite --kubeconfig <(echo $KUBECONFIG | base64 --decode)
    EOT
  }
}

# Create gp3 storageclass as default
resource "kubectl_manifest" "storage_class_gp3" {
  count = var.install_storage_class_gp3 ? 1 : 0

  depends_on = [
    null_resource.storage_class_gp3
  ]

  yaml_body = <<-YAML
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    annotations:
      storageclass.kubernetes.io/is-default-class: "true"
    name: gp3
  parameters:
    type: gp3
  provisioner: kubernetes.io/aws-ebs
  reclaimPolicy: Delete
  volumeBindingMode: WaitForFirstConsumer
  allowVolumeExpansion: true
  YAML
}
