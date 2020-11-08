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

variable "aws_public_key_path" {
  description = "PATH to public key in filesystem local."
}

variable "bucket_name" {
  description = "Bucket name for storage Terraform tfstate remote."
}

variable "dynamodb_table_name"{
  description = "DynamoDB Table name for lock Terraform tfstate remote."
}

variable "vpc1_cidr_block" {
  description = "CIDR block to vpc1."
}

variable "subnet_public1_cidr_block" {
  description = "CIDR block to subnet public1."
}

variable "subnet_private1_cidr_block" {
  description = "CIDR block to subnet private1."
}
