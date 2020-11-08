# Reference:
# https://github.com/glaucius/aws-terraform
# https://www.terraform.io/docs/providers/aws/d/route_table.html
# https://www.terraform.io/docs/providers/aws/d/route.html
# https://github.com/iaasweek/terraform

# Create route custom for public subnet
resource "aws_route_table" "route_table_subnet_public1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = merge(
    {
      Name = "route, public1, gateway, aws, vpc1",
    },
    var.tags,
  )
}

# Create route Access
#resource "aws_route" "internet_access" {
#  route_table_id         = aws_vpc.vpc_testing.route_table_subnet_public1
#  destination_cidr_block = "0.0.0.0/0"
#  gateway_id             = aws_internet_gateway.igw1.id
#}

# Associate route for public subnet
resource "aws_route_table_association" "route_subnet_public1" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.route_table_subnet_public1.id
}


# Create route custom for private subnet
resource "aws_route_table" "route_table_subnet_private1" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block     = "0.0.0.0/0" //associated subnet can reach everywhere
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(
    {
      Name = "route, private1, nat, gateway, aws, vpc1",
    },
    var.tags,
  )
}

# Associate route for private subnet
resource "aws_route_table_association" "route_subnet_private1" {
  subnet_id      = aws_subnet.subnet_private1.id
  route_table_id = aws_route_table.route_table_subnet_private1.id
}


