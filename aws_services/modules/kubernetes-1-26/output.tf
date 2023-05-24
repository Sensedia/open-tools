output "cluster_name" {
  description = "Name of EKS control plane."
  value       = module.eks.cluster_name
}

output "cluster_id" {
  description = "ID for EKS control plane."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "cluster iam role name."
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "cluster iam role arn."
  value       = module.eks.cluster_iam_role_arn
}

output "region" {
  description = "AWS region."
  value       = var.region
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN."
  value       = module.eks.oidc_provider_arn
}

output "node_security_group_id" {
  description = "ID of the node shared security group"
  value       = module.eks.node_security_group_id
}
