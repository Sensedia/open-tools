################################################################################
# general
################################################################################
variable "environment" {
  description = "Name of environment."
  type        = string
  default     = "testing"
}

variable "profile" {
  description = "Profile of AWS credential."
  type        = string
}

variable "region" {
  description = "AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions."
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}


################################################################################
# cluster
################################################################################
variable "attach_cluster_encryption_policy" {
  description = "Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided."
  type        = bool
  default     = true
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane."
  type        = list(string)
  default     = []
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)."
  type        = list(string)
  default     = ["authenticator"]
}

variable "create_kms_key" {
  description = "Controls if a KMS key for cluster encryption should be created."
  type        = bool
  default     = false
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster."
  type        = any
  default     = {
    "resources": [
      "secrets"
    ]
  }
}

variable "cluster_encryption_policy_description" {
  description = "Description of the cluster encryption policy created."
  type        = string
  default     = "Cluster encryption policy to allow cluster role to utilize CMK provided"
}

variable "cluster_encryption_policy_name" {
  description = "Name to use on cluster encryption policy created."
  type        = string
  default     = null
}

variable "cluster_encryption_policy_path" {
  description = "Cluster encryption policy path."
  type        = string
  default     = null
}

variable "cluster_encryption_policy_tags" {
  description = "A map of additional tags to add to the cluster encryption policy created."
  type        = map(string)
  default     = {}
}

variable "cluster_encryption_policy_use_name_prefix" {
  description = "Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix."
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.23`)."
  type        = string
  default     = "1.25"
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane."
  type        = list(string)
  default     = []
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks."
  type        = string
  default     = null
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster."
  type        = map(string)
  default     = {}
}

variable "cluster_timeouts" {
  description = "Create, update, and delete timeout configurations for the cluster."
  type        = map(string)
  default     = {}
}

variable "create_cluster_primary_security_group_tags" {
  description = "Indicates whether or not to tag the cluster's primary security group. This security group is created by the EKS service, not the module, and therefore tagging is handled after cluster creation."
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets."
  type        = list(string)
  default     = []
}

variable "type_worker_node_group" {
  description = "Enter type of worker node group. Types supported: KARPENTER, AWS_MANAGED_NODE (requires 'eks_managed_node_groups' parameter to be set) and SELF_MANAGED_NODE (requires 'self_managed_node_groups' parameter to be set)."
  type        = string
  default     = "AWS_MANAGED_NODE"
  validation {
    condition     = contains(["KARPENTER", "AWS_MANAGED_NODE", "SELF_MANAGED_NODE"], var.type_worker_node_group)
    error_message = "Use a valid option. Types supported: KARPENTER, AWS_MANAGED_NODE and SELF_MANAGED_NODE."
  }
}

variable "vpc_id" {
  description = "ID of the VPC where the cluster and its nodes will be provisioned."
  type        = string
  default     = null
}

variable "vpc_cidr_block" {
  description = "CIDR of the VPC where the cluster and its nodes will be provisioned."
  type        = list(string)
  default     = []
}


################################################################################
# CloudWatch Log Group
################################################################################
variable "create_cloudwatch_log_group" {
  description = "Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled."
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 7 days."
  type        = number
  default     = 7
}


################################################################################
# Cluster Security Group
################################################################################
variable "create_cluster_security_group" {
  description = "Determines if a security group is created for the cluster or use the existing `cluster_security_group_id`."
  type        = bool
  default     = true
}

variable "cluster_security_group_description" {
  description = "Description of the cluster security group created."
  type        = string
  default     = "EKS cluster security group"
}

variable "cluster_security_group_id" {
  description = "Existing security group ID to be attached to the cluster. Required if `create_cluster_security_group` = `false`."
  type        = string
  default     = ""
}

variable "cluster_security_group_name" {
  description = "Name to use on cluster security group created."
  type        = string
  default     = null
}

variable "cluster_security_group_use_name_prefix" {
  description = "Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix."
  type        = bool
  default     = true
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source."
  type        = any
  default     = {}
}

variable "cluster_security_group_tags" {
  description = "A map of additional tags to add to the cluster security group created."
  type        = map(string)
  default     = {}
}


################################################################################
# Node Security Group
################################################################################
variable "create_node_security_group" {
  description = "Determines whether to create a security group for the node groups or use the existing `node_security_group_id`."
  type        = bool
  default     = true
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source."
  type        = any
  default     = {}
}

variable "node_security_group_description" {
  description = "Description of the node security group created."
  type        = string
  default     = "EKS node shared security group"
}

variable "node_security_group_id" {
  description = "ID of an existing security group to attach to the node groups created."
  type        = string
  default     = ""
}

variable "node_security_group_name" {
  description = "Name to use on node security group created."
  type        = string
  default     = null
}

variable "node_security_group_use_name_prefix" {
  description = "Determines whether node security group name (`node_security_group_name`) is used as a prefix."
  type        = bool
  default     = true
}

variable "node_security_group_tags" {
  description = "A map of additional tags to add to the node security group created."
  type        = map(string)
  default     = {}
}


################################################################################
# Cluster IAM Role
################################################################################
variable "create_iam_role" {
  description = "Determines whether a an IAM role is created or to use an existing IAM role."
  type        = bool
  default     = true
}

variable "iam_role_additional_policies" {
  description = "Additional policies to be added to the IAM role."
  type        = map(string)
  default     = {}
}

variable "iam_role_arn" {
  description = "Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`."
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "Name to use on IAM role created."
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name`) is used as a prefix."
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "Cluster IAM role path."
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role."
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role created."
  type        = map(string)
  default     = {}
}


################################################################################
# aws-auth configmap
################################################################################
variable "aws_auth_accounts" {
  description = "List of account maps to add to the aws-auth configmap."
  type        = list(any)
  default     = []
}

variable "aws_auth_node_iam_role_arns_non_windows" {
  description = "List of non-Windows based node IAM role ARNs to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "aws_auth_node_iam_role_arns_windows" {
  description = "List of Windows based node IAM role ARNs to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "aws_auth_fargate_profile_pod_execution_role_arns" {
  description = "List of Fargate profile pod execution role ARNs to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "aws_auth_roles" {
  description = "List of additional IAM roles maps to add to the aws-auth configmap.  \n See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.24.1/examples/complete/main.tf#L206 for example format."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "aws_auth_users" {
  description = "List of additional IAM users maps to add to the aws-auth configmap.  \n See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.24.1/examples/complete/main.tf#L214 for example format."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}


################################################################################
# AWS EKS Managed Node Group
################################################################################
variable "eks_managed_node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

variable "eks_managed_node_group_defaults" {
  description = "Map of EKS managed node group default configurations"
  type        = any
  default     = {}
}

variable "mng_ami_type" {
  description = "Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values are `AL2_x86_64`, `AL2_x86_64_GPU`, `AL2_ARM_64`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64`"
  type        = string
  default     = "AL2_ARM_64"
}


################################################################################
# Self Managed Node Group
################################################################################
variable "self_managed_node_groups" {
  description = "Map of self-managed node group definitions to create"
  type        = any
  default     = {}
}

variable "self_managed_node_group_defaults" {
  description = "Map of self-managed node group default configurations"
  type        = any
  default     = {}
}


################################################################################
# Cluster autoscaler
################################################################################
variable "cluster_autoscaler_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# AWS LoadBalancer Controller
################################################################################
variable "aws_loadbalancer_controller_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "install_aws_loadbalancer_controller" {
  description = "Enable (if true) or disable (if false) the installation of the AWS loadbalancer controller."
  type        = bool
  default     = true
}


################################################################################
# AWS VPC CNI
################################################################################
variable "aws_vpc_cni_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "install_aws_vpc_cni_without_vpn" {
  description = "Enable (if true) or disable (if false) the creation of the AWS VPC CNI (Container Network Interface) without support to VPN (Virtual Private Network). If true, the parameter 'install_aws_vpc_cni_with_vpn' must have 'false' value. If false, the parameter 'install_aws_vpc_cni_with_vpn' must have 'true' value."
  type        = bool
  default     = true
}

variable "install_aws_vpc_cni_with_vpn" {
  description = "Enable (if true) or disable (if false) the creation of the AWS VPC CNI (Container Network Interface) with support to VPN (Virtual Private Network). If false, the parameter 'install_aws_vpc_cni_without_vpn' must have 'true' value. If true, the parameter 'install_aws_vpc_cni_without_vpn' must have 'false' value."
  type        = bool
  default     = false
}

variable "aws_vpc_cni_minimum_ip" {
  description = "Minimum amount of IPs each worker node will reserve for yourself from subnet."
  type        = number
  default     = 14
}

variable "aws_vpc_cni_warm_ip" {
  description = "How many IPs worker node will reserve each call to EC2 API."
  type        = number
  default     = 2
}


################################################################################
# coreDNS
################################################################################
variable "coredns_fargate" {
  description = "If enabled, deploy coreDNS on Fargate nodes to demonstrate this scenario."
  type        = bool
  default     = false
}

variable "coredns_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# EBS CSI Driver
################################################################################
variable "aws_ebs_csi_driver_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "180s"
}


################################################################################
# EFS CSI Driver
################################################################################
variable "install_aws_efs_csi_driver" {
  description = "Enable (if true) or disable (if false) the installation of the AWS EFS CSI Driver."
  type        = bool
  default     = true
}

variable "aws_efs_csi_driver_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# fluentbit
################################################################################
variable "fluentbit_cw_log_group_retention_in_days" {
  description = "Number of days to retain log events collected by fluentbit. Default retention - 7 days."
  type        = number
  default     = 7
}

variable "fluentbit_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# karpenter
################################################################################
variable "karpenter_amifamily" {
  description = "Instance AMI Type. Can be Bottlerocket (53s to Ready) or AL2 (70s to Ready)."
  type        = string
  default     = "Bottlerocket"
}

variable "karpenter_availability_zones" {
  description = "Availability zones to launch nodes."
  type        = list(any)
  default = [
    "us-east-1a",
    "us-east-1b",
  ]
}

variable "karpenter_capacity_types" {
  description = "Capacity Type; Ex spot, on_demand."
  type        = list(any)
  default = [
    "spot",
    "on_demand",
  ]
}

variable "karpenter_cpu_limit" {
  description = "CPU Limits to launch total nodes."
  type        = string
  default     = "100"
}

variable "karpenter_instance_architectures" {
  description = "Instance architecture list to launch on karpenter."
  type        = list(any)
  default = [
    "amd64",
  ]
}

variable "karpenter_instance_families" {
  description = "Instance family list to launch on karpenter."
  type        = list(any)
  default = [
    "m5",
    "c5",
  ]
}

variable "karpenter_instance_sizes" {
  description = "Instance sizes to diversify into instance family."
  type        = list(any)
  default = [
    "micro",
    "medium",
    "large",
    "2xlarge",
  ]
}

variable "karpenter_memory_limit" {
  description = "Memory Limits to launch total nodes."
  type        = string
  default     = "400Gi"
}

variable "karpenter_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# metrics-server
################################################################################
variable "install_metrics_server" {
  description = "Enable (if true) or disable (if false) the installation of the metrics-server."
  type        = bool
  default     = true
}

variable "metrics_server_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# Namespace customizations
################################################################################
variable "namespace_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "enable_namespace_customization" {
  description = "Enable (if true) or disable (if false) the customization of namespaces. Requires 'namespace_customization' parameter to be set."
  type        = bool
  default     = false
}

# Reference: https://yellowdesert.consulting/2021/05/31/terraform-map-and-object-patterns/
variable "namespace_customization" {
  description = "Map with customizations of namespaces. Requires 'enable_namespace_customization' parameter to be set."
  type = map(
    object({
      namespace   = string,
      annotations = list(string),
      labels      = list(string)
    })
  )
  default = {
    namespace1 = {
      namespace   = "kube-system",
      annotations = ["annotation1=value1", "annotation2=value2"],
      labels      = ["label1=value1", "label2=value2"]
    }
  }
}

variable "default_annotations_namespaces" {
  description = "List of annotations for default namespaces. See default_namespaces in locals.tf."
  type        = list(string)
  default     = []
}

variable "default_labels_namespaces" {
  description = "List of labels for default namespaces. See default_namespaces in locals.tf."
  type        = list(string)
  default     = ["namespace_created_with_eks=true"]
}


################################################################################
# Node Termination Handler
################################################################################
variable "node_termination_handler_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# RBAC - Role-based access control
################################################################################
variable "enable_guest_permissions_core_resources" {
  description = "Enable (if true) or disable (if false) the creation of the guest permissions to access core resources in the cluster."
  type        = bool
  default     = true
}

variable "rbac_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}


################################################################################
# traefik
################################################################################
variable "install_traefik" {
  description = "Enable (if true) or disable (if false) the installation of the trafik."
  type        = bool
  default     = true
}

variable "create_traefik_ingress" {
  description = "Enable (if true) or disable (if false) the creation of the traefik ingress. The parameters 'install_aws_loadbalancer_controller' and 'install_traefik' must have 'true' value."
  type        = bool
  default     = true
}

variable "traefik_ingress_alb_certificate_arn" {
  description = "ARN of a certificate to attach an AWS ALB linked to traefik-ingress."
  type        = string
  default     = ""
}

variable "traefik_time_wait" {
  type        = string
  description = "Time wait after cluster creation for access API Server for resource deploy."
  default     = "30s"
}

variable "traefik_inbound_cidrs" {
  type        = string
  description = "Allow list of a string with CIDR of inbound Addresses, separeted by comma."
  default     = "0.0.0.0/0"
}

################################################################################
# Velero
################################################################################
variable "install_velero" {
  description = "Enable (if true) or disable (if false) the installation of Velero."
  type        = bool
  default     = false
}

variable "velero_time_wait" {
  description = "Time wait after cluster creation for access API Server for resource deploy."
  type        = string
  default     = "30s"
}

variable "velero_s3_bucket_name" {
  description = "The s3 bucket for velero backups storage."
  type        = string
  default     = ""
}

variable "velero_s3_bucket_prefix" {
  description = "The s3 bucket directory prefix."
  type        = string
  default     = ""
}

variable "velero_s3_bucket_region" {
  description = "The s3 bucket region for velero backup."
  type        = string
  default     = ""
}

variable "velero_deploy_restic" {
  description = "Whether Restic should be deployed to migrate volumes at filesystem level."
  type        = bool
  default     = false
}

variable "velero_default_restic" {
  description = "True if all volume migration should use Restic. False otherwise."
  type        = bool
  default     = false
}

variable "velero_snapshot_enabled" {
  description = "True if volume migration should use snapshot."
  type        = bool
  default     = false
}

variable "velero_irsa" {
  description = "The velero IRSA configuration."
  type        = bool
  default     = false
}
