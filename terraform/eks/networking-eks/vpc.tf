# Reference:
# https://github.com/glaucius/aws-terraform
# https://www.terraform.io/docs/providers/aws/d/vpc.html
# https://www.terraform.io/docs/providers/aws/d/subnet.html

# Check for correct workspace
data "local_file" "workspace_check" {
  count    = "${var.environment == terraform.workspace ? 0 : 1}"
  filename = "ERROR: Workspace does not match given environment name!"
}

# Create VPC
resource "aws_vpc" "vpc1" {
  cidr_block           = var.vpc1_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  #enable_dns_hostnames = true

  tags = merge(
    {
      Name = "vpc, aws",
    },
    var.tags,
  )
}

# Subnet Public
resource "aws_subnet" "subnet_public1" {
  vpc_id                    = aws_vpc.vpc1.id
  cidr_block                = var.subnet_public1_cidr_block
    map_public_ip_on_launch = "true" #it makes this a public subnet
  availability_zone         = data.aws_availability_zones.available.names[0]

  tags = merge(
    {
      Name                     = "public1, subnet, aws",
      "kubernetes.io/role/elb" = "1"
    },
    var.tags,
  )
}

# Subnet Private
resource "aws_subnet" "subnet_private1" {
  vpc_id                    = aws_vpc.vpc1.id
  cidr_block                = var.subnet_private1_cidr_block
    map_public_ip_on_launch = "false" //it makes this a public subnet
  availability_zone         = data.aws_availability_zones.available.names[1]

  tags = merge(
    {
      Name                              = "private1, subnet, aws",
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.tags,
  )
}