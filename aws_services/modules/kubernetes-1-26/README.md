<!-- TOC -->

- [About](#about)
- [Requirements](#requirements)
- [How to](#how-to-use)
- [Documentation of Code Terraform](#documentation-of-code-terraform)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

<!-- TOC -->

# About

Terraform module to create Kubernetes cluster in AWS-EKS 1.26 with self managed nodes, AWS managed nodes and Karpenter nodes.

1. This directory contains the files:<br>
* ``variables.tf`` => where you can define the values of the variables used by ``main.tf``.<br>
2. The goal create Kubernetes cluster in AWS-EKS.

Install [Terraform-docs](https://github.com/terraform-docs/terraform-docs)

```bash
cd /tmp
VERSION=v0.16.0
curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/$VERSION/terraform-docs-$VERSION-$(uname)-amd64.tar.gz

tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/terraform-docs
rm terraform-docs.tar.gz
terraform-docs --version
```

To update this documentation run these commands:

> ATTENTION!!! Set values of DIR_TERRAFORM_MODULE variable as you need

```bash
cd $DIR_TERRAFORM_MODULE
terraform-docs markdown table . > README.md
```

# Requirements

=====================

NOTE: Developed using Terraform 1.4.x syntax and tested with Terragrunt 0.45.x.

=====================

* Configure AWS access credentials using IAM Roles.

* Install tfenv and tgenv commands.

## How to use

Inside repository directory `live/` create a new directory to host terragrunt.hcl file as you need.

Create the inputs values according to the need of the environments in the ``variables.tf`` file.

Validate the settings with the following commands:

```bash
cd <terragrunt_folder_in_live_directory>
terragrunt validate
```

Useful commands:

* ``terragrunt --help``    => Show help of command terraform<br>
* ``terragrunt console``   => Open a live shell to use terraform commands directly with live state<br>
* ``terragrunt providers`` => Prints a tree of the providers used in the configuration<br>
* ``terragrunt init``      => Initialize a Terraform working directory<br>
* ``terragrunt validate``  => Validates the Terraform files<br>
* ``terragrunt plan``      => Generate and show an execution plan<br>
* ``terragrunt apply``     => Builds or changes infrastructure<br>
* ``terragrunt show``      => Inspect Terraform state or plan<br>
* ``terragrunt destroy``   => Destroy Terraform-managed infrastructure

No destroy some resource:

* List all resources

```bash
terragrunt state list
```

* remove that resource you don't want to destroy, you can add more to be excluded if required

```bash
terragrunt state rm <resource_to_be_deleted>
```

* destroy the whole stack except above resource(s)

```bash
terragrunt destroy
```

# Documentation of Code Terraform



## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.62 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.9 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | ~> 1.14 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.19 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.2 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.9 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_ebs_csi_driver_irsa"></a> [aws\_ebs\_csi\_driver\_irsa](#module\_aws\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_aws_efs_csi_driver_irsa"></a> [aws\_efs\_csi\_driver\_irsa](#module\_aws\_efs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_cluster_autoscaler_irsa_role"></a> [cluster\_autoscaler\_irsa\_role](#module\_cluster\_autoscaler\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.14 |
| <a name="module_fluentbit_irsa"></a> [fluentbit\_irsa](#module\_fluentbit\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_karpenter_irsa"></a> [karpenter\_irsa](#module\_karpenter\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_load_balancer_controller_irsa_role"></a> [load\_balancer\_controller\_irsa\_role](#module\_load\_balancer\_controller\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_node_termination_handler_irsa_role"></a> [node\_termination\_handler\_irsa\_role](#module\_node\_termination\_handler\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_velero_irsa_policy"></a> [velero\_irsa\_policy](#module\_velero\_irsa\_policy) | terraform-aws-modules/iam/aws//modules/iam-policy | ~> 5.3 |
| <a name="module_velero_irsa_role"></a> [velero\_irsa\_role](#module\_velero\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |
| <a name="module_vpc_cni_ipv4_irsa_role"></a> [vpc\_cni\_ipv4\_irsa\_role](#module\_vpc\_cni\_ipv4\_irsa\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.3 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_instance_profile.karpenter_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.aws_for_fluentbit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.aws_efs_csi_driver](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_vpc_cni_with_vpn](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.aws_vpc_cni_without_vpn](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.coredns](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.metrics_server](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.node_termination_handler](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.traefik](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.velero](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.alb_traefik_ingress](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.fluentbit_00](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.fluentbit_01](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.fluentbit_02](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.guest_core_rbac](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.karpenter_provisioner](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.storage_class_gp3](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.view_rbac](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |
| [null_resource.core_namespace_customization](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.modify_kube_dns](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.modify_vpc_cni](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.namespace_customization](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remove_default_coredns_deployment](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.storage_class_gp3](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.aws_auth](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.aws_ebs_csi_driver](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.aws_efs_csi_driver](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.aws_load_balancer_controller](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.aws_vpc_cni](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.cluster_autoscaler](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.coredns](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.karpenter](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.metrics_server](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.namespace_customization](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.node_termination_handler](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.rbac](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.traefik](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.velero](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.fluentbit_irsa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [kubectl_path_documents.fluentbit_00](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |
| [kubectl_path_documents.fluentbit_02](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |
| [kubectl_path_documents.guest_core_rbac](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |
| [kubectl_path_documents.view_rbac](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/data-sources/path_documents) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_cluster_encryption_policy"></a> [attach\_cluster\_encryption\_policy](#input\_attach\_cluster\_encryption\_policy) | Indicates whether or not to attach an additional policy for the cluster IAM role to utilize the encryption key provided. | `bool` | `true` | no |
| <a name="input_aws_auth_accounts"></a> [aws\_auth\_accounts](#input\_aws\_auth\_accounts) | List of account maps to add to the aws-auth configmap. | `list(any)` | `[]` | no |
| <a name="input_aws_auth_fargate_profile_pod_execution_role_arns"></a> [aws\_auth\_fargate\_profile\_pod\_execution\_role\_arns](#input\_aws\_auth\_fargate\_profile\_pod\_execution\_role\_arns) | List of Fargate profile pod execution role ARNs to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_aws_auth_node_iam_role_arns_non_windows"></a> [aws\_auth\_node\_iam\_role\_arns\_non\_windows](#input\_aws\_auth\_node\_iam\_role\_arns\_non\_windows) | List of non-Windows based node IAM role ARNs to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_aws_auth_node_iam_role_arns_windows"></a> [aws\_auth\_node\_iam\_role\_arns\_windows](#input\_aws\_auth\_node\_iam\_role\_arns\_windows) | List of Windows based node IAM role ARNs to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | List of additional IAM roles maps to add to the aws-auth configmap.<br> See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.24.1/examples/complete/main.tf#L206 for example format. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_auth_time_wait"></a> [aws\_auth\_time\_wait](#input\_aws\_auth\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | List of additional IAM users maps to add to the aws-auth configmap.<br> See https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v18.24.1/examples/complete/main.tf#L214 for example format. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_ebs_csi_driver_time_wait"></a> [aws\_ebs\_csi\_driver\_time\_wait](#input\_aws\_ebs\_csi\_driver\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"180s"` | no |
| <a name="input_aws_efs_csi_driver_time_wait"></a> [aws\_efs\_csi\_driver\_time\_wait](#input\_aws\_efs\_csi\_driver\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_aws_loadbalancer_controller_time_wait"></a> [aws\_loadbalancer\_controller\_time\_wait](#input\_aws\_loadbalancer\_controller\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_aws_vpc_cni_minimum_ip"></a> [aws\_vpc\_cni\_minimum\_ip](#input\_aws\_vpc\_cni\_minimum\_ip) | Minimum amount of IPs each worker node will reserve for yourself from subnet. | `number` | `14` | no |
| <a name="input_aws_vpc_cni_time_wait"></a> [aws\_vpc\_cni\_time\_wait](#input\_aws\_vpc\_cni\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_aws_vpc_cni_warm_ip"></a> [aws\_vpc\_cni\_warm\_ip](#input\_aws\_vpc\_cni\_warm\_ip) | How many IPs worker node will reserve each call to EC2 API. | `number` | `2` | no |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html). | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | Number of days to retain log events. Default retention - 7 days. | `number` | `7` | no |
| <a name="input_cluster_additional_security_group_ids"></a> [cluster\_additional\_security\_group\_ids](#input\_cluster\_additional\_security\_group\_ids) | List of additional, externally created security group IDs to attach to the cluster control plane. | `list(string)` | `[]` | no |
| <a name="input_cluster_autoscaler_time_wait"></a> [cluster\_autoscaler\_time\_wait](#input\_cluster\_autoscaler\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logs to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html). | `list(string)` | <pre>[<br>  "authenticator"<br>]</pre> | no |
| <a name="input_cluster_encryption_config"></a> [cluster\_encryption\_config](#input\_cluster\_encryption\_config) | Configuration block with encryption configuration for the cluster. | `any` | <pre>{<br>  "resources": [<br>    "secrets"<br>  ]<br>}</pre> | no |
| <a name="input_cluster_encryption_policy_description"></a> [cluster\_encryption\_policy\_description](#input\_cluster\_encryption\_policy\_description) | Description of the cluster encryption policy created. | `string` | `"Cluster encryption policy to allow cluster role to utilize CMK provided"` | no |
| <a name="input_cluster_encryption_policy_name"></a> [cluster\_encryption\_policy\_name](#input\_cluster\_encryption\_policy\_name) | Name to use on cluster encryption policy created. | `string` | `null` | no |
| <a name="input_cluster_encryption_policy_path"></a> [cluster\_encryption\_policy\_path](#input\_cluster\_encryption\_policy\_path) | Cluster encryption policy path. | `string` | `null` | no |
| <a name="input_cluster_encryption_policy_tags"></a> [cluster\_encryption\_policy\_tags](#input\_cluster\_encryption\_policy\_tags) | A map of additional tags to add to the cluster encryption policy created. | `map(string)` | `{}` | no |
| <a name="input_cluster_encryption_policy_use_name_prefix"></a> [cluster\_encryption\_policy\_use\_name\_prefix](#input\_cluster\_encryption\_policy\_use\_name\_prefix) | Determines whether cluster encryption policy name (`cluster_encryption_policy_name`) is used as a prefix. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the EKS cluster. | `string` | `""` | no |
| <a name="input_cluster_security_group_additional_rules"></a> [cluster\_security\_group\_additional\_rules](#input\_cluster\_security\_group\_additional\_rules) | List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source. | `any` | `{}` | no |
| <a name="input_cluster_security_group_description"></a> [cluster\_security\_group\_description](#input\_cluster\_security\_group\_description) | Description of the cluster security group created. | `string` | `"EKS cluster security group"` | no |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | Existing security group ID to be attached to the cluster. Required if `create_cluster_security_group` = `false`. | `string` | `""` | no |
| <a name="input_cluster_security_group_name"></a> [cluster\_security\_group\_name](#input\_cluster\_security\_group\_name) | Name to use on cluster security group created. | `string` | `null` | no |
| <a name="input_cluster_security_group_tags"></a> [cluster\_security\_group\_tags](#input\_cluster\_security\_group\_tags) | A map of additional tags to add to the cluster security group created. | `map(string)` | `{}` | no |
| <a name="input_cluster_security_group_use_name_prefix"></a> [cluster\_security\_group\_use\_name\_prefix](#input\_cluster\_security\_group\_use\_name\_prefix) | Determines whether cluster security group name (`cluster_security_group_name`) is used as a prefix. | `bool` | `true` | no |
| <a name="input_cluster_service_ipv4_cidr"></a> [cluster\_service\_ipv4\_cidr](#input\_cluster\_service\_ipv4\_cidr) | The CIDR block to assign Kubernetes service IP addresses from. If you don't specify a block, Kubernetes assigns addresses from either the 10.100.0.0/16 or 172.20.0.0/16 CIDR blocks. | `string` | `null` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | A map of additional tags to add to the cluster. | `map(string)` | `{}` | no |
| <a name="input_cluster_timeouts"></a> [cluster\_timeouts](#input\_cluster\_timeouts) | Create, update, and delete timeout configurations for the cluster. | `map(string)` | `{}` | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.26`). | `string` | `"1.26"` | no |
| <a name="input_control_plane_subnet_ids"></a> [control\_plane\_subnet\_ids](#input\_control\_plane\_subnet\_ids) | A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned. Used for expanding the pool of subnets used by nodes/node groups without replacing the EKS control plane. | `list(string)` | `[]` | no |
| <a name="input_coredns_fargate"></a> [coredns\_fargate](#input\_coredns\_fargate) | If enabled, deploy coreDNS on Fargate nodes to demonstrate this scenario. | `bool` | `false` | no |
| <a name="input_coredns_time_wait"></a> [coredns\_time\_wait](#input\_coredns\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_create_cloudwatch_log_group"></a> [create\_cloudwatch\_log\_group](#input\_create\_cloudwatch\_log\_group) | Determines whether a log group is created by this module for the cluster logs. If not, AWS will automatically create one if logging is enabled. | `bool` | `true` | no |
| <a name="input_create_cluster_primary_security_group_tags"></a> [create\_cluster\_primary\_security\_group\_tags](#input\_create\_cluster\_primary\_security\_group\_tags) | Indicates whether or not to tag the cluster's primary security group. This security group is created by the EKS service, not the module, and therefore tagging is handled after cluster creation. | `bool` | `true` | no |
| <a name="input_create_cluster_security_group"></a> [create\_cluster\_security\_group](#input\_create\_cluster\_security\_group) | Determines if a security group is created for the cluster or use the existing `cluster_security_group_id`. | `bool` | `true` | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Determines whether a an IAM role is created or to use an existing IAM role. | `bool` | `true` | no |
| <a name="input_create_kms_key"></a> [create\_kms\_key](#input\_create\_kms\_key) | Controls if a KMS key for cluster encryption should be created. | `bool` | `false` | no |
| <a name="input_create_node_security_group"></a> [create\_node\_security\_group](#input\_create\_node\_security\_group) | Determines whether to create a security group for the node groups or use the existing `node_security_group_id`. | `bool` | `true` | no |
| <a name="input_create_traefik_ingress"></a> [create\_traefik\_ingress](#input\_create\_traefik\_ingress) | Enable (if true) or disable (if false) the creation of the traefik ingress. The parameters 'install\_aws\_loadbalancer\_controller' and 'install\_traefik' must have 'true' value. | `bool` | `true` | no |
| <a name="input_default_annotations_namespaces"></a> [default\_annotations\_namespaces](#input\_default\_annotations\_namespaces) | List of annotations for default namespaces. See default\_namespaces in locals.tf. | `list(string)` | `[]` | no |
| <a name="input_default_labels_namespaces"></a> [default\_labels\_namespaces](#input\_default\_labels\_namespaces) | List of labels for default namespaces. See default\_namespaces in locals.tf. | `list(string)` | <pre>[<br>  "namespace_created_with_eks=true"<br>]</pre> | no |
| <a name="input_eks_managed_node_group_defaults"></a> [eks\_managed\_node\_group\_defaults](#input\_eks\_managed\_node\_group\_defaults) | Map of EKS managed node group default configurations | `any` | `{}` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | Map of EKS managed node group definitions to create | `any` | `{}` | no |
| <a name="input_enable_guest_permissions_core_resources"></a> [enable\_guest\_permissions\_core\_resources](#input\_enable\_guest\_permissions\_core\_resources) | Enable (if true) or disable (if false) the creation of the guest permissions to access core resources in the cluster. | `bool` | `true` | no |
| <a name="input_enable_namespace_customization"></a> [enable\_namespace\_customization](#input\_enable\_namespace\_customization) | Enable (if true) or disable (if false) the customization of namespaces. Requires 'namespace\_customization' parameter to be set. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of environment. | `string` | `"testing"` | no |
| <a name="input_fluentbit_cw_log_group_retention_in_days"></a> [fluentbit\_cw\_log\_group\_retention\_in\_days](#input\_fluentbit\_cw\_log\_group\_retention\_in\_days) | Number of days to retain log events collected by fluentbit. Default retention - 7 days. | `number` | `7` | no |
| <a name="input_fluentbit_time_wait"></a> [fluentbit\_time\_wait](#input\_fluentbit\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_iam_role_additional_policies"></a> [iam\_role\_additional\_policies](#input\_iam\_role\_additional\_policies) | Additional policies to be added to the IAM role. | `map(string)` | `{}` | no |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | Existing IAM role ARN for the cluster. Required if `create_iam_role` is set to `false`. | `string` | `null` | no |
| <a name="input_iam_role_description"></a> [iam\_role\_description](#input\_iam\_role\_description) | Description of the role. | `string` | `null` | no |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | Name to use on IAM role created. | `string` | `null` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | Cluster IAM role path. | `string` | `null` | no |
| <a name="input_iam_role_permissions_boundary"></a> [iam\_role\_permissions\_boundary](#input\_iam\_role\_permissions\_boundary) | ARN of the policy that is used to set the permissions boundary for the IAM role. | `string` | `null` | no |
| <a name="input_iam_role_tags"></a> [iam\_role\_tags](#input\_iam\_role\_tags) | A map of additional tags to add to the IAM role created. | `map(string)` | `{}` | no |
| <a name="input_iam_role_use_name_prefix"></a> [iam\_role\_use\_name\_prefix](#input\_iam\_role\_use\_name\_prefix) | Determines whether the IAM role name (`iam_role_name`) is used as a prefix. | `bool` | `true` | no |
| <a name="input_install_aws_efs_csi_driver"></a> [install\_aws\_efs\_csi\_driver](#input\_install\_aws\_efs\_csi\_driver) | Enable (if true) or disable (if false) the installation of the AWS EFS CSI Driver. | `bool` | `true` | no |
| <a name="input_install_aws_loadbalancer_controller"></a> [install\_aws\_loadbalancer\_controller](#input\_install\_aws\_loadbalancer\_controller) | Enable (if true) or disable (if false) the installation of the AWS loadbalancer controller. | `bool` | `true` | no |
| <a name="input_install_aws_vpc_cni_with_vpn"></a> [install\_aws\_vpc\_cni\_with\_vpn](#input\_install\_aws\_vpc\_cni\_with\_vpn) | Enable (if true) or disable (if false) the creation of the AWS VPC CNI (Container Network Interface) with support to VPN (Virtual Private Network). If false, the parameter 'install\_aws\_vpc\_cni\_without\_vpn' must have 'true' value. If true, the parameter 'install\_aws\_vpc\_cni\_without\_vpn' must have 'false' value. | `bool` | `false` | no |
| <a name="input_install_aws_vpc_cni_without_vpn"></a> [install\_aws\_vpc\_cni\_without\_vpn](#input\_install\_aws\_vpc\_cni\_without\_vpn) | Enable (if true) or disable (if false) the creation of the AWS VPC CNI (Container Network Interface) without support to VPN (Virtual Private Network). If true, the parameter 'install\_aws\_vpc\_cni\_with\_vpn' must have 'false' value. If false, the parameter 'install\_aws\_vpc\_cni\_with\_vpn' must have 'true' value. | `bool` | `true` | no |
| <a name="input_install_metrics_server"></a> [install\_metrics\_server](#input\_install\_metrics\_server) | Enable (if true) or disable (if false) the installation of the metrics-server. | `bool` | `true` | no |
| <a name="input_install_storage_class_gp3"></a> [install\_storage\_class\_gp3](#input\_install\_storage\_class\_gp3) | Change (if true) setup default of default StorageClass from GP2 to GP3. | `bool` | `true` | no |
| <a name="input_install_traefik"></a> [install\_traefik](#input\_install\_traefik) | Enable (if true) or disable (if false) the installation of the trafik. | `bool` | `true` | no |
| <a name="input_install_velero"></a> [install\_velero](#input\_install\_velero) | Enable (if true) or disable (if false) the installation of Velero. | `bool` | `false` | no |
| <a name="input_karpenter_amifamily"></a> [karpenter\_amifamily](#input\_karpenter\_amifamily) | Instance AMI Type. Can be Bottlerocket (53s to Ready) or AL2 (70s to Ready). | `string` | `"Bottlerocket"` | no |
| <a name="input_karpenter_availability_zones"></a> [karpenter\_availability\_zones](#input\_karpenter\_availability\_zones) | Availability zones to launch nodes. | `list(any)` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b"<br>]</pre> | no |
| <a name="input_karpenter_capacity_types"></a> [karpenter\_capacity\_types](#input\_karpenter\_capacity\_types) | Capacity Type; Ex spot, on\_demand. | `list(any)` | <pre>[<br>  "spot",<br>  "on_demand"<br>]</pre> | no |
| <a name="input_karpenter_cpu_limit"></a> [karpenter\_cpu\_limit](#input\_karpenter\_cpu\_limit) | CPU Limits to launch total nodes. | `string` | `"100"` | no |
| <a name="input_karpenter_instance_architectures"></a> [karpenter\_instance\_architectures](#input\_karpenter\_instance\_architectures) | Instance architecture list to launch on karpenter. | `list(any)` | <pre>[<br>  "amd64"<br>]</pre> | no |
| <a name="input_karpenter_instance_families"></a> [karpenter\_instance\_families](#input\_karpenter\_instance\_families) | Instance family list to launch on karpenter. | `list(any)` | <pre>[<br>  "m5",<br>  "c5"<br>]</pre> | no |
| <a name="input_karpenter_instance_sizes"></a> [karpenter\_instance\_sizes](#input\_karpenter\_instance\_sizes) | Instance sizes to diversify into instance family. | `list(any)` | <pre>[<br>  "micro",<br>  "medium",<br>  "large",<br>  "2xlarge"<br>]</pre> | no |
| <a name="input_karpenter_memory_limit"></a> [karpenter\_memory\_limit](#input\_karpenter\_memory\_limit) | Memory Limits to launch total nodes. | `string` | `"400Gi"` | no |
| <a name="input_karpenter_time_wait"></a> [karpenter\_time\_wait](#input\_karpenter\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_metrics_server_time_wait"></a> [metrics\_server\_time\_wait](#input\_metrics\_server\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_mng_ami_type"></a> [mng\_ami\_type](#input\_mng\_ami\_type) | Type of Amazon Machine Image (AMI) associated with the EKS Node Group. Valid values are `AL2_x86_64`, `AL2_x86_64_GPU`, `AL2_ARM_64`, `CUSTOM`, `BOTTLEROCKET_ARM_64`, `BOTTLEROCKET_x86_64` | `string` | `"AL2_ARM_64"` | no |
| <a name="input_namespace_customization"></a> [namespace\_customization](#input\_namespace\_customization) | Map with customizations of namespaces. Requires 'enable\_namespace\_customization' parameter to be set. | <pre>map(<br>    object({<br>      namespace   = string,<br>      annotations = list(string),<br>      labels      = list(string)<br>    })<br>  )</pre> | <pre>{<br>  "namespace1": {<br>    "annotations": [<br>      "annotation1=value1",<br>      "annotation2=value2"<br>    ],<br>    "labels": [<br>      "label1=value1",<br>      "label2=value2"<br>    ],<br>    "namespace": "kube-system"<br>  }<br>}</pre> | no |
| <a name="input_namespace_time_wait"></a> [namespace\_time\_wait](#input\_namespace\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_node_security_group_additional_rules"></a> [node\_security\_group\_additional\_rules](#input\_node\_security\_group\_additional\_rules) | List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source. | `any` | `{}` | no |
| <a name="input_node_security_group_description"></a> [node\_security\_group\_description](#input\_node\_security\_group\_description) | Description of the node security group created. | `string` | `"EKS node shared security group"` | no |
| <a name="input_node_security_group_enable_recommended_rules"></a> [node\_security\_group\_enable\_recommended\_rules](#input\_node\_security\_group\_enable\_recommended\_rules) | Determines whether to enable recommended security group rules for the node security group created. This includes node-to-node TCP ingress on ephemeral ports and allows all egress traffic. | `bool` | `true` | no |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | ID of an existing security group to attach to the node groups created. | `string` | `""` | no |
| <a name="input_node_security_group_name"></a> [node\_security\_group\_name](#input\_node\_security\_group\_name) | Name to use on node security group created. | `string` | `null` | no |
| <a name="input_node_security_group_tags"></a> [node\_security\_group\_tags](#input\_node\_security\_group\_tags) | A map of additional tags to add to the node security group created. | `map(string)` | `{}` | no |
| <a name="input_node_security_group_use_name_prefix"></a> [node\_security\_group\_use\_name\_prefix](#input\_node\_security\_group\_use\_name\_prefix) | Determines whether node security group name (`node_security_group_name`) is used as a prefix. | `bool` | `true` | no |
| <a name="input_node_termination_handler_time_wait"></a> [node\_termination\_handler\_time\_wait](#input\_node\_termination\_handler\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_profile"></a> [profile](#input\_profile) | Profile of AWS credential. | `string` | n/a | yes |
| <a name="input_rbac_time_wait"></a> [rbac\_time\_wait](#input\_rbac\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions. | `string` | n/a | yes |
| <a name="input_scost"></a> [scost](#input\_scost) | A value to associate all internal components to a specific cost ID. | `string` | `""` | no |
| <a name="input_self_managed_node_group_defaults"></a> [self\_managed\_node\_group\_defaults](#input\_self\_managed\_node\_group\_defaults) | Map of self-managed node group default configurations | `any` | `{}` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Map of self-managed node group definitions to create | `any` | `{}` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet IDs where the nodes/node groups will be provisioned. If `control_plane_subnet_ids` is not provided, the EKS cluster control plane (ENIs) will be provisioned in these subnets. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_traefik_inbound_cidrs"></a> [traefik\_inbound\_cidrs](#input\_traefik\_inbound\_cidrs) | Allow list of a string with CIDR of inbound Addresses, separeted by comma. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_traefik_ingress_alb_certificate_arn"></a> [traefik\_ingress\_alb\_certificate\_arn](#input\_traefik\_ingress\_alb\_certificate\_arn) | ARN of a certificate to attach an AWS ALB linked to traefik-ingress. | `string` | `""` | no |
| <a name="input_traefik_time_wait"></a> [traefik\_time\_wait](#input\_traefik\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_type_worker_node_group"></a> [type\_worker\_node\_group](#input\_type\_worker\_node\_group) | Enter type of worker node group. Types supported: KARPENTER, AWS\_MANAGED\_NODE (requires 'eks\_managed\_node\_groups' parameter to be set) and SELF\_MANAGED\_NODE (requires 'self\_managed\_node\_groups' parameter to be set). | `string` | `"AWS_MANAGED_NODE"` | no |
| <a name="input_velero_default_fsbackup"></a> [velero\_default\_fsbackup](#input\_velero\_default\_fsbackup) | True if all volume migration should use FileSystemBackup. False otherwise. | `bool` | `false` | no |
| <a name="input_velero_deploy_fsbackup"></a> [velero\_deploy\_fsbackup](#input\_velero\_deploy\_fsbackup) | Whether FileSystemBackup should be deployed to migrate volumes at filesystem level. | `bool` | `false` | no |
| <a name="input_velero_irsa"></a> [velero\_irsa](#input\_velero\_irsa) | The velero IRSA configuration. | `bool` | `false` | no |
| <a name="input_velero_s3_bucket_name"></a> [velero\_s3\_bucket\_name](#input\_velero\_s3\_bucket\_name) | The s3 bucket for velero backups storage. | `string` | `""` | no |
| <a name="input_velero_s3_bucket_prefix"></a> [velero\_s3\_bucket\_prefix](#input\_velero\_s3\_bucket\_prefix) | The s3 bucket directory prefix. | `string` | `""` | no |
| <a name="input_velero_s3_bucket_region"></a> [velero\_s3\_bucket\_region](#input\_velero\_s3\_bucket\_region) | The s3 bucket region for velero backup. | `string` | `""` | no |
| <a name="input_velero_snapshot_enabled"></a> [velero\_snapshot\_enabled](#input\_velero\_snapshot\_enabled) | True if volume migration should use snapshot. | `bool` | `false` | no |
| <a name="input_velero_time_wait"></a> [velero\_time\_wait](#input\_velero\_time\_wait) | Time wait after cluster creation for access API Server for resource deploy. | `string` | `"30s"` | no |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR of the VPC where the cluster and its nodes will be provisioned. | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the cluster and its nodes will be provisioned. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Endpoint for EKS control plane. |
| <a name="output_cluster_iam_role_arn"></a> [cluster\_iam\_role\_arn](#output\_cluster\_iam\_role\_arn) | cluster iam role arn. |
| <a name="output_cluster_iam_role_name"></a> [cluster\_iam\_role\_name](#output\_cluster\_iam\_role\_name) | cluster iam role name. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID for EKS control plane. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Name of EKS control plane. |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | Security group ids attached to the cluster control plane. |
| <a name="output_node_security_group_id"></a> [node\_security\_group\_id](#output\_node\_security\_group\_id) | ID of the node shared security group |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | OIDC provider ARN. |
| <a name="output_region"></a> [region](#output\_region) | AWS region. |
