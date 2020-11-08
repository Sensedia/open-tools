# Create Security Group
resource "aws_security_group" "services" {
  name        = "terraform_services"
  description = "AWS security group for terraform"
  vpc_id      = aws_vpc.vpc1.id

  # Input
  ingress {
    from_port   = "1"
    to_port     = "65365"
    protocol    = "TCP"
    cidr_blocks = [var.address_allowed, var.vpc1_cidr_block]
  }

  # Output
  egress {
    from_port   = 0             # any port
    to_port     = 0             # any port
    protocol    = "-1"          # any protocol
    cidr_blocks = ["0.0.0.0/0"] # any destination
  }

  # ICMP Ping 
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.address_allowed, var.vpc1_cidr_block]
  }

  tags = merge(
    {
      Name = "security, group, aws, vpc1",
    },
    var.tags,
  )
}