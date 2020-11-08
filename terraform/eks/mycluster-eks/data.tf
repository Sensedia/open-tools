# Check for correct workspace
data "local_file" "workspace_check" {
  count    = "${var.environment == terraform.workspace ? 0 : 1}"
  filename = "ERROR: Workspace does not match given environment name!"
}

# aws-auth configmap 
data "aws_eks_cluster" "cluster" {
  name = module.eks-cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks-cluster.cluster_id
}

# Logging and Autoscaling components
data "template_file" "fluentd" {
  template = file("${path.module}/templates/fluentd.yaml.tpl")

  vars = {
    cluster_name         = var.cluster_name
    region               = var.region
    cw_retention_in_days = var.cw_retention_in_days
  }
}

# Deploy Autoscaler
data "template_file" "autoscaler" {
  template = file("${path.module}/templates/autoscaler.yaml.tpl")

  vars = {
    cluster_name         = var.cluster_name
    region               = var.region
    cw_retention_in_days = var.cw_retention_in_days
  }
}

# Deploy AWS-CNI
data "template_file" "aws_cni" {
  template = file("${path.module}/templates/aws-k8s-cni.yaml.tpl")

  vars = {
    region = var.region
  }
}