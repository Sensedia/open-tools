# Terraform backend for remote state
terraform {
  backend "s3" {
    encrypt                 = true
    bucket                  = "my-terraform-remote-state-01"
    dynamodb_table          = "my-terraform-state-lock-dynamo"
    region                  = "us-east-1"
    workspace_key_prefix    = "testing"
    key                     = "eks/terraform.tfstate"
    profile                 = "default"
    shared_credentials_file = "~/.aws/credentials"
  }
}
