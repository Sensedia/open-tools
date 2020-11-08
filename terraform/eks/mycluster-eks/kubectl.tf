# Apply kube manifest to eks cluster
resource "null_resource" "install_kube_manifests" {
  depends_on = [module.eks-cluster]

  provisioner "local-exec" {
    working_dir = path.module

    interpreter = ["/bin/sh", "-c"]

    command = <<EOS
mkdir -p temp;
echo '${module.eks-cluster.kubeconfig}' > temp/kubeconfig
echo '${null_resource.install_kube_manifests.triggers.fluentd_rendered}' > temp/fluentd.yaml;
echo '${null_resource.install_kube_manifests.triggers.autoscaler_rendered}' > temp/autoscaler.yaml;
echo '${null_resource.install_kube_manifests.triggers.aws_cni_rendered}' > temp/aws_cni.yaml;
kubectl apply -f temp/ --kubeconfig temp/kubeconfig
rm -r temp;
EOS

  }

  triggers = {
    fluentd_rendered    = data.template_file.fluentd.rendered
    autoscaler_rendered = data.template_file.autoscaler.rendered
    aws_cni_rendered    = data.template_file.aws_cni.rendered
    endpoint            = data.aws_eks_cluster.cluster.endpoint
  }
}
