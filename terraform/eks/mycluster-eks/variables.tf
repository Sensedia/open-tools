# Provider config
variable "credentials_file" {
  description = "PATH to credentials file"
  default     = "~/.aws/credentials"
}

variable "profile" {
  description = "Profile of AWS credential."
}

variable "region" {
  description = "AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions"
}

# Networking
variable "subnets" {
  description = "List of IDs subnets public and/or private."
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of VPC."
}

# EKS
variable "cluster_name" {
  description = "Cluster EKS name."
}

variable "cluster_version" {
  description = "Kubernetes version supported by EKS. \n Reference: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"
}

variable "lt_name" {
  description = "Name of template worker group."
}

variable "override_instance_types" {
  description = "Type instances for nodes workers. Reference: https://aws.amazon.com/ec2/pricing/on-demand/"
  type        = list(string)
}

variable "on_demand_percentage_above_base_capacity" {
  description = "On demand percentage above base capacity."
  type        = number
}

variable "autoscaling_enabled" {
  description = "Enable ou disable autoscaling."
  type        = bool
  default     = true
}

variable "asg_min_size" {
  description = "Number minimal of nodes workers in cluster EKS."
  type        = number
}

variable "asg_max_size" {
  description = "Number maximal of nodes workers in cluster EKS."
  type        = number
}

variable "asg_desired_capacity" {
  description = "Number desired of nodes workers in cluster EKS."
  type        = number
}

#variable "kubelet_extra_args" {}

variable "public_ip" {
  description = "Enable ou disable public IP in cluster EKS."
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint, when public access is disabled"
  type        = list(string)
  default     = [ "0.0.0.0/0" ]
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = [ "0.0.0.0/0" ]
}

variable "suspended_processes" {
  description = "Cluster EKS name."
}

variable "root_volume_size" {
  description = "Size of disk in nodes of cluster EKS."
  type        = number
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable.  \n For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = ["api", "audit"]
}

variable "kubelet_extra_args" {
  description = "Extra arguments for EKS."
  type        = string
  default     = "--node-labels=node.kubernetes.io/lifecycle=spot"
}

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events."
  type        = number
  default     = "7"
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers"
  type        = list(string)
  default     = []
}

variable "worker_additional_security_group_ids" {
  description = "A list of additional security group ids to attach to worker instances."
  type        = list(string)
  default     = []
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap.  \n See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/basic/variables.tf for example format."
  type       = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default    = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap.  \n See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/basic/variables.tf for example format."
  type       = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default    = []
}

# Kubernetes manifests
variable "cw_retention_in_days" {
  description = "Fluentd retention in days."
  type        = number
  default     = 7
}

# General
variable "tags" {
  description = "Maps of tags."
  type        = map
  default     = {}
}

variable "environment" {
  description = "Name Terraform workspace."
}

variable "address_allowed" {
  description = "IP or Net address allowed for remote access."
}

variable "aws_key_name" {
  description = "Key pair RSA name."
}
