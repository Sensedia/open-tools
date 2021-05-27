<!-- TOC -->

- [About](#about)
- [Requirements](#requirements)
  - [How to](#how-to)
  - [Requirements](#requirements-1)
  - [Providers](#providers)
  - [Inputs](#inputs)
  - [Outputs](#outputs)

<!-- TOC -->
# About

1. This directory contains the files:<br>
  * ``variables.tf`` => where you can define the values of the variables used by ``main.tf``.<br>
  * ``testing.tfvars`` => where you can define the values of the variables used in testing environment.<br>
2. The goal is to create networking required by EKS cluster in AWS.

# Requirements

=====================

NOTE: Developed using Terraform 0.12.x syntax.

=====================

* Configure the AWS Credentials and install the [kubectl](../../../tutorials/install_kubectl.md), [aws-cli](../../../tutorials/install_awscli.md), [terraform](../../../tutorials/install_terraform.md).

* Create the following resources required for the functioning of the EKS cluster:
  * Bucket S3 and DynamoDB table for Terraform state remote;
  * Subnets public and private;
  * VPC;
  * NAT gateway;
  * Internet Gateway;
  * Security group;
  * Route table;
  * Policies.

* Execute the commands:

```bash
cd ~

git clone git@github.com:Sensedia/open-tools.git

cd ~/open-tools/terraform/eks/networking-eks
```

## How to

* Change the values according to the need of the environment in the ``testing.tfvars`` and ``backend.tf`` files.

* Validate the settings and create the environment with the following commands:

```bash
terraform init
terraform validate
terraform workspace new testing
terraform workspace list
terraform workspace select testing
terraform plan -var-file testing.tfvars
terraform apply -var-file testing.tfvars
terraform output
terraform show
```

Useful commands:

* ``terraform --help``   => Show help of command terraform<br>
* ``terraform init``     => Initialize a Terraform working directory<br>
* ``terraform validate`` => Validates the Terraform files<br>
* ``terraform plan``     => Generate and show an execution plan<br>
* ``terraform apply``    => Builds or changes infrastructure<br>
* ``terraform output``   => Reads an output variable from a Terraform state file and prints the value.<br>
* ``terraform show``     => Inspect Terraform state or plan<br>

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.19, < 0.13.0 |
| aws | >= 2.61.0 |
| local | >= 1.4.0 |
| null | >= 2.1.2 |
| random | >= 2.2.1 |
| template | >= 2.1.2 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.61.0 |
| local | >= 1.4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| address\_allowed | IP or Net address allowed for remote access. | `any` | n/a | yes |
| aws\_key\_name | Key pair RSA name. | `any` | n/a | yes |
| aws\_public\_key\_path | PATH to public key in filesystem local. | `any` | n/a | yes |
| bucket\_name | Bucket name for storage Terraform tfstate remote. | `any` | n/a | yes |
| credentials\_file | PATH to credentials file | `string` | `"~/.aws/credentials"` | no |
| dynamodb\_table\_name | DynamoDB Table name for lock Terraform tfstate remote. | `any` | n/a | yes |
| environment | Name Terraform workspace. | `any` | n/a | yes |
| profile | Profile of AWS credential. | `any` | n/a | yes |
| region | AWS region. Reference: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions | `any` | n/a | yes |
| subnet\_private1\_cidr\_block | CIDR block to subnet private1. | `any` | n/a | yes |
| subnet\_public1\_cidr\_block | CIDR block to subnet public1. | `any` | n/a | yes |
| tags | Maps of tags. | `map` | `{}` | no |
| vpc1\_cidr\_block | CIDR block to vpc1. | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | Bucket ARN |
| bucket\_domain\_name | FQDN of bucket |
| bucket\_id | Bucket Name (aka ID) |
| key\_name | Name of key pair RSA |
| security\_group | Id of security Group |
| subnet\_private1 | Id of subnet private 1 |
| subnet\_public1 | Id of subnet public 1 |
| vpc1 | Id of VPC1 |
