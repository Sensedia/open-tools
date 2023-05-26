#### Menu

<!-- TOC -->

- [About](#about)
- [Requirements](#requirements)
- [Structure of directories](#structure-of-directories)
- [Clearing the Terragrunt cache](#clearing-the-terragrunt-cache)
- [How to Install](#how-to-install)
  - [Stage 0: Change the configurations](#stage-0-change-the-configurations)
  - [Stage 1: Create VPC](#stage-1-create-vpc)
  - [Stage 2: Create key pair RSA](#stage-2-create-key-pair-rsa)
  - [Stage 3: Create KMS](#stage-3-create-kms)
  - [Stage 4: Create Kubernetes cluster](#stage-4-create-kubernetes-cluster)
- [How to Uninstall](#how-to-uninstall)
  - [Remove Kubernetes cluster](#remove-kubernetes-cluster)
  - [Remove KMS](#remove-kms)
  - [Remove subnets, NAT Gateway and VPC](#remove-subnets-nat-gateway-and-vpc)
  - [Remove key pair RSA](#remove-key-pair-rsa)
  - [Remove AWS S3 Bucket](#remove-aws-s3-bucket)
  - [Remove DynamoDB Table](#remove-dynamodb-table)

<!-- TOC -->

# About

Create EKS Kubernetes cluster 1.27 using Terragrunt and Terraform code.

Thanks to the Cloud Platform Team for their contribution to the terraform module, documentation and terragrunt.

* [Danilo Rocha](https://www.linkedin.com/in/danilo-figueiredo-rocha/)
* [Alan Arakaki](https://www.linkedin.com/in/alanarakaki/)
* [Tiago Vilas Boas](https://www.linkedin.com/in/tavilasboas/)
* [Lucas Santos](https://www.linkedin.com/in/lucas-vieira-dos-santos/)
* [Fabiano Costa](https://www.linkedin.com/in/fabiano-costa/)
* [Aécio Pires](https://www.linkedin.com/in/aeciopires/)

# Requirements

* Configure the AWS Credentials and all install all packages and binaries following the instructions on the [REQUIREMENTS.md](../REQUIREMENTS.md) file.

Access https://terragrunt.gruntwork.io/docs/#getting-started for more informations about Terragrunt commands.

Terragrunt is a thin wrapper that provides extra tools for keeping your configurations DRY, working with multiple Terraform modules, and managing remote state.

Terragrunt will forward almost all commands, arguments, and options directly to Terraform, but based on the settings in your ``terragrunt.hcl`` file.

```diff
- ATTENTION!!!
- Bug possible: https://github.com/hashicorp/terraform-provider-aws/issues/14917
+ Fix: ``export AWS_DEFAULT_REGION=region_name``.
```

# Structure of directories

```bash
├── live # Directory with Terragrunt code
│   ├── default.hcl
│   ├── empty.yaml
│   └── testing # Directory with environment code
│       ├── environment.hcl # Environment configurations for Terragrunt code
│       ├── regions # Directory with regions code
│       │   └── us-east-2 # Directory with specific region code
│       │       ├── mycustomer # Directory with specific resources code of customer
│       │       │   ├── certificates
│       │       │   │   ├── validation-wildcard-mydomain-com
│       │       │   │   │   └── terragrunt.hcl # Terragrunt for create DNS record to validate certificate
│       │       │   │   └── wildcard-mydomain-com
│       │       │   │       └── terragrunt.hcl # Terragrunt for create certificate
│       │       │   ├── customer.hcl  # Customer configurations for Terragrunt code
│       │       │   ├── ec2
│       │       │   │   └── apps
│       │       │   │       └── terragrunt.hcl # Terragrunt for create EC2 instance
│       │       │   ├── eks
│       │       │   │   └── cluster1-gyr4
│       │       │   │       └── terragrunt.hcl # Terragrunt for create EKS cluster
│       │       │   ├── keypair
│       │       │   │   └── key-gyr4
│       │       │   │       └── terragrunt.hcl # Terragrunt for create Key pair
│       │       │   ├── kms
│       │       │   │   └── kms-gyr4
│       │       │   │       └── terragrunt.hcl # Terragrunt for create KMS
│       │       │   └── vpc
│       │       │       └── net-gyr4
│       │       │           └── terragrunt.hcl # Terragrunt for create VPC
│       │       └── region.hcl # Region configurations for Terragrunt code
│       └── terragrunt.hcl # General Terragrunt code for manage state in S3 e lockID in DynamoDB
├── modules # Directory with Terraform modules
│   └── kubernetes-1-27 # Terraform module for create EKS cluster
└── README.md # This documentation
```

# Clearing the Terragrunt cache

Terragrunt creates a ``.terragrunt-cache`` folder in the current working directory as its scratch directory. It downloads your remote Terraform configurations into this folder, runs your Terraform commands in this folder, and any modules and providers those commands download also get stored in this folder. You can safely delete this folder any time and Terragrunt will recreate it as necessary.

If you need to clean up a lot of these folders (e.g., after ``terragrunt apply``), you can use the following commands on Mac and Linux:

Recursively find all the ``.terragrunt-cache`` folders that are children of the current folder:

```bash
find . -type d -name ".terragrunt-cache" | xargs rm -rf
```

Reference: https://terragrunt.gruntwork.io/docs/features/caching/

# How to Install

* Clone repository.

```bash
mkdir ~/git

cd ~/git

git clone https://github.com/Sensedia/open-tools
```

> **WARNING:** Before start to contribute, run the command: `git pull origin master` to fetch the newest content of the main branch and avoid conflicts that can make you waste time.

* Create a branch. Example:

```bash
git checkout -b BRANCH_NAME
```

## Stage 0: Change the configurations

* Change values in files ``environment.hcl``, ``region.hcl`` and ``customer.hcl`` files.

```bash
cd ~/git/open-tools/aws_services/

find . -type f | grep "environment.hcl\|region.hcl\|customer.hcl" | grep -v terragrunt-cache
```

## Stage 1: Create VPC

* For create VPC for specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/vpc/net-${SUFFIX}"
```

Run the ``terragrunt`` commands.

```bash
terragrunt validate
terragrunt plan
terragrunt apply
terragrunt output
```

## Stage 2: Create key pair RSA

* For create key pair RSA for specific customer:

Example:

```bash
SUFFIX=gyr4

ssh-keygen -t rsa -b 4096 -v -f ~/key-$SUFFIX.pem
```

* Copy content public key without USER and HOST.

```bash
cat ~/key-$SUFFIX.pem.pub | cut -d " " -f1,2
```

* Example:

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6UOQ5zd6yRWsJESIpRPBUGK7yWcNdXSZl+NGbOy4xndkSOBYWWVr0IJk3nEddqsIxfTazh8p9gwVu0O1WUTsxOxTx6vk8EQbArA/o8m+Hiue2pPJlJDl+cY2t7twfwzoh6aZ0MstYvMRrjvTKHcur4bXqD/UqaTn1UeNJ2WytY8+JSvtx3YoS97UHFiGmHnEfZzsShVSkqJv0wgm1eqZnajFVcqXIKOSyxk0CN4kfCTOd29b5Y8CoO1o4IAqISoz2eecViTw5gy0IlhEtmoa03084WSyOzGG/D0QZ0lfA3mXgAAmG5uv/5sN0E7pzs4R1ZgMFYHorN8Cdp+3eJiPX
```

* Change the values according to the need of the customer in ``~/git/open-tools/aws_services/live/testing/regions/us-east-2/mycustomer/customer.hcl``.

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/keypair/key-${SUFFIX}/"
```

Run the ``terragrunt`` commands.

```bash
terragrunt validate
terragrunt plan
terragrunt apply
terragrunt output
```

## Stage 3: Create KMS

* For create KMS for specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/kms/kms-${SUFFIX}/"
```

Run the ``terragrunt`` commands.

```bash
terragrunt validate
terragrunt plan
terragrunt apply
terragrunt output
```

## Stage 4: Create Kubernetes cluster

* For create EKS in specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'
CLUSTER_NAME='cluster1'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/eks/${CLUSTER_NAME}-${SUFFIX}/"
```

Run the ``terragrunt`` commands.

```bash
terragrunt validate
terragrunt plan
terragrunt apply
terragrunt output
```

Authenticate in cluster with follow command.

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'
CUSTOMER_ID='cdk17o7adl'
CLUSTER_NAME="${CUSTOMER_ID}-cluster1-${SUFFIX}"

aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION" --profile my-account
```

```diff
- ATTENTION!!!
- Problems with aws-auth configmap or kubeconfig?
+ Solutions:
```

```bash
terragrunt state list
terragrunt state rm kubernetes_config_map.aws_auth[0]
terragrunt state rm local_file.kubeconfig[0]
terragrunt import kubernetes_config_map.aws_auth[0] kube-system/aws-auth
terragrunt apply -auto-approve
```

References:

* https://github.com/terraform-aws-modules/terraform-aws-eks/issues/699
* https://github.com/terraform-aws-modules/terraform-aws-eks/issues/852
* https://github.com/terraform-aws-modules/terraform-aws-eks/issues/911
* https://github.com/terraform-aws-modules/terraform-aws-eks/issues/1280
* https://medium.com/@ssorcnafets/terraform-k8s-provider-auth-issue-eb98814e673c
* https://github.com/aws/containers-roadmap/issues/654
* https://github.com/terraform-aws-modules/terraform-aws-eks
* https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/launch_templates/main.tf
* https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
* https://github.com/particuleio/teks/blob/main/terragrunt/live/production/eu-west-1/clusters/demo/eks/terragrunt.hcl

# How to Uninstall

## Remove Kubernetes cluster

* For remove EKS for specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'
CLUSTER_NAME='cluster1'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/eks/${CLUSTER_NAME}-$SUFFIX/"
```

Run the command:

```bash
terragrunt destroy
```

## Remove KMS

* For remove EKS for specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/kms/kms-$SUFFIX/"
```

Run the command:

```bash
terragrunt destroy
```

## Remove subnets, NAT Gateway and VPC

* For remove network resources for specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/vpc/net-$SUFFIX/"
```

Run the command:

```bash
terragrunt destroy
```

## Remove key pair RSA

* For remove key par RSA for specific customer:

```bash
SUFFIX='gyr4'
AWS_REGION='us-east-2'

cd "~/git/open-tools/aws_services/live/testing/regions/${AWS_REGION}/mycustomer/keypair/key-$SUFFIX/"
```

Run the ``terragrunt`` command.

```bash
terragrunt destroy
```

## Remove AWS S3 Bucket

Run the command:

```bash
AWS_ACCOUNT_ID='CHANGE_HERE'
AWS_REGION='us-east-2'

aws s3 rb "s3://terragrunt-remote-state-${AWS_ACCOUNT_ID}" \
  --force \
  --region "$AWS_REGION" \
  --profile my-account

# or

aws s3api delete-bucket \
  --bucket "terragrunt-remote-state-${AWS_ACCOUNT_ID}" \
  --region "$AWS_REGION" \
  --profile my-account
```

References:

* https://docs.aws.amazon.com/AmazonS3/latest/userguide/delete-bucket.html
* https://docs.aws.amazon.com/cli/latest/reference/s3api/delete-bucket.html

## Remove DynamoDB Table

Run the command:

```bash
AWS_ACCOUNT_ID='CHANGE_HERE'
AWS_REGION='us-east-2'

aws dynamodb delete-table \
  --table-name "terragrunt-state-lock-dynamo-${AWS_ACCOUNT_ID}" \
  --region "$AWS_REGION" \
  --profile my-account
```

References:

* https://docs.aws.amazon.com/cli/latest/reference/dynamodb/delete-table.html
