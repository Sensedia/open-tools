# Reference: 
# https://github.com/glaucius/aws-terraform
# https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
# https://www.terraform.io/docs/providers/aws/d/internet_gateway.html

# Create Internet Nat Gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = merge(
    {
      Name = "router, gateway, aws, vpc1",
    },
    var.tags,
  )
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  vpc      = true

  tags = merge(
    {
      Name = "nat, gateway, aws, vpc1",
    },
    var.tags,
  )
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_public1.id
  depends_on    = [ aws_internet_gateway.igw1 ]

  tags = merge(
    {
      Name = "nat, gateway, aws, vpc1",
    },
    var.tags,
  )
}