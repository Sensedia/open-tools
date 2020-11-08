# Provider config
profile     = "default"   # AWS profile https://amzn.to/2IgHGCs
region      = "us-east-1" # See regions of AWS https://amzn.to/3khGP21
environment = "testing"

# General
# If not existis, create a public and private key with command:
# sudo ssh-keygen -t rsa -b 2048 -v -f /home/aws-testing.pem
# Do not enter a password when creating the keys
#
# The public key will be created in the following path: '/home/aws-testing.pem.pub'
# and will be registered on AWS under the name 'aws-testing'. This public key will
# be associated with the EC2 instances during the creation of the cluster and this
# way you will be able to access them via SSH in the future using the private key
# that is in '/home/aws-testing.pem'.
aws_public_key_path        = "/home/aws-testing.pem.pub"
aws_key_name               = "aws-testing"
address_allowed            = "201.82.34.213/32" # My house public IP Address
bucket_name                = "my-terraform-remote-state-01"
dynamodb_table_name        = "my-terraform-state-lock-dynamo"
vpc1_cidr_block            = "10.0.0.0/16"
subnet_public1_cidr_block  = "10.0.1.0/24"
subnet_private1_cidr_block = "10.0.3.0/24"

tags = {
  Scost       = "testing",
  Terraform   = "true",
  Environment = "testing"
}